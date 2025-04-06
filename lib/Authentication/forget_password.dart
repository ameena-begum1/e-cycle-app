import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar('Please enter your email address.', Colors.orange);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackBar('Password reset email sent successfully.', Colors.green);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? 'An error occurred.', Colors.red);
    }
  }

  Future<void> changePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showSnackBar('Please fill in all fields.', Colors.orange);
      return;
    }

    if (newPassword != confirmPassword) {
      showSnackBar('Passwords do not match.', Colors.red);
      return;
    }

    try {
      await user!.updatePassword(newPassword);
      showSnackBar('Password changed successfully.', Colors.green);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? 'An error occurred.', Colors.red);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF003366)) : null,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFF003366),
        title: Text(
          isLoggedIn ? 'Change Password' : 'Reset Password',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  size: 60,
                  color: Color(0xFF003366),
                ),
                SizedBox(height: 20),
                Text(
                  isLoggedIn
                      ? 'Secure your account by updating your password.'
                      : 'Enter your email to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15.5, color: Colors.grey[800]),
                ),
                SizedBox(height: 30),
                if (isLoggedIn) ...[
                  _buildTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscure: true,
                    icon: Icons.lock,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscure: true,
                    icon: Icons.lock_outline,
                  ),
                ] else ...[
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                  ),
                ],
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoggedIn ? changePassword : sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003366),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      isLoggedIn ? 'Change Password' : 'Send Reset Link',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
