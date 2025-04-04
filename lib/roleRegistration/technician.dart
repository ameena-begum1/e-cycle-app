import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class TechnicianRegistrationScreen extends StatefulWidget {
  @override
  _TechnicianRegistrationScreenState createState() =>
      _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState
    extends State<TechnicianRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController expertiseController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController socialMediaController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName =
          "technician_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref =
          FirebaseStorage.instance.ref().child("technician_images/$fileName");
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      FirebaseFirestore.instance.collection("technician_fields").add({
        "name": nameController.text,
        "registration_number": regNoController.text,
        "mobile_number": mobileController.text,
        "email": emailController.text,
        "expertise": expertiseController.text,
        "address": addressController.text,
        "social_media": socialMediaController.text.isNotEmpty
            ? socialMediaController.text
            : null,
        "profile_image": imageUrl ?? "",
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Technician Registered Successfully!")));

        nameController.clear();
        regNoController.clear();
        mobileController.clear();
        emailController.clear();
        expertiseController.clear();
        addressController.clear();
        socialMediaController.clear();

        setState(() {
          _image = null;
        });

        _formKey.currentState!.reset();
      }).catchError((error) {
        print("Error: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Technician Registration",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      backgroundColor: Colors.grey[200],
                      child: _image == null
                          ? Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(nameController, "Name"),
                _buildTextField(regNoController, "Registration Number"),
                _buildTextField(mobileController, "Mobile Number",
                    keyboardType: TextInputType.phone),
                _buildTextField(emailController, "Email",
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(expertiseController, "Expertise"),
                _buildTextField(addressController, "Address"),
                _buildTextField(
                    socialMediaController, "Social Media Link (Optional)"),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    ),
                    child: Text("Register",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? "Enter $labelText" : null,
      ),
    );
  }
}
