import 'package:flutter/material.dart';
import 'package:e_cycle/reusablewidgets/app_colors.dart';

class HomeServiceScreen extends StatelessWidget {
  const HomeServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(86, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: AppTheme.orangeColor,
        title: const Text("Home Service",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.home_repair_service, size: 100, color: AppTheme.orangeColor),
             Image.asset(
                'assets/images/home-service.jpg', 
                width: 350, 
                height: 250, 
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            const Text(
              "Home Service Feature Coming Soon!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "We’re working hard to bring you the best home repair services. Stay tuned!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
