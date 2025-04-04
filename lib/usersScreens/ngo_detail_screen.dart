
import 'package:e_cycle/usersScreens/donation_form.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NgoDetailScreen extends StatelessWidget {
  final String name;
  final String location;
  final String url;

  const NgoDetailScreen(
      {required this.name, required this.location, required this.url, Key? key})
      : super(key: key);

  Future<void> _launchMaps() async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open the URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon:
                      Icon(Icons.location_pin, color: Colors.blue, size: 30),
                  onPressed: _launchMaps,
                ),
                SizedBox(width: 5),
                Text(location,
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "About $name",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              "$name is committed to making a difference in the community through various initiatives. It works towards education, healthcare, and social empowerment, ensuring a better future for the underprivileged.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(body:DonationFormDialog())));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: Text("Donate Now",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
