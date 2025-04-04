import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegisterVolunteerScreen extends StatefulWidget {
  @override
  _RegisterVolunteerScreenState createState() => _RegisterVolunteerScreenState();
}

class _RegisterVolunteerScreenState extends State<RegisterVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController availabilityController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = "";
      
      if (_imageFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child("volunteers/$fileName.jpg");
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('volunteers').add({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'skills': skillsController.text,
        'availability': availabilityController.text,
        'profilePic': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered Successfully!"),backgroundColor: Colors.green,));

      _formKey.currentState!.reset();
      setState(() {
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register as Volunteer",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,// Grey Circular Avatar
                    child: _imageFile == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade700)
                        : ClipOval(
                            child: Image.file(_imageFile!, fit: BoxFit.cover, width: 120, height: 120),
                          ),
                  ),
                ),
                SizedBox(height: 20),

                // Name Field
                _buildTextField(nameController, "Full Name", Icons.person),

                // Email Field
                _buildTextField(emailController, "Email", Icons.email, isEmail: true),

                // Phone Field
                _buildTextField(phoneController, "Phone Number", Icons.phone, isPhone: true),

                // Address Field
                _buildTextField(addressController, "Address", Icons.location_on),

                // Skills Field
                _buildTextField(skillsController, "Skills", Icons.build),

                // Availability Field
                _buildTextField(availabilityController, "Availability", Icons.schedule),

                SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.yellow[700]),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey), // Grey border for fields
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: const Color.fromARGB(255, 255, 193, 35), width: 2), // Yellow border on focus
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter $label";
          if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return "Enter valid email";
          if (isPhone && value.length < 10) return "Enter valid phone number";
          return null;
        },
      ),
    );
  }
}
