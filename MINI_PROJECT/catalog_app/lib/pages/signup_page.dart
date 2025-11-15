import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/user.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Added
  bool _isLoading = false;

  void _showLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _showLoading(true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.email!.split('@').first,
        role: 'user',
        plan: 'Free',
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'displayName': newUser.displayName,
        'firstName': null,
        'lastName': null,
        'username': null,
        'photoURL': user.photoURL,
        'role': newUser.role,
        'plan': newUser.plan,
        'premium': newUser.hasPaidPlan,
        'createdAt': FieldValue.serverTimestamp(),
      });

      LoadUserDataMutation(newUser);
      // No success message needed, GoRouter will redirect
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registration failed.");
      _showLoading(false); // Stop loading on error
    } finally {
      // No _showLoading(false) on success, page will be gone
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: context.theme.colorScheme.secondary),
          onPressed: () => context.go(MyRoutes.loginRoute),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              80.heightBox,
              "Create Account".text.xl5.bold.make(),
              "Start your journey with us".text.xl.gray500.make(),
              40.heightBox,
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => v!.isEmpty ? "Enter email" : null,
                        ),
                        20.heightBox,
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password (6+ characters)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return "Enter password";
                            if (v.length < 6) return "Password too short";
                            return null;
                          },
                        ),
                        20.heightBox,
                        TextFormField(
                          // Confirm Password
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_clock_outlined),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return "Please confirm password";
                            if (v != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        30.heightBox,
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _registerWithEmail,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: "Sign Up".text.xl.make(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "Already have an account? ".text.make(),
                  TextButton(
                    onPressed: () => context.go(MyRoutes.loginRoute),
                    child: "Sign In".text.bold.make(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
