import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String? verificationId;
  bool isLoading = false;
  bool otpSent = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white,
              elevation: 10,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 70,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Phone Login 📲",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in securely with your phone number",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Phone Number Field
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: "Phone Number (+91...)",
                        hintText: "+911234567890",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!otpSent)
                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final phone = phoneController.text.trim();
                                  if (phone.isEmpty || !phone.startsWith('+')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter a valid phone number with country code (+91...)",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  await auth.signInWithPhone(
                                    context, // Added context
                                    phone,
                                    (id) {
                                      setState(() {
                                        verificationId = id;
                                        otpSent = true;
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "OTP sent successfully!",
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  setState(() => isLoading = false);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            isLoading ? "Sending..." : "Send OTP",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                    // OTP Section
                    if (otpSent)
                      Column(
                        key: const ValueKey('otpSection'),
                        children: [
                          const SizedBox(height: 30),
                          TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: "Enter OTP",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final otp = otpController.text.trim();
                                      if (otp.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please enter the OTP",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => isLoading = true);
                                      final result = await auth.verifyOtp(
                                        verificationId!,
                                        otp,
                                      );
                                      setState(() => isLoading = false);

                                      if (result == null) {
                                        // Success
                                        if (!context.mounted) return;
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const HomeScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      } else {
                                        // Error
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(result)),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              icon: const Icon(Icons.verified),
                              label: Text(
                                isLoading ? "Verifying..." : "Verify OTP",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                otpSent = false;
                                verificationId = null;
                                otpController.clear();
                              });
                            },
                            child: const Text(
                              "Change Phone Number",
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
