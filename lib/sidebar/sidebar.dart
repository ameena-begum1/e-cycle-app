import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_cycle/sidebar/gamification.dart';
import 'package:e_cycle/usersScreens/my_posts.dart';
import 'package:e_cycle/sidebar/wishlist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_cycle/Authentication/signin_screen.dart';
import 'package:e_cycle/roleRegistration/join_us_as.dart';
import 'package:e_cycle/usersScreens/notification_screen.dart';
import 'package:e_cycle/sidebar/settings.dart';
import 'package:e_cycle/sidebar/aboutdevelopers.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userName = "Loading...";
  String userEmail = "No Email";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "No Email";
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "User";
        });
      }
    }
  }

//function for user profile
  Widget _buildProfilePicture() {
    User? user = _auth.currentUser;
    if (user != null && user.photoURL != null) {
      // If user has a profile picture from Google, show it
      return ClipOval(
        child: Image.network(user.photoURL!, fit: BoxFit.cover),
      );
    } else {
      // If no profile picture, show the first letter of their name
      String initials = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
      return CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(
          initials,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: TextStyle(color: Colors.white)),
            accountEmail:
                Text(userEmail, style: TextStyle(color: Colors.white)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: _buildProfilePicture(),
            ),
            decoration: BoxDecoration(color: Color.fromARGB(255, 7, 57, 106)),
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: Colors.green),
            title: Text('ई-Coins', style: TextStyle(color: Colors.black)),
            subtitle: Text('100', style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Gamification()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.redAccent),
            title: Text('Wishlist/Saved Items',
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WishlistScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.brown),
            title: Text('Notifications', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag,
                color: Color.fromARGB(255, 128, 128, 0)),
            title: Text('My Posts', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyPostedItems()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text('Settings', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          Divider(),
          ListTile(
            leading:
                Icon(Icons.group_add, color: Color.fromARGB(255, 255, 215, 0)),
            title: Text('Join Us', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RoleSelectionScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Color.fromARGB(255, 255, 215, 0)),
            title:
                Text('About Developers', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutDevelopers()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.black),
            title: Text('Logout', style: TextStyle(color: Colors.black)),
            onTap: () async {
              await _auth.signOut(); // Ensure user is signed out
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}


