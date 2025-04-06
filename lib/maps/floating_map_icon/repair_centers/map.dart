import 'package:e_cycle/maps/floating_map_icon/repair_centers/maps_api.dart';
import 'package:e_cycle/reusablewidgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final String product;

  MapScreen({required this.product});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double? userLat, userLon;
  bool isLoading = true;
  List<Map<String, dynamic>> repairCenters = [];
  Map<String, dynamic>? selectedCenter;

  final MapController _mapController = MapController();
  double zoomLevel = 13.0; // Initial zoom level

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLat = position.latitude;
      userLon = position.longitude;

      repairCenters =
          await fetchRepairCenters(userLat!, userLon!, widget.product);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openGoogleMaps(String name, double lat, double lon) async {
    final formattedName = Uri.encodeComponent(name);
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$formattedName&query=$lat,$lon";

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl),
            mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  void _zoomIn() {
    setState(() {
      zoomLevel = (zoomLevel + 1).clamp(5.0, 18.0);
_mapController.move(_mapController.camera.center, zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      zoomLevel = (zoomLevel - 1).clamp(5.0, 18.0);
_mapController.move(_mapController.camera.center, zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Repair Centers",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(255, 31, 107, 36),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userLat == null
              ? Center(
                  child: Text("Failed to get location. Check permissions!"))
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(userLat!, userLon!),
                        initialZoom: zoomLevel,
                        onTap: (_, __) {
                          setState(() {
                            selectedCenter = null; // Hide button when tapping elsewhere
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            // User Location Marker
                            Marker(
                              point: LatLng(userLat!, userLon!),
                              width: 40,
                              height: 40,
                              child: Icon(Icons.my_location,
                                  color: Colors.blue, size: 40),
                            ),
                            // Repair Center Markers
                            for (var center in repairCenters)
                              Marker(
                                point: LatLng(
                                  double.parse(center["lat"]),
                                  double.parse(center["lon"]),
                                ),
                                width: 80,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCenter = center;
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          center["name"],
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Icon(Icons.location_on,
                                          color: Colors.red, size: 40),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Zoom Buttons
                    Positioned(
                      bottom: 100,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "zoomIn",
                            backgroundColor: Colors.white,
                            mini: true,
                            onPressed: _zoomIn,
                            child: Icon(Icons.zoom_in, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: "zoomOut",
                            backgroundColor: Colors.white,
                            mini: true,
                            onPressed: _zoomOut,
                            child: Icon(Icons.zoom_out, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    // Floating Direction Button (Visible when a marker is clicked)
                    if (selectedCenter != null)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: FloatingActionButton.extended(
                          backgroundColor: Colors.green,
                          onPressed: () {
                            _openGoogleMaps(
                              selectedCenter!["name"],
                              double.parse(selectedCenter!["lat"]),
                              double.parse(selectedCenter!["lon"]),
                            );
                          },
                          icon: Icon(Icons.directions, color: Colors.white),
                          label: Text("Get Directions",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
    );
  }
}
