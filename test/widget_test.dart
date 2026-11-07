import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_assistant/main.dart';
import 'package:student_assistant/models/catalog_product.dart';
import 'package:student_assistant/providers/cart_provider.dart';
import 'package:student_assistant/screens/catalog_screen.dart';
import 'package:student_assistant/services/auth_service.dart';
import 'package:student_assistant/services/student_storage.dart';
import 'package:student_assistant/widgets/catalog_product_card.dart';
import 'package:student_assistant/widgets/news_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Student Assistant signs in after creating a local account',
    (WidgetTester tester) async {
      await tester.pumpWidget(const StudentAssistantApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Welcome Back!'),
        findsOneWidget,
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(
        find.text('Student Registration'),
        findsOneWidget,
      );

      expect(
        find.text('Create Your Account'),
        findsOneWidget,
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Aruzhan');
      await tester.enterText(fields.at(1), 'aruzhan@example.edu');
      await tester.enterText(fields.at(2), 'student-pass');
      await tester.enterText(fields.at(3), 'student-pass');
      final acknowledgment = find.byType(CheckboxListTile);
      await tester.ensureVisible(acknowledgment);
      await tester.pumpAndSettle();
      await tester.tap(acknowledgment);
      await tester.ensureVisible(find.text('Register'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Aruzhan!'), findsOneWidget);
    },
  );

  test('CartProvider adds, removes and totals unique products', () {
    const product = CatalogProduct(
      id: 1,
      title: 'Test product',
      category: 'Test',
      price: 2500,
      rating: 5,
      icon: Icons.book,
      color: Colors.blue,
    );
    final cart = CartProvider();

    cart.addToCart(product);
    cart.addToCart(product);

    expect(cart.itemCount, 1);
    expect(cart.totalPrice, 2500);
    expect(cart.isInCart(product), isTrue);

    cart.removeFromCart(product);
    expect(cart.itemCount, 0);

    cart.clearAll();
    expect(cart.items, isEmpty);
  });

  testWidgets('Marketplace stays synchronized with Cart',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(
          home: CatalogScreen(),
        ),
      ),
    );

    expect(find.text('Student Marketplace'), findsOneWidget);
    expect(find.text('6 products available'), findsOneWidget);
    expect(find.text('Add to Cart'), findsAtLeastNWidgets(5));

    await tester.tap(find.text('Add to Cart').first);
    await tester.pump();

    expect(find.text('Remove from Cart'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();

    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Total · 1 item'), findsOneWidget);
    expect(find.text('499990 ₸'), findsNWidgets(2));

    await tester.tap(find.text('Clear All'));
    await tester.pump();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  test('Local account verifies passwords and restores the session', () async {
    await AuthService.register(
      name: 'Sam Student',
      email: ' SAM@example.edu ',
      password: 'student-pass',
      role: 'Student',
    );
    expect((await AuthService.currentUser())?['email'], 'sam@example.edu');
    await AuthService.logout();
    expect(await AuthService.currentUser(), isNull);
    expect(
      await AuthService.login(email: 'sam@example.edu', password: 'wrong'),
      isFalse,
    );
    expect(await AuthService.currentUser(), isNull);
    expect(
      await AuthService.login(
          email: 'sam@example.edu', password: 'student-pass'),
      isTrue,
    );
  });

  for (final grid in [false, true]) {
    testWidgets('Pull to refresh prepends an item after 1.5s in ${grid ? 'grid' : 'list'}',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
          child: const MaterialApp(home: CatalogScreen()),
        ),
      );
      if (grid) {
        await tester.tap(find.byTooltip('Switch to grid'));
        await tester.pumpAndSettle();
      }

      final refresh = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      ).onRefresh();
      await tester.pump(const Duration(milliseconds: 1499));
      expect(find.text('6 products available'), findsOneWidget);
      expect(find.text('New Study Item 7'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await refresh;
      await tester.pump();
      expect(find.text('7 products available'), findsOneWidget);
      expect(
        tester.widget<CatalogProductCard>(find.byType(CatalogProductCard).first)
            .product.title,
        'New Study Item 7',
      );
      await tester.drag(
        find.byType(grid ? GridView : ListView),
        const Offset(0, 350),
      );
      await tester.pump();
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('8 products available'), findsOneWidget);
    });
  }

  test('Cart restores refreshed products and still reads saved seed IDs',
      () async {
    SharedPreferences.setMockInitialValues({
      'student.sam@example.edu.cart': '[1]',
    });
    final storage = StudentStorage(
      await SharedPreferences.getInstance(),
      'sam@example.edu',
    );
    final cart = CartProvider(storage);
    expect(cart.items.single.title, 'MacBook Air');
    const newProduct = CatalogProduct(
      id: 100,
      title: 'New Study Item 7',
      category: 'Stationery',
      price: 9990,
      rating: 4.9,
      icon: Icons.menu_book,
      color: Color(0xFF405DE6),
    );
    await cart.addToCart(newProduct);
    final restored = CartProvider(storage);
    expect(restored.itemCount, 2);
    expect(restored.items.last.title, newProduct.title);
    expect(restored.totalPrice, 509980);
    cart.dispose();
    restored.dispose();
  });

  testWidgets('Student data survives a restart and is scoped to the account',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'app_users_v2': jsonEncode([
        {'email': 'sam@example.edu', 'name': 'Sam', 'role': 'Student'},
        {'email': 'lee@example.edu', 'name': 'Lee', 'role': 'Student'},
      ]),
      'app_session_v2': 'sam@example.edu',
      'student_tasks_v1': jsonEncode([
        {
          'id': 'old-task',
          'title': 'Legacy assignment',
          'subject': 'Math',
          'description': 'Migrated',
          'dueDate': 'Oct 28',
          'category': 'Quiz',
          'color': 0xFF405DE6,
        },
      ]),
    });

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).hitTestable().first);
      await tester.pumpAndSettle();
    }

    Future<void> startApp() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const StudentAssistantApp());
      await tester.pumpAndSettle();
    }

    await startApp();
    expect(find.text('Hello, Sam!').hitTestable(), findsOneWidget);
    await tapText('Weekly schedule');
    await tapText('Add class');
    await tester.enterText(find.byType(TextFormField).first, 'Linear Algebra');
    await tapText('Save class');
    expect(find.text('Linear Algebra').hitTestable(), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Linear Algebra').hitTestable(), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cybersecurity Workshop'),
      250,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    final favoriteButton = find.descendant(
      of: find.widgetWithText(NewsCard, 'Cybersecurity Workshop'),
      matching: find.byTooltip('Add to favorites'),
    );
    await Scrollable.ensureVisible(tester.element(favoriteButton), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();
    await tapText('Favorites');
    expect(find.text('Cybersecurity Workshop').hitTestable(), findsOneWidget);

    await tapText('Marketplace');
    await tapText('Add to Cart');
    await tapText('Profile');
    await tapText('Dark Mode');
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);

    await startApp();
    expect(find.text('Linear Algebra').hitTestable(), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
    await tapText('Favorites');
    expect(find.text('Cybersecurity Workshop').hitTestable(), findsOneWidget);
    await tapText('Marketplace');
    expect(find.text('Remove from Cart').hitTestable(), findsOneWidget);
    await tapText('Tasks');
    expect(find.text('Legacy assignment').hitTestable(), findsOneWidget);

    await tapText('Profile');
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tapText('Logout');
    expect(find.text('Welcome Back!'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_session_v2', 'lee@example.edu');
    await startApp();
    expect(find.text('Hello, Lee!').hitTestable(), findsOneWidget);
    expect(find.text('No classes scheduled for today.'), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);
    await tapText('Tasks');
    expect(find.text('Legacy assignment').hitTestable(), findsNothing);
    await tapText('Favorites');
    expect(find.text('No favorites yet').hitTestable(), findsOneWidget);
    await tapText('Marketplace');
    expect(find.text('Remove from Cart').hitTestable(), findsNothing);
  });

  testWidgets('Planner supports creating, editing and undoing deletion',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'app_users_v2': jsonEncode([
        {'email': 'sam@example.edu', 'name': 'Sam', 'role': 'Student'},
      ]),
      'app_session_v2': 'sam@example.edu',
    });
    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).hitTestable().first);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const StudentAssistantApp());
    await tester.pumpAndSettle();
    await tapText('Tasks');
    await tapText('Add Task');
    await tester.enterText(find.byType(TextFormField).at(0), 'Read chapter 2');
    await tester.enterText(find.byType(TextFormField).at(1), 'Economics');
    await tapText('Select due date');
    await tapText('OK');
    await tapText('Add Assignment');

    await tapText('Read chapter 2');
    await tester.tap(find.byTooltip('Edit assignment'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Read chapter 3');
    await tapText('Save Changes');
    expect(find.text('Read chapter 3').hitTestable(), findsOneWidget);
    await tapText('Mark as Completed');
    expect(find.text('Completed').hitTestable(), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(Dismissible).hitTestable(), const Offset(-310, 0));
    await tester.pumpAndSettle();
    expect(find.text('Read chapter 3').hitTestable(), findsNothing);
    await tapText('UNDO');
    expect(find.text('Read chapter 3').hitTestable(), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Search assignments'),
      'missing',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching assignments').hitTestable(), findsOneWidget);
  });
}
