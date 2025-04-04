import 'package:flutter/material.dart';

class Gamification extends StatelessWidget {
  const Gamification({super.key});
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ई-Wallet'),
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
              '♻ Gamification Coming Soon! ♻\n'
              'Earn ई-Coins every time you sell, repair, recycle or donate electronics. Redeem points for exclusive rewards, discounts, or eco-friendly perks!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ));
  }
}
