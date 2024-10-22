import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/cats_model.dart';
import 'package:intl/intl.dart';

class CatDetailsPage extends StatelessWidget {
  final String catId; // รับ ID ของแมวเป็น parameter เพื่อดึงข้อมูล

  const CatDetailsPage({
    super.key,
    required this.catId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('ข้อมูลเพิ่มเติม'),
          titleTextStyle: const TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Cats').doc(catId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cat details'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Cat not found'));
          }

          // แปลงข้อมูลจาก Firestore Map เป็น CatsModel
          CatsModel cat =
              CatsModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: cat.catURL,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const LinearProgressIndicator(
                    value: 0.5,
                    color: Colors.grey,
                    backgroundColor:
                        Colors.grey, // สีพื้นหลังเมื่อยังไม่ได้โหลด
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Cat name and age
                      Text(
                        cat.catname,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'อายุ ${cat.age} ขวบ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          cat.bio,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Personality Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.pets, color: Colors.lightBlue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Personality',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.personality,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Likes and Dislikes Cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Likes',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 49, 94, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.favorite_rounded,
                                        color: Color.fromRGBO(255, 49, 94, 1)),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.likes,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Dislikes',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 49, 94, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.do_not_touch_rounded,
                                        color: Color.fromRGBO(255, 49, 94, 1)),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.dislikes,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Additional Info Cards
                      InfoCard(
                          icon: Icons.transgender,
                          label: 'Gender',
                          value: cat.sex),
                      const SizedBox(height: 4),
                      InfoCard(
                          icon: Icons.pets, label: 'Breed', value: cat.breed),
                      const SizedBox(height: 4),
                      InfoCard(
                        icon: Icons.sunny,
                        label: 'Daily Activity',
                        value: cat.dailyactivity,
                      ),
                      const SizedBox(height: 4),
                      InfoCard(
                        icon: Icons.set_meal_sharp,
                        label: 'Favorite Food',
                        value: cat.favoritefood,
                      ),
                      const SizedBox(height: 4),
                      InfoCard(
                        icon: Icons.beach_access_rounded,
                        label: 'Favorite Place',
                        value: cat.favoriteplace,
                      ),
                      const SizedBox(height: 4),
                      InfoCard(
                        icon: Icons.date_range,
                        label: 'Vaccine Date',
                        value: DateFormat('dd/MM/yyyy')
                            .format(cat.vaccineDate.toDate()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// component for card format
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue)),
                  Text(
                    value,
                    style: TextStyle(color: Colors.grey[700]),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
