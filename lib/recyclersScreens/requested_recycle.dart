import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecyclerRequestsScreen extends StatefulWidget {
  @override
  _RecyclerRequestsScreenState createState() => _RecyclerRequestsScreenState();
}

class _RecyclerRequestsScreenState extends State<RecyclerRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchRequestsCount();
  }

  Future<void> _fetchRequestsCount() async {
    QuerySnapshot snapshot = await _firestore.collection('recycle_form').get();
    setState(() {
      _requestCount = snapshot.docs.length;
    });
  }

  void _acceptRequest(BuildContext context, String requestId) async {
    // Pick a date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: ColorScheme.light(primary: Colors.green),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // Pick a time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // Combine date and time
    DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Show loading indicator while updating Firebase
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Scheduling pickup..."),
          ],
        ),
      ),
    );

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('recycle_form')
        .doc(requestId)
        .update({
      'status': 'Accepted',
      'pickup_time': selectedDateTime.toIso8601String(),
    });

    // Close loading dialog
    Navigator.pop(context);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Pickup Scheduled",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(
              "Recycler has been informed. Pickup is scheduled on:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat('EEE, MMM d, y – hh:mm a').format(selectedDateTime),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Delete the request from Firestore
              await FirebaseFirestore.instance
                  .collection('recycle_form')
                  .doc(requestId)
                  .delete();

              // Optional: Show a snackbar for feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Happy Recycling :)")),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF003366),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "OK",
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, String requestId) {
    TextEditingController _reasonController = TextEditingController();
    String? _selectedReason;

    List<String> rejectionMessages = [
      "We appreciate your effort to recycle, but we currently do not accept this type of item.",
      "Thank you for your request! Unfortunately, we are unable to process this material at the moment.",
      "Due to transportation constraints, we are unable to collect from your location.",
      "We are currently prioritizing other recyclable materials. Please check back later.",
      "The item does not meet our recycling criteria. Please consider other disposal options.",
      "We truly appreciate your commitment to sustainability! However, this item is not suitable for our recycling process."
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              "Rejection Reason",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: "Select a reason...",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: rejectionMessages.map((message) {
                  return DropdownMenuItem(
                    value: message,
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  _selectedReason = value;
                  _reasonController.text = value!;
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: "Or enter a custom reason...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 3,
              ),
            ],
          ),
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
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('recycle_form')
                  .doc(requestId)
                  .update({
                'status': 'Rejected',
                'rejection_reason': _reasonController.text.isNotEmpty
                    ? _reasonController.text
                    : "No reason provided.",
              });

              await FirebaseFirestore.instance
                  .collection('recycle_form')
                  .doc(requestId)
                  .delete();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "The recycler has been informed about the rejection."),
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
        title: Text("Recycle requests",
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF003366),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Recycling Center Logo (Placeholder) & Name
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300], // Light grey placeholder
                  child:
                      Icon(Icons.recycling, size: 40, color: Color(0xFF003366)),
                ),
                SizedBox(height: 8),
                Text(
                  "Green Earth Recycling Center",
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Spacing before total requests

            // Summary Section
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
                    "Total Requests Received: $_requestCount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Requests List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('recycle_form')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(
                        child: Text("No requests available",
                            style: TextStyle(fontSize: 16)));

                  return ListView(
                    children: snapshot.data!.docs
                        .map((doc) => _buildRecyclerCard(doc))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecyclerCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      color: Color(0xFFDAE3F3), // Light Blue-Gray
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (data['image_url'] != null && data['image_url']!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(data['image_url']!,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            SizedBox(height: 12),

            // Product & User Info
            Text("${data['product_type']} - ${data['brand']}",
                style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366))),
            Text("Condition: ${data['condition']}",
                style: TextStyle(color: Colors.grey[700])),
            Divider(),
            Text("User: ${data['name']}", style: TextStyle(fontSize: 16)),
            Text("Location: ${data['location']}"),
            Text("Phone: ${data['phone']}"),
            SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _acceptRequest(context, doc.id),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRejectionDialog(
                      context, doc.id), // Fixed function call
                  icon: Icon(Icons.close, color: Colors.white),
                  label: Text("Reject"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
