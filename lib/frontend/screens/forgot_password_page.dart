import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  // 📧 VALIDATION
  ////////////////////////////////////////////////////////////

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  ////////////////////////////////////////////////////////////
  // 🔁 RESET LOGIC
  ////////////////////////////////////////////////////////////

  void _sendResetLink() async {
    String email = emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage("Enter a valid email");
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    _showMessage("Reset link sent to $email");
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 40),

              //////////////////////////////////////////////////
              // 🔙 BACK
              //////////////////////////////////////////////////

              InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 6),
                    Text("Back"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////
              // TITLE
              //////////////////////////////////////////////////

              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter your email and we'll send a reset link.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////
              // EMAIL
              //////////////////////////////////////////////////

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // BUTTON
              //////////////////////////////////////////////////

              ElevatedButton(
                onPressed: isLoading ? null : _sendResetLink,

                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Send Reset Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}