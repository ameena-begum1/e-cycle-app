import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDevelopers extends StatelessWidget {

  
  final List<Map<String, String>> developers = [
    {
      "name": "Mohammadi Fatima",
      "role": "Lead Developer",
      "description":
          "I’m Mohammadi Fatima, Co-Founder & Lead Developer of E-Cycle. Passionate about app development and sustainability, I love creating tech solutions that make a difference.",
      "image": "assets/images/mohammadi_fatima.jpeg",
      "email": "mailto:mohammadifatima1224@gmail.com",
      "linkedin": "https://www.linkedin.com/in/mohammadi-fatima-3aa84b306/"
    },
    {
      "name": "Ameena Begum",
      "role": "Lead Developer",
      "description":
          "I’m Ameena, Co-Founder & Lead Developer of E-Cycle. I focus on building efficient applications that encourage e-waste recycling and a greener digital future.",
      "image": "assets/images/ameena.jpeg",
      "email": "mailto:ameenahsyed2003@gmail.com",
      "linkedin": "https://www.linkedin.com/in/ameena-begum-3a8526315/"
    },
    {
      "name": "Syeda Noor Fatima", 
      "role": "Creative Director & Head of Marketing",
      "description":
          "I’m Syeda Noor Fatima, Co-Founder & Creative Director of E-Cycle. I ensure E-Cycle reaches the right audience—driving awareness, engagement, and sustainability.",
      "image": "assets/images/syeda_noor_fatima.jpeg",
      "email": "mailto:synoorf@gmail.com",
      "linkedin": "http://www.linkedin.com/in/syedanoorfatima"
    },
  ];

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
    backgroundColor: Color(0xFF003366),
    iconTheme: IconThemeData(color: Colors.white), // Makes the back button white
    title: const Text(
      "About Developers",
      style: TextStyle(color: Colors.white),
    ),
  ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading with red heart
            Text.rich(
              TextSpan(
                text: "Co-Founders ई-cycle ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: "❤️",
                    style: TextStyle(color: Color(0xFF003366)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // First Row (2 Cards)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDeveloperCard(developers[0]),
                buildDeveloperCard(developers[1]),
              ],
            ),
            SizedBox(height: 16),

            // Second Row (Single Centered Card)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildDeveloperCard(developers[2])],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeveloperCard(Map<String, String> dev) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 180, // Adjusted width for better fit
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(dev["image"]!),
            ),
            SizedBox(height: 10),
            Text(
              dev["name"]!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              textAlign: TextAlign.center,
            ),
            Text(
              dev["role"]!,
              style: TextStyle(fontSize: 13, color: Colors.green.shade800, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            
            // Scrollable Description
            Container(
              height: 60, // Fixed height for scrolling effect
              child: SingleChildScrollView(
                child: Text(
                  dev["description"]!,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.email, color: Colors.red.shade700),
                  onPressed: () => _launchURL(dev["email"]!),
                ),
                IconButton(
                  icon: Icon(Icons.link, color: Colors.green.shade700),
                  onPressed: () => _launchURL(dev["linkedin"]!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}