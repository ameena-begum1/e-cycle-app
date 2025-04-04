import 'package:e_cycle/reusablewidgets/app_colors.dart';
import 'package:e_cycle/roleRegistration/volunteer.dart';
import 'package:flutter/material.dart';
import 'package:e_cycle/roleRegistration/ngo.dart';
import 'package:e_cycle/roleRegistration/recycler.dart';
import 'package:e_cycle/roleRegistration/technician.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "ई-Cycle",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "What would you like to join us as?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '"The greatest threat to our planet is the belief that someone else will save it."',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoleCard(
                  role: "NGO",
                  screen: NGOProfileScreen(),
                  icon: Icons.volunteer_activism,
                  backgroundColor: AppTheme.orangeColor,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                ),
                RoleCard(
                  role: "Recycler",
                  screen: RecyclerProfileScreen(),
                  icon: Icons.recycling,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 20), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoleCard(
                  role: "Technician",
                  screen:
                      TechnicianRegistrationScreen(), // Create this screen separately
                  icon: Icons.build, // Wrench/Tools icon
                  backgroundColor: Colors.blue, // Blue theme for technicians
                  textColor: Colors.white,
                  borderColor: Colors.white,
                ),
                RoleCard(
                  role: "Volunteer",
                  screen:
                      RegisterVolunteerScreen(), // Create this screen separately
                  icon: Icons.person, // Wrench/Tools icon
                  backgroundColor: Colors.amber, //
                  textColor: Colors.white,
                  borderColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String role;
  final Widget screen;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  RoleCard({
    required this.role,
    required this.screen,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 50),
            SizedBox(height: 10),
            Text(
              role,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
