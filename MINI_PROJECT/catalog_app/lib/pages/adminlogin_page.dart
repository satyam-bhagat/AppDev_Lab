import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:velocity_x/velocity_x.dart';

class AdminLoginPage extends StatefulWidget {
  final String email;
  final String password;

  const AdminLoginPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyAdminCodeAndLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('admin_code')
          .get();

      // --- FIX: Removed the "1234" fallback ---
      // This will now give a clear error if the doc is missing.
      if (!doc.exists || !doc.data()!.containsKey('code')) {
        throw Exception("Admin code configuration not found in Firestore.");
      }

      final String correctCode = doc.data()!['code'] as String;
      final String enteredCode = _codeController.text.trim();

      if (correctCode != enteredCode) {
        throw Exception("Incorrect Admin Code.");
      }

      // --- FIX: Only sign in. Do not fetch role or redirect. ---
      // The GoRouter will see the auth change and redirect to HomePage.
      // The HomePage will then fetch the 'admin' role.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // --- REMOVED 'LoadUserDataMutation' ---
      // --- REMOVED 'context.go(MyRoutes.adminPanelRoute)' ---
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false); // Stop loading on error
    }
    // --- REMOVED 'finally' block ---
    // On success, this page will be unmounted by the router.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        title: const Text("Admin Verification"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.security, size: 80, color: Colors.red),
                  20.heightBox,
                  "Admin Login".text.xl4.bold.make(),
                  "Please enter the secret admin code to proceed."
                      .text
                      .gray500
                      .center
                      .make(),
                  40.heightBox,
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _codeController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Admin Code",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      validator: (v) => v!.isEmpty ? "Code is required" : null,
                    ),
                  ),
                  20.heightBox,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifyAdminCodeAndLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white))
                          : "Verify and Login".text.xl.make(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
