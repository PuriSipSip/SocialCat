import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';

class AreaPage extends StatefulWidget {
  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  late GoogleMapController mapController;
   final LatLng _utccCenter = const LatLng(13.7768, 100.5592); // พิกัดที่ถูกต้องของ UTCC
  Set<Marker> _markers = {};

  // กำหนดขอบเขตของมหาวิทยาลัยหอการค้าไทย
  final LatLngBounds utccBounds = LatLngBounds(
    southwest: const LatLng(13.7748, 100.5572), // ปรับขอบเขตให้ครอบคลุมพื้นที่มหาวิทยาลัย
    northeast: const LatLng(13.7788, 100.5612),
  );

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Posts').get();
    
    for (var doc in querySnapshot.docs) {
      GeoPoint geoPoint = doc['location'];
      String imageUrl = doc['imageURL'];
      String catName = doc['catname'] ?? 'Unknown Cat';
      
      try {
        final BitmapDescriptor markerIcon = await _createCustomMarkerImageFromUrl(imageUrl, catName);
        
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: catName,
              snippet: doc['description'] ?? 'No description',
            ),
            onTap: () => _showPostDetails(doc),
          ));
        });
      } catch (e) {
        print('Error creating marker for ${doc.id}: $e');
        // ใช้ marker แบบ default หากมีข้อผิดพลาด
      }
    }
  }

  
  Future<BitmapDescriptor> _createCustomMarkerImageFromUrl(String url, String catName) async {
    final int size = 150;
    final int imageSize = 120;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final Paint bgPaint = Paint()..color = Colors.black;

    // วาดเงา
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, shadowPaint);

    // วาดพื้นหลังสีดำ
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 3, bgPaint);

    // โหลดและวาดรูปภาพ
    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List imageData = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(imageData, targetWidth: imageSize, targetHeight: imageSize);
    final ui.FrameInfo fi = await codec.getNextFrame();
    
    // คร็อปรูปภาพให้เป็นวงกลม
    final Path clipPath = Path();
    clipPath.addOval(Rect.fromLTWH(size / 2 - imageSize / 2, size / 2 - imageSize / 2, imageSize.toDouble(), imageSize.toDouble()));
    canvas.clipPath(clipPath);

    canvas.drawImageRect(
      fi.image,
      Rect.fromLTWH(0, 0, fi.image.width.toDouble(), fi.image.height.toDouble()),
      Rect.fromLTWH(size / 2 - imageSize / 2, size / 2 - imageSize / 2, imageSize.toDouble(), imageSize.toDouble()),
      Paint(),
    );

    // แปลงเป็น BitmapDescriptor
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  
  void _showPostDetails(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    doc['imageURL'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['catname'] ?? 'Unknown Cat',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(doc['description'] ?? 'No description'),
                    ],
                  ),
                ),
                TextButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AREA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          controller.setMapStyle('[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
          controller.animateCamera(CameraUpdate.newLatLngBounds(utccBounds, 50.0));
        },
        initialCameraPosition: CameraPosition(
          target: _utccCenter,
          zoom: 17,
        ),
        markers: _markers,
        cameraTargetBounds: CameraTargetBounds(utccBounds),
        minMaxZoomPreference: MinMaxZoomPreference(15, 20),
      ),
    );
  }
}
