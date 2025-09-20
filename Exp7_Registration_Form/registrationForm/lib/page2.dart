import 'package:flutter/material.dart';
import 'page3.dart';

class Page2 extends StatefulWidget {
  final String firstName, lastName, age;
  const Page2({super.key, required this.firstName, required this.lastName, required this.age});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 2: Contact & Security")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Enter your email address"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Enter your phone number"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Create a password"),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm your password"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Page3(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      age: widget.age,
                      email: emailController.text,
                      phone: phoneController.text,
                      password: passwordController.text,
                    ),
                  ),
                );
              },
              child: const Text("Next"),
            )
          ],
        ),
      ),
    );
  }
}
