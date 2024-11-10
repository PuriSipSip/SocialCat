import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cats_model.dart';
import 'package:flutter_application_1/services/cat_service.dart';
import 'package:flutter_application_1/pages/cat_edit_page.dart';

class EditAndDeleteCatPage extends StatefulWidget {
  const EditAndDeleteCatPage({super.key});

  @override
  _EditAndDeletePostPageState createState() => _EditAndDeletePostPageState();
}

class _EditAndDeletePostPageState extends State<EditAndDeleteCatPage> {
  final CatsService catsService = CatsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit or Delete Cats',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Cats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final snap = snapshot.data!.docs[index];
              final cat =
                  CatsModel.fromMap(snap.data() as Map<String, dynamic>);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(cat.catURL),
                  ),
                  title: Text(cat.catname),
                  subtitle: Text(cat.bio),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CatEditPage(cat: cat),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await catsService.deleteCats(cat.id);
                          setState(() {}); // Refresh the list
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
