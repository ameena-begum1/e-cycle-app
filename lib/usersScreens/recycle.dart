import 'package:e_cycle/maps/floating_map_icon/epr_certified_centers/centers_list.dart';
import 'package:e_cycle/reusablewidgets/app_colors.dart';
import 'package:e_cycle/usersScreens/chatbot_screen.dart';
import 'package:e_cycle/usersScreens/recycle_form.dart';
import 'package:flutter/material.dart';

class RecycleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    backgroundColor: Color(0xFF003366),
    iconTheme: IconThemeData(color: Colors.white), 
    title: const Text(
      "Recycle Services",
      style: TextStyle(color: Colors.white),
    ),
  ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Recycle Responsibly",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    title: "Recycle Now",
                    icon: Icons.recycling,
                    color: AppTheme.greenColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecycleFormScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    title: "Locate Govt. Certified Recycling Centers",
                    icon: Icons.location_on,
                    color: Colors.red,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EprMapScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSleekCard(
              title: "AI-Assist",
              icon: Icons.support_agent,
              color: Color(0xFF003366),
              onTap: () {
                
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()));
              },
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/recycle.jpeg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Strong, heartfelt quote
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                '"The greatest threat to our planet is the belief that someone else will save it."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 30), 
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleekCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
