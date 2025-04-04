import 'package:e_cycle/usersScreens/ngo_detail_screen.dart'; 
import 'package:flutter/material.dart';

class NgoSelectionScreen extends StatefulWidget {
  @override
  _NgoSelectionScreenState createState() => _NgoSelectionScreenState();
}

class _NgoSelectionScreenState extends State<NgoSelectionScreen> {
  bool _isRecommendedSelected = true;

  final List<Map<String, String>> allNgos = [
    {"name": "Helping Hands", "location": "Hyderabad", "url": "https://maps.google.com?q=Helping+Hands"},
    {"name": "Care & Share", "location": "Bangalore", "url": "https://maps.google.com?q=Care+&+Share"},
    {"name": "Humanity First", "location": "Delhi", "url": "https://maps.google.com?q=Humanity+First"},
  ];

  final List<Map<String, String>> recommendedNgos = [
    {"name": "Hope Foundation", "location": "Hyderabad", "url": "https://maps.google.com?q=Hope+Foundation"},
    {"name": "Safe Haven", "location": "Hyderabad", "url": "https://maps.google.com?q=Safe+Haven"},
    {"name": "Seva Trust", "location": "Hyderabad", "url": "https://maps.google.com?q=Seva+Trust"},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> ngosToDisplay = _isRecommendedSelected ? recommendedNgos : allNgos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "NGOs & Orphanages",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRecommendedSelected = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecommendedSelected ? Color(0xFF003366) : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Recommended'),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRecommendedSelected = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isRecommendedSelected ? Color(0xFF003366) : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ngosToDisplay.length,
          itemBuilder: (context, index) {
            var ngo = ngosToDisplay[index];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.blue[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.verified, color: Colors.green),
                title: Text(
                  ngo["name"]!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.red, size: 18),
                    SizedBox(width: 5),
                    Text(ngo["location"]!),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NgoDetailScreen(
                        name: ngo["name"]!,
                        location: ngo["location"]!,
                        url: ngo["url"]!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
