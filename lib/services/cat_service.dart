import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cats_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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

  Future<List<CatsModel>> getCats() async {
    // Get the 'Cats' collection
    QuerySnapshot catsSnapshot = await _firestore.collection('Cats').get();

    // Convert the QuerySnapshot to a List of CatsModel
    List<CatsModel> cats = catsSnapshot.docs
        .map((doc) => CatsModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return cats;
  }

  Future<void> updateCats(CatsModel cats, vaccineDate) async {
    // Update the document in the 'Cats' collection
    print("asdasdasd");

    // Format the DateTime to a readable format
    final DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(vaccineDate);
    final Timestamp vaccineTimestamp = Timestamp.fromDate(parsedDate);

    try {
      await _firestore.collection('Cats').doc(cats.id).update({
        'catname': cats.catname,
        'bio': cats.bio,
        'age': cats.age,
        'sex': cats.sex,
        'breed': cats.breed,
        'vaccineDate': vaccineTimestamp,
        'catURL': cats.catURL,
        'likes': cats.likes,
        'dislikes': cats.dislikes,
        'personality': cats.personality,
        'favoriteplace': cats.favoriteplace,
        'dailyactivity': cats.dailyactivity,
        'favoritefood': cats.favoritefood,
      });

      Fluttertoast.showToast(
        msg: 'ข้อมูลถูกอัปเดตแล้ว 😽',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.lightBlueAccent,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'อัปเดตข้อมูลไม่สำเร็จ: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  Future<void> deleteCats(String id) async {
    // Delete the document in the 'Cats' collection
    try {
      await _firestore.collection('Cats').doc(id).delete();

      Fluttertoast.showToast(
        msg: 'แมวถูกลบแล้ว 🙀',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'ลบข้อมูลไม่สำเร็จ: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }
}
