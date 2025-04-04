import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NgoDonationScreen extends StatefulWidget {
  final String ngoName;

  NgoDonationScreen({required this.ngoName});

  @override
  _NgoDonationScreenState createState() => _NgoDonationScreenState();
}

class _NgoDonationScreenState extends State<NgoDonationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _donationCount = 0;
  bool _hasNewNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    QuerySnapshot snapshot = await _firestore.collection('donations').get();
    setState(() {
      _donationCount = snapshot.docs.length;
      _hasNewNotifications = snapshot.docs.isNotEmpty;
    });
  }

  void _acceptDonation(String donationId) async{
    _firestore
        .collection('donations')
        .doc(donationId)
        .update({'status': 'Accepted'});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("The donor has been informed about the acceptance."),
        backgroundColor: Colors.green,
      ),
    );
       // Delete the request from Firestore
              await FirebaseFirestore.instance
                  .collection('donations')
                  .doc(donationId)
                  .delete();
  }

  void _showRejectionDialog(String donationId) {
    TextEditingController _reasonController = TextEditingController();
    String? _selectedReason;

    List<String> rejectionMessages = [
      "We truly appreciate your generosity, but unfortunately, we are unable to accept donations from distant locations at this time.",
      "Thank you for your kind gesture! However, due to logistical challenges, we are unable to proceed with this donation.",
      "Your support means the world to us! Sadly, we are not accepting this particular item at the moment.",
      "We are deeply grateful for your willingness to help, but due to storage limitations, we are unable to accommodate this donation.",
      "We sincerely appreciate your kindness, but this donation does not align with our current requirements. We hope to accept your contributions in the future!",
      "Thank you for thinking of us! However, we are currently prioritizing other essentials. We truly value your support!"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        title: Text(
          "Rejection Reason",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown for predefined messages
            DropdownButtonFormField<String>(
              isExpanded: true, // Ensures dropdown items don't overflow
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Select a reason...",
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10), // Avoids extra spacing issues
              ),
              items: rejectionMessages.map((message) {
                return DropdownMenuItem(
                  value: message,
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow
                        .ellipsis, // Ensures long text doesn't break UI
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _selectedReason = value;
                _reasonController.text =
                    value!; // Set text field to selected value
              },
            ),

            SizedBox(height: 10),

            // Manual input field for custom reason
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: "Or enter a custom reason...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore.collection('donations').doc(donationId).update({
                'status': 'Rejected',
                'rejection_reason': _reasonController.text.isNotEmpty
                    ? _reasonController.text
                    : "No reason provided.",
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("The donor has been informed about the rejection."),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            "Donations",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Welcome message
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF003366),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome, ${widget.ngoName}!",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Total Donations Received: $_donationCount",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Donation List (Wrap it in Expanded to prevent overflow)
              Expanded(
                child: StreamBuilder(
                  stream: _firestore.collection('donations').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty)
                      return Center(child: Text("No Donations Available"));

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 4,
                          color: Color(0xFFDAE3F3), // Light Blue-Gray
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and product info
                                Text(
                                  "Product: ${data['product_name']}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003366)),
                                ),
                                SizedBox(height: 5),
                                Text(
                                    "Description: ${data['product_description']}"),
                                Text("Condition: ${data['product_condition']}"),
                                Text("Repair Status: ${data['repair_status']}"),
                                Text("Pickup Date: ${data['pickup_date']}"),
                                SizedBox(height: 10),

                                // Product image
                                if (data['image_url'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      data['image_url'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                SizedBox(height: 15),

                                // Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _acceptDonation(doc.id),
                                      icon: Icon(Icons.check,
                                          color: Colors.white),
                                      label: Text("Accept"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showRejectionDialog(doc.id),
                                      icon: Icon(Icons.close,
                                          color: Colors.white),
                                      label: Text("Reject"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
