import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final List<String> productImages;
  final String productPrice;
  final String productDescription;
  final String sellerName;
  final String sellerPhone;
  final String location;

  ProductDetailScreen({
    required this.productId,
    required this.productName,
    required this.productImages,
    required this.productPrice,
    required this.productDescription,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();

//chat functionality to open whatsapp chat
Future<void> _openWhatsAppChat(String phoneNumber) async {
  String formattedNumber = phoneNumber.trim();
  if (!formattedNumber.startsWith("91")) {
    formattedNumber = "91$formattedNumber"; 
  }
String message = Uri.encodeComponent("Hello, I am interested in buying '${widget.productName}', posted on ई-cycle app. Is it still available?");
  
  final Uri url = Uri.parse('https://wa.me/$formattedNumber?text=$message');

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    print('Could not launch $url');
  }
}



//wishlist functionality
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 void _addToWishlist() async {
  try {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in first"), backgroundColor: Colors.red),
      );
      return;
    }

    String userId = _auth.currentUser!.uid;

    // Check if the item is already in the wishlist
    var doc = await _firestore
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: widget.productId)
        .get();

    if (doc.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already in Wishlist!"), backgroundColor: Colors.orange),
      );
      return;
    }

    // Add item if not already present
  await _firestore.collection('wishlist').add({
  'userId': userId,
  'productId': widget.productId,
  'product_name': widget.productName,
  'image_urls': widget.productImages,
  'price': widget.productPrice,
  'sellerName': widget.sellerName,
  'sellerPhone': widget.sellerPhone,
  'description': widget.productDescription,
  'state': widget.location, // add state and city at once
  'timestamp': FieldValue.serverTimestamp(),
});


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added to Wishlist!"), backgroundColor: Colors.green),
    );
  } catch (e) {
    print("Error adding to wishlist: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add to Wishlist"), backgroundColor: Colors.red),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Product Details',
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
            Container(
              height: 250,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.productImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageView(
                            images: widget.productImages,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.productImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.productImages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.blue[900]!,
                  dotColor: Colors.blue[300]!,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.productName,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 8),
            Text('Price: ₹ ${widget.productPrice}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[900])),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.productDescription,
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800], size: 24),
                SizedBox(width: 5),
                Text(
                  'Location: ${widget.location}',
                  style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                ),
              ],
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Seller: ',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.sellerName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsAppChat(widget.sellerPhone),
                    icon: Icon(Icons.chat, size: 20, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text('Chat', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: _addToWishlist,
                    icon:
                        Icon(Icons.shopping_bag, size: 20, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003366),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text('Wishlist', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  FullScreenImageView({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("View Image", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
