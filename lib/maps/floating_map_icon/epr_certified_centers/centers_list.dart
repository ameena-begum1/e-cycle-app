import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EprMapScreen extends StatefulWidget {
  @override
  _EprMapScreenState createState() => _EprMapScreenState();
}

class _EprMapScreenState extends State<EprMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  bool _showDirectionsButton = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRecyclingCenters();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _loadRecyclingCenters() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('recycling_centers').get();

    Set<Marker> newMarkers = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('latitude') &&
          data.containsKey('longitude') &&
          data['latitude'] != null &&
          data['longitude'] != null) {
        double lat = data['latitude'];
        double lng = data['longitude'];

        newMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: data['Company Name'] ?? "Unknown",
              // snippet: "Tap for more details",
            ),
            onTap: () {
              setState(() {
                _selectedLocation = LatLng(lat, lng);
                _showDirectionsButton = true;
              });
            },
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _openGoogleMaps() async {
    if (_selectedLocation != null && _currentLocation != null) {
      String googleUrl =
          "https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${_selectedLocation!.latitude},${_selectedLocation!.longitude}";

      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open Google Maps';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Select a location first or enable GPS!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EPR Recycling Centers",style: TextStyle(fontWeight: FontWeight.bold),),backgroundColor: Colors.green,),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(20.5937, 78.9629),
              zoom: 10,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          Positioned(
            top: 100,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_in, color: Colors.black),
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_out, color: Colors.black),
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),

          if (_showDirectionsButton)
            Positioned(
              top: 20,
              right: 10,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.blue,
                icon: Icon(Icons.directions, color: Colors.white),
                label: Text("Directions"),
                onPressed: _openGoogleMaps,
              ),
            ),
        ],
      ),
    );
  }
}


