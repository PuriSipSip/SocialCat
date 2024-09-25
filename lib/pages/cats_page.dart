import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_catcard.dart';

class CatsPage extends StatelessWidget {
  CatsPage({super.key});
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CATS',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder(
        stream: firestore.collection('Cats').snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          final cats = snapshot.data!.docs;
          return ListView.builder(
              itemCount: cats.length,
              itemBuilder: (context, index) {
                var catData = cats[index].data();
                return CatProfileCard(
                  catname: catData['catname'] ?? 'Unknown',
                  bio: catData['bio'] ?? 'No bio available',
                  catURL: catData['catURL'] ??
                      'https://example.com/default-cat-image.jpg',
                  age: catData['age'] ?? 'Unknown age',
                  sex: catData['sex'] ?? 'Unknown sex',
                  breed: catData['breed'] ?? 'Unknown breed',
                  vaccine: catData['vaccine'] ?? 'N/A',
                );
              });
        },
      ),
    );
  }
}
