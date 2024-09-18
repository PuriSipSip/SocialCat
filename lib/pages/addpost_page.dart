import 'package:flutter/material.dart';

class AddpostPage extends StatelessWidget {
  const AddpostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: const Center(
        child: Text('Add Post Content'),
      ),
    );
  }
}
