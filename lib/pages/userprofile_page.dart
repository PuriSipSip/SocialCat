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
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
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
            return Column(
              children: [
                Text(user['email']),
                Text(user['username']),
              ],
            );
          } else {
            return const Text("No user data available");
          }
        },
      ),
    );
  }
}
