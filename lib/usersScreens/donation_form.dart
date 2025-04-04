 import 'dart:typed_data';
import 'package:e_cycle/backend_files/donation_form_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DonationFormDialog extends StatefulWidget {
  @override
  _DonationFormDialogState createState() => _DonationFormDialogState();
}

class _DonationFormDialogState extends State<DonationFormDialog> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();

  String? _productCondition;
  String? _repairStatus;
  DateTime? _pickupDate;
  String? _selectedNgoOrphanage;
  bool _isSubmitting = false;
  Uint8List? _selectedImage;

  final List<String> _ngoOrphanages = ["NGO A", "NGO B", "NGO C"];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  Future<void> _selectPickupDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _pickupDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitDonationForm() async {
  if (_productNameController.text.isEmpty ||
      _productDescController.text.isEmpty ||
      _productCondition == null ||
      _repairStatus == null ||
      _pickupDate == null ||
      _selectedNgoOrphanage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all required fields!")),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  await DonationBackend().submitDonation(
    productName: _productNameController.text,
    productDesc: _productDescController.text,
    productCondition: _productCondition!,
    repairStatus: _repairStatus!,
    pickupDate: _pickupDate!,
    ngo: _selectedNgoOrphanage!,
    imageBytes: _selectedImage,
  );

  setState(() {
    _isSubmitting = false;
    _productNameController.clear();
    _productDescController.clear();
    _productCondition = null;
    _repairStatus = null;
    _pickupDate = null;
    _selectedNgoOrphanage = null;
    _selectedImage = null;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Donation submitted successfully!")),
  );
}


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF003366), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF003366), width: 2),
                    ),
                    child: _selectedImage == null
                        ? Center(child: Text("Tap to upload an image"))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _productNameController,
                  decoration: _inputDecoration('Product Name *'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _productDescController,
                  decoration: _inputDecoration('Product Description *'),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                Text("Product Condition *", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: ["New", "Old"].map((condition) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: condition,
                          groupValue: _productCondition,
                          onChanged: (value) => setState(() => _productCondition = value),
                        ),
                        Text(condition),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                Text("Repair Status *", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: ["Yes", "No"].map((status) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: status,
                          groupValue: _repairStatus,
                          onChanged: (value) => setState(() => _repairStatus = value),
                        ),
                        Text(status),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                Container(
  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.blue[900]!, width: 1.5),
    borderRadius: BorderRadius.circular(8),
    color: Colors.white, 
  ),
  child: TextButton(
    onPressed: _selectPickupDate,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero, // Removes extra padding
      alignment: Alignment.centerLeft, // Align text to the left
    ),
    child: Text(
      _pickupDate == null
          ? "Choose Date & Time"
          : DateFormat('yyyy-MM-dd HH:mm').format(_pickupDate!),
      style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
    ),
  ),
),


                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedNgoOrphanage,
                  items: _ngoOrphanages.map((ngo) {
                    return DropdownMenuItem<String>(
                      value: ngo,
                      child: Text(ngo),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedNgoOrphanage = value),
                  decoration: _inputDecoration("Choose an NGO"),
                ),
                SizedBox(height: 12),
                _isSubmitting
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitDonationForm,
                        child: Text("Submit Donation"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF003366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
