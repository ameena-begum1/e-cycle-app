import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellItemScreen extends StatefulWidget {
  @override
  _SellItemScreenState createState() => _SellItemScreenState();
}

class _SellItemScreenState extends State<SellItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _district = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  String? _selectedState;
  String? _selectedCategory;

  final List<String> _categories = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'Televisions',
    'Refrigerators',
    'Washing Machines',
    'Air Conditioners',
    'Speakers & Headphones',
    'Gaming Consoles',
    'Cameras & Accessories',
    'Others'
  ];

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

//to pick the images
  List<XFile> _images = [];
  final ImagePicker img = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await img.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    if (source == ImageSource.camera) {
      await _pickImage(source);
    } else {
      final pickedFiles = await img.pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _images.addAll(pickedFiles);
        });
      }
    }
  }

//from camera or gallery
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image Source",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.grey[400]),
                title:
                    Text('Take a Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.grey[400]),
                title: Text('Choose from Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

//to deselect the image
  void _deselectImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

//to upload the image to firebase storage
  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) {
      print('No images selected.');
      return [];
    }

    List<String> downloadUrls = [];

    for (var image in _images) {
      try {
        print("Uploading image to Firebase...");

        String uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('seller_images');
        Reference referenceImageToUpload =
            referenceDirImages.child(uniqueFileName);

        UploadTask uploadTask;

        if (kIsWeb) {
          Uint8List bytes = await image.readAsBytes();
          uploadTask = referenceImageToUpload.putData(bytes);
        } else {
          File file = File(image.path);
          uploadTask = referenceImageToUpload.putFile(file);
        }

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        print("Upload successful! Image URL: $downloadUrl");
      } catch (error) {
        print('Error uploading file: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images. Please try again.')),
        );
      }
    }

    return downloadUrls;
  }

//submit data to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _submitItem() async {
    if (_images.isEmpty ||
        _itemNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedState == null ||
        _phonenoController.text.isEmpty ||
        _district.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please fill all fields and upload at least one image!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade900),
            SizedBox(height: 16),
            Text("Please wait, your item is being posted..."),
          ],
        ),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      List<String> imageUrls = await _uploadImages();

      if (imageUrls.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No images were successfully uploaded!')),
        );
        return;
      }

      await firestore.collection('seller_fields').add({
        'userId': user.uid,
        'product_name': _itemNameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'phone_no': _phonenoController.text,
        'state': _selectedState,
        'city': _district.text,
        'image_urls': imageUrls,
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item successfully listed for sale!')),
      );

      _itemNameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _district.clear();
      _phonenoController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedState = null;
        _images.clear();
        _isLoading = false;
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Sell Your Electronics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF003366),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: _images.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey[700]),
                          SizedBox(height: 8),
                          Text('Tap to upload images',
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _images.length) {
                            return GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(Icons.add,
                                      size: 40, color: Colors.white),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onLongPress: () => _deselectImage(index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(_images[index]
                                            .path)), // Ensure it's a File
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: Icon(Icons.remove_circle,
                                        color: Colors.red, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Item Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text('Select Category'),
              items: _categories
                  .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phonenoController,
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Phone no.',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedState,
              hint: Text('Select State'),
              items: _states
                  .map((state) =>
                      DropdownMenuItem(value: state, child: Text(state)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _district,
              decoration: InputDecoration(
                labelText: 'City/District',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003366), // Ashoka Chakra Blue
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sell Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
