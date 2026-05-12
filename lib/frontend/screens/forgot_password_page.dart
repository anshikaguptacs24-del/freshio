import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/user_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: Reset
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  String? _generatedOtp;
  bool _isLoading = false;

  void _generateOtp() {
    final random = Random();
    _generatedOtp = (1000 + random.nextInt(9000)).toString();
    
    // For demo: Show OTP in Snackbar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Demo OTP: $_generatedOtp", style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _nextStep() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (_currentStep == 1) {
      if (!_emailCtrl.text.contains('@')) {
        _error("Enter a valid email");
        return;
      }
      _generateOtp();
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_otpCtrl.text == _generatedOtp) {
        setState(() => _currentStep = 3);
      } else {
        _error("Incorrect OTP. Try again.");
      }
    } else if (_currentStep == 3) {
      if (_passCtrl.text.length < 6) {
        _error("Password must be at least 6 characters");
        return;
      }
      if (_passCtrl.text != _confirmPassCtrl.text) {
        _error("Passwords do not match");
        return;
      }
      
      await context.read<UserProvider>().updatePassword(_passCtrl.text);
      _success();
    }
  }

  void _error(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.redAccent));
  
  void _success() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset successfully!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 32),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepView(),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(number: 1, active: _currentStep >= 1),
        _StepLine(active: _currentStep >= 2),
        _StepDot(number: 2, active: _currentStep >= 2),
        _StepLine(active: _currentStep >= 3),
        _StepDot(number: 3, active: _currentStep >= 3),
      ],
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildEmailStep();
      case 2:
        return _buildOtpStep();
      case 3:
        return _buildResetStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Forgot Password?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text("Enter your email address to receive a verification code.", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        _buildTextField(_emailCtrl, "Email Address", Icons.email_outlined, TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Verify Identity", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text("We've sent a 4-digit code to your email. Check your inbox (or the snackbar above).", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        _buildTextField(_otpCtrl, "4-Digit OTP", Icons.lock_clock_outlined, TextInputType.number),
      ],
    );
  }

  Widget _buildResetStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("New Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text("Create a strong new password to secure your account.", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        _buildTextField(_passCtrl, "New Password", Icons.lock_outline_rounded, TextInputType.visiblePassword, isObscure: true),
        const SizedBox(height: 16),
        _buildTextField(_confirmPassCtrl, "Confirm Password", Icons.lock_outline_rounded, TextInputType.visiblePassword, isObscure: true),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, TextInputType type, {bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final theme = Theme.of(context);
    String label = "Send OTP";
    if (_currentStep == 2) label = "Verify Code";
    if (_currentStep == 3) label = "Reset Password";

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool active;
  const _StepDot({required this.number, required this.active});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: active ? primary : Colors.grey.shade200, shape: BoxShape.circle),
      child: Center(child: Text("$number", style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
      ),
    );
  }
}