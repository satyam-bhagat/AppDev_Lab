import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  final String userName = "Satyam Bhagat";
  final int userAge = 19;
  final String userEmail = "satyambhagat@gmail.com";
  final String userAddress = "Goa";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🧑 User Info Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "👤 User Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Name: $userName", style: const TextStyle(fontSize: 18)),
                Text("Age: $userAge", style: const TextStyle(fontSize: 18)),
                Text("Email: $userEmail", style: const TextStyle(fontSize: 18)),
                Text(
                  "Address: $userAddress",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 🔔 Notifications Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: const Text(
              "🔔 Notifications",
              style: TextStyle(fontSize: 18),
            ),
            subtitle: const Text("Enable or disable app notifications"),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),

        // 🌐 Language Settings
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text("🌐 Language", style: TextStyle(fontSize: 18)),
            subtitle: const Text("Select your preferred language"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Language settings coming soon..."),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 🔒 Privacy Settings
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("🔒 Privacy", style: TextStyle(fontSize: 18)),
            subtitle: const Text("Manage your privacy preferences"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Privacy settings coming soon..."),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
