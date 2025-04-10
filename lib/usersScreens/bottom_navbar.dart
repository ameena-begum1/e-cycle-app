import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for UI overlay
import 'package:e_cycle/usersScreens/sell_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, 
      child: Scaffold(
        resizeToAvoidBottomInset: true, 
        body: Center(child: Text("Screen $_selectedIndex")),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        floatingActionButton: CustomFAB(isEnabled: true), 
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0, 
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildNavItem(Icons.home, "Home", 0)),
            Expanded(child: _buildNavItem(Icons.volunteer_activism, "Donate", 1)),
            SizedBox(width: 50), 
            Expanded(child: _buildNavItem(Icons.recycling, "Recycle", 2)),
            Expanded(child: _buildNavItem(Icons.build, "Repair", 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: index == 0 ? const Color(0xFF003366) : Colors.grey, 
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: index == 0 ? const Color.fromARGB(255, 9, 9, 9) : Colors.grey, 
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFAB extends StatelessWidget {
  final bool isEnabled; 

  const CustomFAB({Key? key, this.isEnabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isEnabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellItemScreen()),
              );
            }
          : null, 
      backgroundColor: Colors.white,
      child: Icon(Icons.add, color: isEnabled ? Colors.black : Colors.grey, size: 35),
      shape: CircleBorder(
        side: BorderSide(
          color: isEnabled ? Color(0xFF003366) : Colors.grey,
          width: 5,
        ),
      ),
    );
  }
}
