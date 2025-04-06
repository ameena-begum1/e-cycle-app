import 'package:e_cycle/usersScreens/newsstand.dart';
import 'package:e_cycle/usersScreens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), 
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40, 
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),

          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white,size: 25,),
            tooltip: "Notifications",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ));
            },
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.solidPaperPlane, 
              color: Colors.white, 
              size: 22, 
            ),
            tooltip: "ई-Cycle Newsstand",
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Newsroom(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}

