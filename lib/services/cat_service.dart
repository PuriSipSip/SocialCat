import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/cats_model.dart';

class CatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCats(CatsModel cats) async {
    // Create a new document in the 'Cats' collection
    await _firestore.collection('Cats').doc(cats.id).set({
      'id': cats.id,
      'catname': cats.catname,
      'bio': cats.bio,
      'age': cats.age,
      'sex': cats.sex,
      'breed': cats.breed,
      'vaccineDate': cats.vaccineDate,
      'catURL': cats.catURL, // URL ของรูปภาพที่ถูกอัปโหลดแล้ว
      'likes': cats.likes,
      'dislikes': cats.dislikes,
      'personality': cats.personality,
      'favoriteplace': cats.favoriteplace,
      'dailyactivity': cats.dailyactivity,
      'favoritefood': cats.favoritefood,
    });
  }
}
