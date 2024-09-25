import 'package:flutter/material.dart';

class CatProfileCard extends StatelessWidget {
  final String catName;
  final String bio;
  final String catURL;
  final int age;
  final String sex;
  final String breed;
  final String vaccine;

  const CatProfileCard({
    super.key,
    required this.catName,
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
          Image.network(catURL, height: 150, fit: BoxFit.cover),
          const SizedBox(
            height: 10,
          ),
          Text(catName,
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
              _buildInfoIcon(Icons.pets, '$age ปี'),
              _buildInfoIcon(
                  Icons.transgender, sex == 'Male' ? 'เพศผู้' : 'เพศเมีย'),
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
    children: [
      Icon(icon, color: Colors.blue),
      const SizedBox(height: 5),
      Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
    ],
  );
}
