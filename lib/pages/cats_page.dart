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
          style: TextStyle(color: Colors.white),
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
                  catName: catData['catname'],
                  bio: catData['bio'],
                  catURL: catData['catURL'],
                  age: catData['age'],
                  sex: catData['sex'],
                  breed: catData['breed'],
                  vaccine: catData['vaccine'] ?? 'N/A',
                );
              });
        },
      ),
    );
  }
}
