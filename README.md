# Student Assistant

A local Flutter workspace for university students. The home screen shows today's classes, open assignments ordered by deadline, and progress.

## Use the app

- Create a local account or sign in with an existing one.
- Open **Weekly schedule** from Home to add, edit, or remove repeating classes.
- In **Tasks**, create assignments, search by title or course, filter by status, or switch between list and grid. Open an assignment to edit it, bookmark it, or mark it complete. Swipe to delete and tap **Undo** to restore it. Pull down to reload saved tasks.
- Save articles to **Favorites**. The news section contains sample announcements.
- In **Marketplace**, pick from six study products and manage the cart. Prices are shown in tenge.
- Turn on **Dark Mode** in Profile to save the preference for your account.

Tasks, classes, article bookmarks, cart, and theme are stored on this device per account. Data from the old shared task list is imported into the first local account on the device. Local accounts use the existing password and session storage. A university feed, payments, and cloud synchronization require external services.

## Run and check

Open the existing project in Android Studio, or run these commands in the project directory with a Flutter device or emulator available.

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```
