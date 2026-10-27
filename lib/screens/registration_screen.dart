import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  final Future<void> Function(
      String,
      String,
      String,
      String,
      ) onRegister;

  final VoidCallback onLogin;

  const RegistrationScreen({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool acceptTerms = false;
  bool showPassword = false;
  bool isLoading = false;
  bool showTermsError = false;

  String selectedRole = 'Student';

  // REGISTER USER

  Future<void> register() async {
    if (isLoading) return;

    final isValid = _formKey.currentState!.validate();

    setState(() {
      showTermsError = !acceptTerms;
    });

    if (!isValid || !acceptTerms) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await widget.onRegister(
        nameController.text.trim(),
        emailController.text.trim().toLowerCase(),
        passwordController.text,
        selectedRole,
      );

      debugPrint('===== USER REGISTRATION =====');
      debugPrint('Full Name: ${nameController.text.trim()}');
      debugPrint('Email: ${emailController.text.trim()}');
      debugPrint('Role: $selectedRole');
      debugPrint('Terms Accepted: $acceptTerms');
      debugPrint('=============================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              autovalidateMode:
              AutovalidateMode.onUserInteraction,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 20),

                  // APP ICON

                  const Center(
                    child: Icon(
                      Icons.school,
                      size: 70,
                      color: Color(0xFF405DE6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TITLE

                  const Center(
                    child: Text(
                      'Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      'Register to continue to Student Assistant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FULL NAME

                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,

                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full Name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // EMAIL

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,

                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@narxoz.kz',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD

                  TextFormField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    textInputAction: TextInputAction.next,

                    onChanged: (_) {
                      if (confirmController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },

                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimum 6 characters',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        tooltip: showPassword
                            ? 'Hide password'
                            : 'Show password',

                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // CONFIRM PASSWORD

                  TextFormField(
                    controller: confirmController,
                    obscureText: !showPassword,
                    textInputAction: TextInputAction.done,

                    onFieldSubmitted: (_) => register(),

                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Repeat your password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ROLE SELECTION

                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,

                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Student',
                        child: Text('Student'),
                      ),

                      DropdownMenuItem(
                        value: 'Teacher',
                        child: Text('Teacher'),
                      ),

                      DropdownMenuItem(
                        value: 'Developer',
                        child: Text('Developer'),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        selectedRole = value ?? 'Student';
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // TERMS AND CONDITIONS

                  CheckboxListTile(
                    title: const Text(
                      'I accept the Terms and Conditions',
                    ),

                    value: acceptTerms,

                    controlAffinity:
                    ListTileControlAffinity.leading,

                    contentPadding: EdgeInsets.zero,

                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value ?? false;
                        showTermsError = !acceptTerms;
                      });
                    },
                  ),

                  if (showTermsError)
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 4,
                      ),

                      child: Text(
                        'You must accept the terms to register',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // REGISTER BUTTON

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF405DE6),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BACK TO LOGIN

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'Already have an account?',
                        ),
                      ),

                      TextButton(
                        onPressed: isLoading
                            ? null
                            : widget.onLogin,

                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}