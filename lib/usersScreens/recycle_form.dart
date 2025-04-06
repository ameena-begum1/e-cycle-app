import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class RecycleFormScreen extends StatefulWidget {
  @override
  _RecycleFormScreenState createState() => _RecycleFormScreenState();
}

class _RecycleFormScreenState extends State<RecycleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProduct;
  String? _selectedCondition;
  Uint8List? _imageBytes;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<String> productTypes = ['Phone', 'Laptop', 'Battery', 'Other'];
  List<String> productConditions = ['Working', 'Damaged'];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null && _imageFile == null) return null;
    final String fileName = "recycle_images/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      UploadTask uploadTask;
      if (_imageBytes != null) {
        uploadTask = storageRef.putData(_imageBytes!);
      } else {
        uploadTask = storageRef.putFile(_imageFile!);
      }
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("❌ Image upload failed: $e");
      return null;
    }
  }

  Future<void> _submitRecycleForm() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      String? imageUrl = await _uploadImage();
      Map<String, dynamic> formData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'product_type': _selectedProduct ?? '',
        'brand': _brandController.text,
        'condition': _selectedCondition ?? '',
        'location': _locationController.text,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : 'N/A',
        'image_url': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('recycle_form').add(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Recycle Request Submitted Successfully!")),
      );
      Navigator.pop(context);
    } catch (error) {
      print("❌ Failed to submit recycle form: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit recycle form: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white), 
        title: Text(
          'Recycle Form',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          )
                        : (_imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : Icon(Icons.add_a_photo, size: 50, color: Colors.green)),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Full Name *', _nameController),
                _buildTextField('Email Address *', _emailController),
                _buildTextField('Phone Number *', _phoneController),
                _buildDropdownField('Product Type *', productTypes, (value) => _selectedProduct = value),
                _buildTextField('Brand/Model *', _brandController),
                _buildDropdownField('Condition *', productConditions, (value) => _selectedCondition = value),
                _buildTextField('Pickup Location *', _locationController),
                _buildTextField('Additional Notes', _notesController, maxLines: 3),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRecycleForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  ),
                  child: Text("Submit", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.green),
        ),
        items: items.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select an option' : null,
      ),
    );
  }
}
