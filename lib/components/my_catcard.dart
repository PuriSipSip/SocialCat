import 'package:flutter/material.dart';

class CatProfileCard extends StatelessWidget {
  final String catname;
  final String bio;
  final String catURL;
  final int age;
  final String sex;
  final String breed;
  final String vaccine;

  const CatProfileCard({
    super.key,
    required this.catname,
    required this.bio,
    required this.catURL,
    required this.age,
    required this.sex,
    required this.breed,
    required this.vaccine,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              catURL,
              height: 200, // Fixed height
              width: double.infinity, // Full width of the Card
              fit: BoxFit.fill, // Ensure the image covers the width and height
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(catname,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              bio,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoIcon(Icons.cake_rounded, '$age ปี'),
              _buildInfoIcon(Icons.transgender, sex),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoIcon(Icons.pets, breed),
              _buildInfoIcon(Icons.vaccines, vaccine),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// for icon
Widget _buildInfoIcon(IconData icon, String text) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center, // Ensure icon is centered
    children: [
      Icon(icon, color: Colors.blue),
      const SizedBox(height: 5),
      SizedBox(
        width: 80, // Fix width to ensure consistent alignment
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center, // Ensure text is centered within its box
          overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
        ),
      ),
    ],
  );
}
