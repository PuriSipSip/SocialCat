import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AreaPage extends StatefulWidget {
  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition =
      const LatLng(13.7791935058, 100.560316259); // Default location (Bangkok)

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied case
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when the user has permanently denied access
      return;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    // Move the camera to the current location
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // No need to call _getCurrentLocation here anymore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AREA',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _getCurrentLocation(); // Get current location after map is created
        },
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 19,
        ),
      ),
    );
  }
}
