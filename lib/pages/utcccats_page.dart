import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_imageslider.dart';
import 'package:flutter_application_1/pages/utcccatdetails_page.dart';

class UtcccatsPage extends StatelessWidget {
  UtcccatsPage({super.key});
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTCC CATS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Column(children: [
        const MyImageSlider(), // เรียกใช้งาน MyImageslider component
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('Cats').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }

            // ดึงข้อมูลแมวจาก Firestore และแสดงเฉพาะ catname, bio, และ catURL
            final List<DocumentSnapshot> catsDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: catsDocs.length,
              itemBuilder: (context, index) {
                var data = catsDocs[index].data() as Map<String, dynamic>;

                // ตรวจสอบว่า field catname, bio, catURL ไม่เป็น null
                String catname = data['catname'] ?? 'ไม่มีชื่อ';
                String bio = data['bio'] ?? 'ไม่มีข้อมูล';
                String catURL = data['catURL'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: catURL.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: catURL,
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(
                                    value: 0.5,
                                    color: Colors.grey,
                                    backgroundColor: Colors
                                        .grey, // สีพื้นหลังเมื่อยังไม่ได้โหลด
                                  ),
                                )
                              : const Icon(Icons.pets, size: 80),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catname,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bio,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CatDetailsPage(
                                              catId: catsDocs[index].id),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'ข้อมูลเพิ่มเติม',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.lightBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ))
      ]),
    );
  }
}
