import 'package:flutter/material.dart';


class CategoryList extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryList({super.key, required this.onCategorySelected});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String selectedCategory = 'All'; // ✅ Default to "All"

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.category}, // 🔹 "All" category
    {'name': 'Smartphones', 'icon': Icons.phone_android},
    {'name': 'Laptops', 'icon': Icons.laptop},
    {'name': 'Tablets', 'icon': Icons.tablet_mac},
    {'name': 'Televisions', 'icon': Icons.tv},
    {'name': 'Refrigerators', 'icon': Icons.kitchen},
    {'name': 'Washing Machines', 'icon': Icons.local_laundry_service},
    {'name': 'Air Conditioners', 'icon': Icons.ac_unit},
    {'name': 'Speakers & Headphones', 'icon': Icons.headset},
    {'name': 'Gaming Consoles', 'icon': Icons.sports_esports},
    {'name': 'Cameras & Accessories', 'icon': Icons.camera_alt},
    {'name': 'Others', 'icon': Icons.data_object},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCategorySelected(''); // ✅ Ensures this runs after build
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((category) {
          bool isSelected = category['name'] == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
              });
              widget.onCategorySelected(selectedCategory == 'All' ? '' : selectedCategory);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isSelected ? 35 : 30, // ✅ Bigger icon when selected
                    backgroundColor: isSelected ? Color.fromARGB(255, 7, 57, 106) : Color.fromARGB(255, 6, 78, 150),
                    child: Icon(
                      category['icon'],
                      size: isSelected ? 40 : 30, // ✅ Bigger icon when selected
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 35,
                    child: Text(
                      category['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
