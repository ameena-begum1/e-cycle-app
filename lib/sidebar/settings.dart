import 'package:e_cycle/Authentication/forget_password.dart';
import 'package:flutter/material.dart';
import 'package:e_cycle/Authentication/signin_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 65, 107),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          

          SizedBox(height: 20),

          // Settings Options
          _buildSettingsCard(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            ),
          ),
          _buildSettingsCard(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () async {
              final Uri url = Uri.parse('https://www.termsfeed.com/live/826d74b4-0ca3-447d-8cf0-8bb0479ed38e');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          _buildSettingsCard(
            context,
            icon: Icons.report,
            title: 'Report Problem',
            onTap: () async {
              final Uri url = Uri.parse('https://forms.gle/ktJnW7c4i4GmAUBb6');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SigninScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 8, 50, 117), // Solid green
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Spacer(),

          // Footer with Version & Copyright
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('© E-Cycle', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Widget for Modern Settings Card
  Widget _buildSettingsCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ListTile(
          leading: Icon(icon, color: const Color.fromARGB(255, 128, 128, 0), size: 28),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
