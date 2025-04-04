import 'package:e_cycle/maps/floating_map_icon/repair_centers/search_screen.dart';
import 'package:e_cycle/usersScreens/chatbot_screen.dart';
import 'package:e_cycle/usersScreens/home_service.dart';
import 'package:flutter/material.dart';

class RepairScreen extends StatelessWidget {
  const RepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    backgroundColor: Color(0xFF003366),
    iconTheme: IconThemeData(color: Colors.white), // Makes the back button white
    title: const Text(
      "Repair Services",
      style: TextStyle(color: Colors.white),
    ),
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Select a Repair Service",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Two big square cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildServiceCard(
                    title: "Book Home Service",
                    icon: Icons.home_repair_service,
                    color: Colors.blue[900]!, // Changed to Dark Blue
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeServiceScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    title: "Locate Nearby Centers",
                    icon: Icons.location_on,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI-Powered Assistant
            _buildSleekCard(
              title: "AI-Assist",
              icon: Icons.support_agent,
              color: Colors.green,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()));
              },
            ),

            const SizedBox(height: 20),

            // Image Below the Cards
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/repair.jpg', // Make sure this image exists in your assets
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
                '"Every repair is a step towards a cleaner planet. Reduce waste, cherish what you own, and make sustainability a habit."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a square-shaped card
  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Square shape
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

  // Helper method to create a sleek rectangular card
  Widget _buildSleekCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // Sleek rectangle
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
