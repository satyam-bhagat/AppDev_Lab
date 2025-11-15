import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/user.dart';
// import 'package:catalog_app/utils/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _verificationId = "";

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

  Future<void> _fetchAndStoreRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        LoadUserDataMutation(userModel);
      } else {
        _showError("User data not found. Please contact support.");
      }
    } catch (e) {
      _showError(_getErrorMessage(e));
    }
  }

  Future<void> _checkAndCreateUserData(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.phoneNumber ?? 'New User',
          'firstName': null,
          'lastName': null,
          'username': null,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'role': "user",
          'plan': 'Free',
          'premium': false,
        });
      }
    } catch (e) {
      _showError(_getErrorMessage(e));
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      _showError("Please enter a phone number.");
      return;
    }
    _showLoading(true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          _showLoading(true);
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            await _checkAndCreateUserData(userCredential);
            await _fetchAndStoreRole(userCredential.user!);
          } catch (e) {
            _showError(_getErrorMessage(e));
            _showLoading(false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(_getErrorMessage(e));
          _showLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _otpSent = true;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
            });
          }
        },
      );
    } catch (e) {
      _showError(_getErrorMessage(e));
      _showLoading(false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showError("Please enter the OTP.");
      return;
    }
    _showLoading(true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await _checkAndCreateUserData(userCredential);
      await _fetchAndStoreRole(userCredential.user!);
      // GoRouter redirect will handle navigation
    } catch (e) {
      _showError(_getErrorMessage(e));
      _showLoading(false); // Stop loading on error
    } finally {
      // No _showLoading(false) on success, page will be gone
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return "No internet connection. Please check your network and try again.";
        case 'too-many-requests':
          return "Too many requests. Please try again later.";
        case 'invalid-phone-number':
          return "Invalid phone number. Please check and try again.";
        case 'invalid-verification-code':
          return "Invalid verification code. Please check and try again.";
        case 'session-expired':
          return "Session expired. Please request a new code.";
        default:
          return error.message ?? "An error occurred. Please try again.";
      }
    }

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return "No internet connection. Please check your network and try again.";
    }

    return "An error occurred: $error";
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Enter your phone number".text.xl2.make(),
        "We will send you a verification code".text.gray500.make(),
        30.heightBox,
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone (e.g., +919876543210)",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        30.heightBox,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendOtp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: "Send OTP".text.xl.make(),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "Verify your number".text.xl2.make(),
        "Enter the 6-digit code sent to ${_phoneController.text}"
            .text
            .gray500
            .make(),
        30.heightBox,
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "6-Digit Code",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.password),
          ),
        ),
        30.heightBox,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: "Verify & Sign In".text.xl.make(),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _otpSent = false),
          child: "Wrong number?".text.make(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in with Phone"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const CircularProgressIndicator().centered().h(250)
                    : _otpSent
                        ? _buildOtpInput()
                        : _buildPhoneInput(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
