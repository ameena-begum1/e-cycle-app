import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:e_cycle/usersScreens/home_screen.dart';

class RecyclerProfileScreen extends StatefulWidget {
  @override
  _RecyclerProfileScreenState createState() => _RecyclerProfileScreenState();
}

class _RecyclerProfileScreenState extends State<RecyclerProfileScreen> {
  final TextEditingController recyclerNameController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController businessAddressController = TextEditingController();
  final TextEditingController materialsRecycledController = TextEditingController();

  Uint8List? _imageBytes;
  File? _imageFile;
  String? _imageUrl;

  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    } else {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null && _imageFile == null) return;

    final String fileName = 'recyclers/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = storage.ref().child(fileName);

    try {
      if (_imageBytes != null) {
        await ref.putData(_imageBytes!);
      } else if (_imageFile != null) {
        await ref.putFile(_imageFile!);
      }
      _imageUrl = await ref.getDownloadURL();
      print("Image uploaded: $_imageUrl");
    } catch (e) {
      print("Image upload failed: $e");
    }
  }

  Future<void> _saveRecyclerData() async {
    try {
      if (_imageBytes != null || _imageFile != null) {
        await _uploadImage();
      }

      await firestore.collection('recycler_fields').add({
        'recycler_name': recyclerNameController.text,
        'license_number': int.tryParse(licenseNumberController.text) ?? 0,
        'business_address': businessAddressController.text,
        'materials_recycled': materialsRecycledController.text,
        'logo_url': _imageUrl,
      });

      print("Recycler Registered Successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recycler Registered Successfully!")),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (error) {
      print("Failed to save Recycler data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save Recycler data: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recycler Registration",style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_imageFile != null ? FileImage(_imageFile!) : null),
                      child: (_imageBytes == null && _imageFile == null)
                          ? Icon(Icons.business, size: 50, color: Colors.grey.shade700)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(label: "Recycler Name *", controller: recyclerNameController),
            CustomTextField(label: "License Number *", controller: licenseNumberController, isNumeric: true),
            CustomTextField(label: "Business Address *", controller: businessAddressController),
            CustomTextField(label: "Materials Recycled *", controller: materialsRecycledController, maxLines: 3),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveRecyclerData,
                child: Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool isNumeric;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.isNumeric = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
