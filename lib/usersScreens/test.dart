import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_cycle/sidebar/sidebar.dart';
import 'package:e_cycle/usersScreens/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:e_cycle/reusablewidgets/app_colors.dart';
import 'package:e_cycle/usersScreens/donation_screen.dart';
import 'package:e_cycle/usersScreens/recycle.dart';
import 'package:e_cycle/usersScreens/repair_screen.dart';
import 'package:e_cycle/usersScreens/chatbot_screen.dart';
import 'package:e_cycle/usersScreens/search_bar.dart';
import 'package:e_cycle/usersScreens/category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? selectedCategory;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => EWasteDonationPortal()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecycleScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => RepairScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.orangeColor,
        title: SearchBarWidget(),
      ),
      drawer: Sidebar(),
      body: Stack(
        children: [
          SafeArea(
          
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  CategoryList(onCategorySelected: (String category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  }),
                ],
              ),
            ),
          ),
          

          /// Floating Chatbot Button - Positioned Above Bottom NavBar
                    Positioned(
            right: 16.0,
            bottom: 10.0,
            child: FloatingActionButton(
              
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotScreen()));
              },
              backgroundColor: AppTheme.orangeColor,
              child: Icon(Icons.support_agent, color: Colors.white, size: 40),
            ),
          ),
          
        ],
      ),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFAB(),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      
      ),
  
    );
    
  }
}