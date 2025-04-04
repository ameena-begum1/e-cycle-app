import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_cycle/usersScreens/buy_product_detail_screen.dart';

class ItemsForSaleWidget extends StatefulWidget {
  final String? selectedCategory;

  const ItemsForSaleWidget({super.key, this.selectedCategory});

  @override
  _ItemsForSaleWidgetState createState() => _ItemsForSaleWidgetState();
}

class _ItemsForSaleWidgetState extends State<ItemsForSaleWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String sellerName = "Unknown user";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          sellerName = userDoc['name'] ?? "User";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Sustainability starts with you – Shop pre-loved electronics!",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 6),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('seller_fields')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child:
                        CircularProgressIndicator(color: Colors.blue.shade900));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No items available for sale.'));
              }

              var items = snapshot.data!.docs;
              if (widget.selectedCategory != null &&
                  widget.selectedCategory!.isNotEmpty) {
                items = items.where((item) {
                  var data = item.data() as Map<String, dynamic>;
                  return data['category'] == widget.selectedCategory;
                }).toList();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  var data = item.data() as Map<String, dynamic>;
                  String sellerId =
                      data['userId'] ?? ''; // Fetch seller's userId

                  List<String> productImages = [];
                  if (data['image_urls'] is List) {
                    productImages = List<String>.from(data['image_urls']);
                  } else if (data['image_urls'] is String) {
                    productImages = [data['image_urls']];
                  }

                  String imageUrl = productImages.isNotEmpty
                      ? productImages.first
                      : 'https://via.placeholder.com/150';

                  String state = data['state'] ?? 'Unknown State';
                  String city = data['city'] ?? 'Unknown City';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(sellerId)
                        .get(),
                    builder: (context, sellerSnapshot) {
                      String sellerName = "Unknown Seller";
                      if (sellerSnapshot.connectionState ==
                              ConnectionState.done &&
                          sellerSnapshot.hasData &&
                          sellerSnapshot.data!.exists) {
                        sellerName =
                            sellerSnapshot.data!['name'] ?? "Unknown Seller";
                      }
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
                                sellerName: sellerName,
                                sellerPhone: data['phone_no'] ?? '',
                                location: "$city, $state",
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    headers: const {
                                      "Access-Control-Allow-Origin": "*"
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.blue.shade900,
                                      ));
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                          'assets/images/placeholder.png');
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['product_name'] ?? 'Unknown Product',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '₹${data['price'] ?? '0'}',
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.blueAccent, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '$state → ${city.length > 9 ? city.substring(0, 9) + "…" : city}',
                                            style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
