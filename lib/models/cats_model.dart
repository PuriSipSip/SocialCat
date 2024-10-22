/*
  อธิบายโครงสร้าง
  - id: Unique ไอดีของแมว (String)
  - catname: ชื่อของแมว (String)
  - bio: ประวัติหรือข้อมูลเบื้องต้นของแมว (String)
  - sex: เพศของแมว (String)
  - breed: สายพันธุ์ของแมว (String)
  - vaccineDate: วันที่ฉีดวัคซีน (Timestamp)
  - catURL: URL ของภาพของแมว (String)
  - likes: สิ่งที่แมวชอบ (String)
  - dislikes: สิ่งที่แมวไม่ชอบ (String)
  - personality: นิสัยของแมว (String)
  - favoriteplace: สถานที่โปรดของแมว (String)
  - dailyactivity: กิจกรรมประจำวันของแมว (String)
  - favoritefood: อาหารโปรดของแมว (String)
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class CatsModel {
  String id; // Unique ID for each cat (could be linked to QR code )
  String catname;
  String bio;
  int age;
  String sex; // Cat's gender (Male/Female)
  String breed;
  Timestamp vaccineDate;
  String catURL; // URL of the cat's image
  String likes;
  String dislikes;
  String personality;
  String favoriteplace;
  String dailyactivity;
  String favoritefood;

  CatsModel(
      {required this.id,
      required this.catname,
      required this.bio,
      required this.age,
      required this.sex,
      required this.breed,
      required this.vaccineDate,
      required this.catURL,
      required this.likes,
      required this.dislikes,
      required this.personality,
      required this.favoriteplace,
      required this.dailyactivity,
      required this.favoritefood});

  // แปลงข้อมูลจาก Map ที่ดึงมาจาก FireStore ให้เป็น Object
  factory CatsModel.fromMap(Map<String, dynamic> data) {
    return CatsModel(
        id: data['id'],
        catname: data['catname'],
        bio: data['bio'],
        age: data['age'],
        sex: data['sex'],
        breed: data['breed'],
        vaccineDate: data['vaccineDate'] as Timestamp,
        catURL: data['catURL'],
        likes: data['likes'],
        dislikes: data['dislikes'],
        personality: data['personality'],
        favoriteplace: data['favoriteplace'],
        dailyactivity: data['dailyactivity'],
        favoritefood: data['favoritefood']);
  }

  // แปลงข้อมูลจาก Object ที่ได้จาก FireStore ให้เป็น Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catname': catname,
      'bio': bio,
      'age': age,
      'sex': sex,
      'breed': breed,
      'vaccine': vaccineDate,
      'catURL': catURL,
      'likes': likes,
      'dislikes': dislikes,
      'personality': personality,
      'favoriteplace': favoriteplace,
      'dailyactivity': dailyactivity,
      'favoritefood': favoritefood
    };
  }
}
