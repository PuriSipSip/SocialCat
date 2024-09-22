import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserprofilePage extends StatelessWidget {
  UserprofilePage({super.key});

  // current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetail() async {
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser?.email)
          .get();
    } else {
      throw Exception("No user is logged in");
    }
  }

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // UserProfile UI Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              onPressed: signUserOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetail(),
        builder: (context, snapshot) {
          // loading..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // error
          else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData && snapshot.data?.data() != null) {
            Map<String, dynamic> user = snapshot.data!.data()!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.grey[200],
                      ),
                      Positioned(
                        top: 10,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user['photoURL']),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user['username'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user['bio'] ?? 'Loves Cats!',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return const Text("No user data available");
          }
        },
      ),
    );
  }
}
