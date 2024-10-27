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
  final LatLng _utccCenter =
      const LatLng(13.7768, 100.5592); // พิกัดศูนย์กลางของ UTCC
  Set<Marker> _allMarkers = {};
  Set<Marker> _filteredMarkers = {};
  String _currentFilter = 'today';

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  Future<void> _initializeMarkers() async {
    await _loadMarkers();
    if (mounted) {
      setState(() {
        _currentFilter = 'today';
      });
      _filterMarkers('today');
    }
  }

  // โหลดข้อมูลหมุดทั้งหมดจาก Firestore
  Future<void> _loadMarkers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Posts').get();

    for (var doc in querySnapshot.docs) {
      await _createMarkerFromDocument(doc);
    }
    _filterMarkers('all');
  }

  // สร้างหมุดจากข้อมูลเอกสาร Firestore
  Future<void> _createMarkerFromDocument(DocumentSnapshot doc) async {
    GeoPoint geoPoint = doc['location'];
    String imageUrl = doc['imageURL'];
    String catName = doc['catname'] ?? 'Unknown Cat';

    try {
      final BitmapDescriptor markerIcon =
          await _createCustomMarkerImageFromUrl(imageUrl, catName);

      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        icon: markerIcon,
        onTap: () => _showPostDetails(doc),
      );

      setState(() {
        _allMarkers.add(marker);
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการสร้างหมุดสำหรับ ${doc.id}: $e');
    }
  }

  // กรองหมุดตามช่วงเวลาที่กำหนด
  Future<void> _filterMarkers(String filter) async {
    setState(() {
      _currentFilter = filter;
    });

    Set<Marker> newFilteredMarkers = {};
    DateTime now = DateTime.now();

    for (var marker in _allMarkers) {
      DocumentSnapshot? docSnapshot =
          await _getDocumentFromMarkerId(marker.markerId.value);
      if (docSnapshot != null && docSnapshot.exists) {
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('timestamp')) {
          Timestamp timestamp = data['timestamp'];
          DateTime postDate = timestamp.toDate();
          Duration difference = now.difference(postDate);

          bool shouldInclude = _shouldIncludeMarker(filter, difference);

          if (shouldInclude) {
            newFilteredMarkers.add(marker);
          }
        }
      }
    }

    setState(() {
      _filteredMarkers = newFilteredMarkers;
    });
  }

  // ตรวจสอบว่าควรรวมหมุดในการกรองหรือไม่
  bool _shouldIncludeMarker(String filter, Duration difference) {
    switch (filter) {
      case 'today':
        return difference.inDays == 0;
      case 'threeDays':
        return difference.inDays <= 2;
      case 'all':
        return true;
      default:
        return false;
    }
  }

  // ดึงข้อมูลเอกสารจาก Firestore โดยใช้ markerId
  Future<DocumentSnapshot?> _getDocumentFromMarkerId(String markerId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('Posts')
          .doc(markerId)
          .get();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงเอกสาร: $e');
      return null;
    }
  }

  // สร้างไอคอนหมุดแบบกำหนดเองจาก URL รูปภาพ
  Future<BitmapDescriptor> _createCustomMarkerImageFromUrl(
      String url, String catName) async {
    final int size = 150;
    final int imageSize = 120;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final Paint bgPaint = Paint()..color = Colors.black;

    // วาดเงาและพื้นหลัง
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, shadowPaint);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 3, bgPaint);

    // โหลดและวาดรูปภาพ
    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List imageData = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(imageData,
        targetWidth: imageSize, targetHeight: imageSize);
    final ui.FrameInfo fi = await codec.getNextFrame();

    // ครอบตัดรูปภาพให้เป็นวงกลม
    final Path clipPath = Path();
    clipPath.addOval(Rect.fromLTWH(size / 2 - imageSize / 2,
        size / 2 - imageSize / 2, imageSize.toDouble(), imageSize.toDouble()));
    canvas.clipPath(clipPath);

    canvas.drawImageRect(
      fi.image,
      Rect.fromLTWH(
          0, 0, fi.image.width.toDouble(), fi.image.height.toDouble()),
      Rect.fromLTWH(size / 2 - imageSize / 2, size / 2 - imageSize / 2,
          imageSize.toDouble(), imageSize.toDouble()),
      Paint(),
    );

    // แปลงเป็น BitmapDescriptor
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // แสดงรายละเอียดของโพสต์เมื่อแตะที่หมุด
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
                      _buildUserInfo(doc),
                      SizedBox(height: 10),
                      Text(
                        doc['catname'] ?? 'Unknown Cat',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(doc['description'] ?? 'No description'),
                    ],
                  ),
                ),
                TextButton(
                  child: Text('ปิด'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // สร้างส่วนแสดงข้อมูลผู้ใช้
  Widget _buildUserInfo(DocumentSnapshot doc) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(doc['photoURL'] ?? ''),
          radius: 20,
        ),
        SizedBox(width: 10),
        Text(
          doc['username'] ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'พื้นที่',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          _buildFilterButtons(),
        ],
      ),
    );
  }

  // สร้าง Google Map
  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        controller.setMapStyle(
            '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
      },
      initialCameraPosition: CameraPosition(
        target: _utccCenter,
        zoom: 17,
      ),
      markers: _filteredMarkers,
    );
  }

  // สร้างปุ่มกรอง
  Widget _buildFilterButtons() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton('วันนี้', 'today'),
              _buildFilterButton('3 วัน', 'threeDays'),
              _buildFilterButton('ทั้งหมด', 'all'),
            ],
          ),
        ),
      ),
    );
  }

  // สร้างปุ่มกรองแต่ละปุ่ม
  Widget _buildFilterButton(String label, String filter) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            _currentFilter == filter ? Colors.lightBlue : Colors.grey,
      ),
      child: Text(label),
      onPressed: () => _filterMarkers(filter),
    );
  }
}
