import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      "linkedin": "https://www.linkedin.com/in/mohammadi-fatima-3aa84b306/",
    },
    {
      "name": "Ameena Begum",
      "role": "Lead Developer",
      "description":
          "I’m Ameena, Co-Founder & Lead Developer of E-Cycle. I focus on building efficient applications that encourage e-waste recycling and a greener digital future.",
      "image": "assets/images/ameena.jpeg",
      "email": "mailto:ameenahsyed2003@gmail.com",
      "linkedin": "https://www.linkedin.com/in/ameena-begum-3a8526315/",
    },
    {
      "name": "Syeda Noor Fatima",
      "role": "Creative Director & Head of Marketing",
      "description":
          "I’m Syeda Noor Fatima, Co-Founder & Creative Director of E-Cycle. I ensure E-Cycle reaches the right audience—driving awareness, engagement, and sustainability.",
      "image": "assets/images/syeda_noor_fatima.jpeg",
      "email": "mailto:synoorf@gmail.com",
      "linkedin": "http://www.linkedin.com/in/syedanoorfatima",
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 16 + 16 padding + spacing
    final cardHeight = 300.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF003366),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "About Developers",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: "Co-Founders ई-cycle ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "❤️",
                    style: TextStyle(color: Color(0xFF003366)),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildDeveloperCard(developers[0], cardWidth, cardHeight),
                buildDeveloperCard(developers[1], cardWidth, cardHeight),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDeveloperCard(developers[2], cardWidth, cardHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeveloperCard(
    Map<String, String> dev,
    double width,
    double height,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(dev["image"]!),
            ),
            SizedBox(height: 10),
            Text(
              dev["name"]!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              dev["role"]!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  dev["description"]!,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.at,
                    color: Colors.red.shade700,
                  ),
                  onPressed: () => _launchURL(dev["email"]!),
                ),

                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.linkedin,
                    color: Colors.blue[700],
                  ),
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
