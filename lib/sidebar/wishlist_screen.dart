import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_cycle/usersScreens/buy_product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('wishlist')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            return  Center(child: Column(
              children: [
                SizedBox(height: 50,),
                Image.asset("assets/images/empty_wishlist.png"),
                Text("Your Wishlist is Empty!"),
              ],
            ));
          }

          List<QueryDocumentSnapshot> wishlistItems = snapshot.data.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                var item = wishlistItems[index];
                var data = item.data() as Map<String, dynamic>;

                List<String> productImages = [];
                if (data['image_urls'] is List) {
                  productImages = List<String>.from(data['image_urls']);
                } else if (data['image_urls'] is String) {
                  productImages = [data['image_urls']];
                }

                String imageUrl =
                    productImages.isNotEmpty ? productImages.first : '';

                String heroTag = "${item.id}_$index";
                String state = data['state'] ?? 'Unknown State';
                String city = data['city'] ?? 'Unknown City';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: item.id,
                          productName:
                              data['product_name'] ?? 'Unknown Product',
                          productImages: productImages,
                          productPrice: (data['price'] ?? 0).toString(),
                          productDescription: data['description'] ?? '',
                          sellerName: data['sellerName'] ?? 'Unknown Seller',
                          sellerPhone: data['phone_no'] ?? '',
                          location: "$city, $state",
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  color:
                                      Colors.red[100], 
                                  child: const Center(
                                    child: Icon(
                                      Icons.close, 
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['product_name'] ?? 'Unknown Product',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "₹${(data['price'] ?? 0).toString()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('wishlist')
                                .doc(item.id)
                                .delete();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 50),
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 5),
                              Text(
                                "Remove",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
