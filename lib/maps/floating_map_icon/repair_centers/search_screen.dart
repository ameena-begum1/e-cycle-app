import 'package:e_cycle/maps/floating_map_icon/repair_centers/maps_api.dart';
import 'package:e_cycle/reusablewidgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:e_cycle/maps/floating_map_icon/repair_centers/map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      throw e;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;

    String userInput = _controller.text.trim().toLowerCase();
    bool isValidSearch = isElectronicItem(userInput);

    if (!isValidSearch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please search for electronic repair centers only!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Position position = await _getCurrentLocation();
      await fetchRepairCenters(position.latitude, position.longitude, userInput);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(product: userInput),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Repair Centers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.greenColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "repair_icon",
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.build, 
                    size: 90,
                    color: AppTheme.greenColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.green[50],
                labelText: 'Enter Gadget Type',
                labelStyle: TextStyle(color: Colors.green[900]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.search, color: AppTheme.greenColor),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () => setState(() {
                          _controller.clear();
                        }),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 25),
            _isLoading
                ? SpinKitWave(
                    color: AppTheme.greenColor,
                    size: 40.0,
                  )
                : ElevatedButton(
                    onPressed: _handleSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

List<String> electronicsKeywords = [
  // Personal Gadgets
  'phone', 'smartphone', 'mobile', 'laptop', 'tablet', 'computer', 'desktop', 
  'smartwatch', 'headphones', 'earphones', 'earbuds', 'bluetooth speaker', 
  'camera', 'dslr', 'webcam', 'fitness tracker',

  // Home Entertainment
  'television', 'tv', 'smart tv', 'gaming console', 'playstation', 'xbox', 
  'nintendo switch', 'soundbar', 'home theater', 'blu-ray player', 'dvd player', 
  'radio', 'set-top box', 'streaming device', 'amazon firestick', 'chromecast', 
  'projector', 'vr headset',

  // Kitchen Appliances
  'microwave', 'oven', 'toaster', 'coffee maker', 'blender', 'food processor', 
  'mixer grinder', 'induction cooktop', 'electric kettle', 'rice cooker', 
  'air fryer', 'refrigerator', 'fridge', 'water purifier', 'dishwasher',

  // Home & Cleaning Appliances
  'air conditioner', 'ac', 'washing machine', 'dryer', 'vacuum cleaner', 
  'air purifier', 'humidifier', 'dehumidifier', 'iron', 'steam iron',

  // Networking & Connectivity
  'router', 'modem', 'wi-fi extender', 'network switch', 'ethernet adapter', 
  'portable hotspot',

  // Office & Productivity
  'printer', 'scanner', 'fax machine', 'photocopier', 'calculator', 
  'electronic whiteboard', 'laminator',

  // Smart Home Devices
  'smart bulb', 'smart plug', 'smart switch', 'smart thermostat', 
  'smart lock', 'smart doorbell', 'security camera', 'cctv', 'robot vacuum',

  // Personal Care & Grooming
  'electric toothbrush', 'hair dryer', 'hair straightener', 'hair curler', 
  'electric shaver', 'trimmer', 'massager', 'heating pad',

  // Miscellaneous
  'power bank', 'usb flash drive', 'external hard drive', 'memory card', 
  'solar charger', 'electric scooter', 'drone', 'walkie talkie', 'e-reader'
];


bool isElectronicItem(String query) {
  String lowerQuery = query.toLowerCase();
  return electronicsKeywords.any((keyword) => lowerQuery.contains(keyword));
}
