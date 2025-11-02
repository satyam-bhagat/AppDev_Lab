import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Get current user
  User? get currentUser => _auth.currentUser;

  // ✅ Listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Email Sign Up
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Email Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return 'Sign-in aborted by user';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error: ${e.message}");
      return e.message ?? 'Google sign-in failed';
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return e.toString();
    }
  }

  // ✅ Phone Sign-In - FIXED
  Future<void> signInWithPhone(
    BuildContext context, // Added context parameter
    String phoneNumber,
    Function(String) onCodeSent,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          debugPrint('✅ Phone number automatically verified');
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('📩 Code sent to $phoneNumber');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⚠️ Auto retrieval timeout');
        },
      );
    } catch (e) {
      debugPrint('🔥 Error during phone sign-in: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ✅ Verify OTP
  Future<String?> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      debugPrint("OTP verification failed: ${e.message}");
      return e.message ?? 'OTP verification failed';
    } catch (e) {
      debugPrint("OTP verification error: $e");
      return e.toString();
    }
  }

  // ✅ Send Password Reset Email
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset email';
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Delete Account
  Future<String?> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to delete account';
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
