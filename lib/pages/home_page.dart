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
            'Post',
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
              ),
            ),
          ]),
      body: Center(
        child: Text(
          "LOGGED IN AS:${user.email}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
