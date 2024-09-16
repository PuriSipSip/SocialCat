import 'package:flutter/material.dart';

class AllpostPage extends StatelessWidget {
  const AllpostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Post'),
      ),
      body: const Center(
        child: Text('All Post Content'),
      ),
    );
  }
}
