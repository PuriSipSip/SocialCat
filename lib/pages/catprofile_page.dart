import 'package:flutter/material.dart';

class CatprofilePage extends StatelessWidget {
  const CatprofilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTCC Cats'),
      ),
      body: const Center(
        child: Text('UTCC Cats Page Content'),
      ),
    );
  }
}
