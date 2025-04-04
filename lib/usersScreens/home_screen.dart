import 'package:e_cycle/sidebar/sidebar.dart';
import 'package:e_cycle/usersScreens/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:e_cycle/usersScreens/donation_screen.dart';
import 'package:e_cycle/usersScreens/recycle.dart';
import 'package:e_cycle/usersScreens/repair_screen.dart';
import 'package:e_cycle/usersScreens/chatbot_screen.dart';
import 'package:e_cycle/usersScreens/search_bar.dart';
import 'package:e_cycle/usersScreens/category_filter.dart';
import 'package:e_cycle/usersScreens/items_for_sale.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? selectedCategory;

  void _onItemTapped(int index) {
    if (index == 0) return; 

    switch (index) {
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EWasteDonationPortal()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RecycleScreen()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RepairScreen()));
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, // Prevent FAB from moving up
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 57, 106),
        iconTheme: IconThemeData(color: Colors.white),
        title: const SearchBarWidget(),
      ),
      drawer: Sidebar(),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  CategoryList(
                    onCategorySelected: (String category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ItemsForSaleWidget(selectedCategory: selectedCategory ?? ''),
                  ),
                ],
              ),
            ),

            // Floating Action Button Positioned Correctly
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChatbotScreen()));
                },
                backgroundColor: Color(0xFF003366),
                child: const Icon(Icons.support_agent, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFAB(), // Ensure this widget is defined
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
