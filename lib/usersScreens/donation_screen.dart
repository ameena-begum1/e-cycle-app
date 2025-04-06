import 'package:e_cycle/usersScreens/donation_form.dart';
import 'package:e_cycle/usersScreens/ngos_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EWasteDonationPortal extends StatefulWidget {
  @override
  _EWasteDonationPortalState createState() => _EWasteDonationPortalState();
}

class _EWasteDonationPortalState extends State<EWasteDonationPortal>
    with SingleTickerProviderStateMixin {
  double donationProgress = 0.75;
  int totalDonations = 318;
  int targetDonations = 500;

  String selectedItem = "";

  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController();

  bool _isFormVisible = false;
  bool _isRecommendedSelected = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: donationProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _productNameController.dispose();
    _productDescController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'E-Waste Donation Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
        backgroundColor: Color(0xFF003366),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.volunteer_activism,
              size: 100,
              color: Colors.red, 
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Give your old electronics a second life – Donate today!",
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  "Donate Your Item",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (_isFormVisible) DonationFormDialog(),
            Divider(),
            NgoSelectionScreen(),
          ],
        ),
      ),
    );
  }
}
