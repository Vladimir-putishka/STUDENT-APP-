import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {

  final Function(String, String, String) onRegister;

  const RegistrationScreen({
    super.key,
    required this.onRegister,
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

  String selectedRole = 'Student';

  void register() {

    bool isValid = _formKey.currentState!.validate();

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept Terms and Conditions',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isValid) {

      debugPrint('===== USER REGISTRATION =====');
      debugPrint('Full Name: ${nameController.text}');
      debugPrint('Email: ${emailController.text}');
      debugPrint('Role: $selectedRole');
      debugPrint('Terms Accepted: $acceptTerms');
      debugPrint('=============================');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onRegister(
        nameController.text,
        emailController.text,
        selectedRole,
      );
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          autovalidateMode:
          AutovalidateMode.onUserInteraction,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              const Center(
                child: Icon(
                  Icons.school,
                  size: 70,
                  color: Color(0xFF405DE6),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Create Your Account',
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

                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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

                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@narxoz.kz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
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

                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimum 6 characters',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(
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

                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Repeat your password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
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

              // ROLE

              DropdownButtonFormField<String>(
                initialValue: selectedRole,

                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
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

              // TERMS

              CheckboxListTile(
                title: const Text(
                  'I accept the Terms and Conditions',
                ),

                value: acceptTerms,

                controlAffinity:
                ListTileControlAffinity.leading,

                onChanged: (value) {
                  setState(() {
                    acceptTerms = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 25),

              // REGISTER

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF405DE6),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}