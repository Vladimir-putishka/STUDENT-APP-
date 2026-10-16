import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),

            child: ListView(
              padding: const EdgeInsets.all(20),

              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                const Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFFE5E9FF),

                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Color(0xFF405DE6),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    widget.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  color: Colors.white,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text('Full Name: ${widget.name}'),

                        const SizedBox(height: 12),

                        Text('Email: ${widget.email}'),

                        const SizedBox(height: 12),

                        Text('Role: ${widget.role}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                SwitchListTile(
                  title: const Text('Notifications'),
                  value: notificationsEnabled,

                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: darkMode,

                  onChanged: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: widget.onLogout,

                  icon: const Icon(Icons.logout),

                  label: const Text('Logout'),

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}