import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // current logged in user
  final user = FirebaseAuth.instance.currentUser!;

  // sing user out method ออกจากระบบ
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // return มาจาก Navigation bar
      appBar: AppBar(
          title: const Text(
            'POST',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          actions: [
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ]),
      body: const Center(
        child: Text('Post Content'),
      ),
    );
  }
}
