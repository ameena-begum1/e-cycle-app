import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:e_cycle/usersScreens/home_screen.dart';

class NGOProfileScreen extends StatefulWidget {
  @override
  _NGOProfileScreenState createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController ngoNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();

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

    final String fileName = 'ngos/${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  Future<void> _saveNGOData() async {
    if (!_formKey.currentState!.validate()) {
      print("Validation failed.");
      return;
    }

    try {
      if (_imageBytes != null || _imageFile != null) {
        await _uploadImage();
      }

      await firestore.collection('ngo_fields').add({
        'ngo_name': ngoNameController.text,
        'registration_number': registrationNumberController.text,
        'mobile_number': mobileNumberController.text,
        'email': emailController.text,
        'description': descriptionController.text,
        'address': addressController.text,
        'social_media': socialMediaController.text.isNotEmpty ? socialMediaController.text : null,
        'logo_url': _imageUrl,
      });

      print("NGO Registered Successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("NGO Registered Successfully!")),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (error) {
      print("Failed to save NGO data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save NGO data: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NGO Registration",style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(label: "NGO Name *", controller: ngoNameController),
              CustomTextField(
                label: "Registration Number *",
                controller: registrationNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d+$').hasMatch(value)) {
                    return "Enter a valid Registration Number";
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: "Mobile Number *",
                controller: mobileNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit Mobile Number";
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: "Email *",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return "Enter a valid Email Address";
                  }
                  return null;
                },
              ),
              CustomTextField(label: "Description *", controller: descriptionController, maxLines: 3),
              CustomTextField(label: "Address *", controller: addressController),
              CustomTextField(label: "Social Media Link", controller: socialMediaController),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveNGOData,
                  child: Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
