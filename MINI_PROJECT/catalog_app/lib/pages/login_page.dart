import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/user.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final _adminEmails = ["vpg@gmail.com", "student@admin.com"];

  void _loading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _loadRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        _error("User data not found.");
        return;
      }

      final userModel = UserModel.fromFirestore(doc);
      LoadUserDataMutation(userModel);
    } catch (e) {
      _error("Failed to fetch role: $e");
    }
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    _loading(true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Admin special route
    if (_adminEmails.contains(email)) {
      context.push(MyRoutes.adminLoginRoute,
          extra: {"email": email, "password": password});
      _loading(false);
      return;
    }

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (cred.user != null) {
        await _loadRole(cred.user!);
      }
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Login failed");
      _loading(false);
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _loginWithGoogle() async {
    _loading(true);

    try {
      const String clientId =
          "535242589665-6kfe9lrctdjh3jqpoehakjmqlab5a23p.apps.googleusercontent.com";

      final googleUser = await GoogleSignIn(clientId: clientId).signIn();
      if (googleUser == null) {
        _loading(false);
        return;
      }

      if (_adminEmails.contains(googleUser.email)) {
        _error("Admins must use email/password.");
        GoogleSignIn().signOut();
        _loading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCred.user != null) {
        await _createUserIfNew(userCred.user!);
        await _loadRole(userCred.user!);
      }
    } catch (e) {
      _error(e.toString());
      _loading(false);
    }
  }

  // Create user in Firestore if first time login
  Future<void> _createUserIfNew(User user) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    if ((await doc.get()).exists) return;

    await doc.set({
      "uid": user.uid,
      "email": user.email,
      "displayName": user.displayName ?? user.email?.split('@').first,
      "firstName": null,
      "lastName": null,
      "username": null,
      "photoURL": user.photoURL,
      "createdAt": FieldValue.serverTimestamp(),
      "role": "user",
      "plan": "Free",
      "premium": false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              80.heightBox,
              "Welcome Back!".text.xl5.bold.white.make(),
              "Sign in to your account".text.xl.gray500.make(),
              40.heightBox,

              // ---------------- EMAIL/PASSWORD CARD ----------------
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "Enter email" : null,
                        ),
                        20.heightBox,
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Enter password" : null,
                        ),
                        20.heightBox,
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loginWithEmail,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: "Sign In".text.xl.make(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              20.heightBox,

              "Or sign in with".text.gray500.make(),
              20.heightBox,

              // ---------------- SOCIAL LOGIN CARD ----------------
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (!_isLoading)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.g_mobiledata,
                              color: Colors.red, size: 28),
                          onPressed: _loginWithGoogle,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          label: "Sign In with Google".text.xl.make(),
                        ),
                      20.heightBox,
                      if (!_isLoading)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.phone),
                          onPressed: () =>
                              context.push(MyRoutes.phoneAuthRoute),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          label: "Sign In with Phone".text.xl.white.make(),
                        ),
                    ],
                  ),
                ),
              ),

              20.heightBox,

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "Don't have an account? ".text.make(),
                  TextButton(
                    onPressed: () => context.go(MyRoutes.signupRoute),
                    child: "Sign Up".text.bold.make(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:catalog_app/utils/routes.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:velocity_x/velocity_x.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;

//   final _adminEmails = ["vpg@gmail.com", "student@admin.com"];

//   void _showLoading(bool loading) {
//     if (mounted) setState(() => _isLoading = loading);
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: Colors.red),
//       );
//     }
//   }

//   // --- _fetchAndStoreRole is REMOVED from this file ---
//   // --- _checkAndCreateUserData is REMOVED from this file ---

//   Future<void> _signInWithEmail() async {
//     if (!_formKey.currentState!.validate()) return;
//     _showLoading(true);

//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();

//     if (_adminEmails.contains(email)) {
//       if (mounted) {
//         context.push(
//           MyRoutes.adminLoginRoute,
//           extra: {'email': email, 'password': password},
//         );
//       }
//       _showLoading(false);
//       return;
//     }

//     try {
//       // 1. Just sign in.
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       // 2. DO NOT fetch role here. GoRouter will handle the redirect.
//       //    The HomePage will be responsible for fetching the role.
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? "Login failed.");
//       _showLoading(false); // Stop loading *only* if there's an error
//     }
//     // No 'finally' block needed. On success, this page will be
//     // unmounted by the router, so we don't need to set _isLoading = false.
//   }

//   Future<void> _signInWithGoogle() async {
//     _showLoading(true);
//     try {
//       final String webClientId =
//           "535242589665-6kfe9lrctdjh3jqpoehakjmqlab5a23p.apps.googleusercontent.com"; // Your Client ID

//       final GoogleSignInAccount? googleUser = await GoogleSignIn(
//         clientId: webClientId,
//         serverClientId: webClientId,
//       ).signIn();

//       if (googleUser == null) {
//         _showLoading(false);
//         return; // User cancelled
//       }

//       if (_adminEmails.contains(googleUser.email)) {
//         _showError("Admin login is only allowed with Email/Password.");
//         _showLoading(false);
//         await GoogleSignIn().signOut();
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // 1. Just sign in.
//       await FirebaseAuth.instance.signInWithCredential(credential);

//       // 2. DO NOT check/create user or fetch role here.
//       //    The HomePage will handle this.
//     } catch (e) {
//       _showError(e.toString());
//       _showLoading(false); // Stop loading *only* if there's an error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.canvasColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               80.heightBox,
//               "Welcome Back!".text.xl5.bold.make(),
//               "Sign in to your account".text.xl.gray500.make(),
//               40.heightBox,
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: const InputDecoration(
//                             labelText: "Email",
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.email_outlined),
//                           ),
//                           validator: (v) => v!.isEmpty ? "Enter email" : null,
//                         ),
//                         20.heightBox,
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             labelText: "Password",
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.lock_outline),
//                           ),
//                           validator: (v) =>
//                               v!.isEmpty ? "Enter password" : null,
//                         ),
//                         20.heightBox,
//                         if (_isLoading)
//                           const CircularProgressIndicator()
//                         else
//                           ElevatedButton(
//                             onPressed: _signInWithEmail,
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(double.infinity, 50),
//                             ),
//                             child: "Sign In".text.xl.make(),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               20.heightBox,
//               "Or sign in with".text.gray500.make(),
//               20.heightBox,
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     children: [
//                       if (!_isLoading)
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.g_mobiledata,
//                               color: Colors.red, size: 28),
//                           onPressed: _signInWithGoogle,
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size(double.infinity, 50),
//                             backgroundColor: Colors.white,
//                             foregroundColor: Colors.black,
//                           ),
//                           label: "Sign In with Google".text.xl.make(),
//                         ),
//                       20.heightBox,
//                       if (!_isLoading)
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.phone, size: 24),
//                           onPressed: () {
//                             context.push(MyRoutes.phoneAuthRoute);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size(double.infinity, 50),
//                             backgroundColor: Colors.green.shade600,
//                             foregroundColor: Colors.white,
//                           ),
//                           label: "Sign In with Phone".text.xl.white.make(),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               20.heightBox,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   "Don't have an account? ".text.make(),
//                   TextButton(
//                     onPressed: () => context.go(MyRoutes.signupRoute),
//                     child: "Sign Up".text.bold.make(),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
