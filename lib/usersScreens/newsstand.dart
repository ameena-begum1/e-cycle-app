import 'package:flutter/material.dart';

class Newsroom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ई-Cycle Newsstand',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/news.jpg', 
                width: 350, 
                height: 250, 
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                "Stay updated with the latest e-waste news, sustainability insights, and awareness posts from our team. Join the movement towards a greener future!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
