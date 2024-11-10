import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cats_model.dart';
import 'package:flutter_application_1/services/cat_service.dart'; // Assuming you have this service for updating
import 'package:flutter_application_1/components/admin_vaccinedatepicker.dart';
import 'package:intl/intl.dart';

class CatEditPage extends StatefulWidget {
  final CatsModel cat;

  const CatEditPage({super.key, required this.cat});

  @override
  _CatEditPageState createState() => _CatEditPageState();
}

class _CatEditPageState extends State<CatEditPage> {
  final TextEditingController catnameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController likesController = TextEditingController();
  final TextEditingController dislikesController = TextEditingController();
  final TextEditingController personalityController = TextEditingController();
  final TextEditingController favoritePlaceController = TextEditingController();
  final TextEditingController dailyActivityController = TextEditingController();
  final TextEditingController favoriteFoodController = TextEditingController();
  final TextEditingController _vaccineDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    catnameController.text = widget.cat.catname;
    bioController.text = widget.cat.bio;
    sexController.text = widget.cat.sex;
    breedController.text = widget.cat.breed;
    likesController.text = widget.cat.likes;
    dislikesController.text = widget.cat.dislikes;
    personalityController.text = widget.cat.personality;
    favoritePlaceController.text = widget.cat.favoriteplace;
    dailyActivityController.text = widget.cat.dailyactivity;
    favoriteFoodController.text = widget.cat.favoritefood;
    _vaccineDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.cat.vaccineDate.toDate());
  }

  void _saveChanges() async {
    final updatedCat = CatsModel(
      id: widget.cat.id,
      catname: catnameController.text,
      bio: bioController.text,
      age: widget.cat
          .age, // Assuming you don't want to change age here, else add a controller for it
      sex: sexController.text,
      breed: breedController.text,
      vaccineDate: widget.cat
          .vaccineDate, // Assuming you don't want to change the vaccine date here
      catURL: widget.cat.catURL, // Assuming this URL doesn't change
      likes: likesController.text,
      dislikes: dislikesController.text,
      personality: personalityController.text,
      favoriteplace: favoritePlaceController.text,
      dailyactivity: dailyActivityController.text,
      favoritefood: favoriteFoodController.text,
    );
    var vaccineDate = _vaccineDateController.text;
    // Call the update method from CatService
    CatsService catService = CatsService();
    await catService.updateCats(
        updatedCat, vaccineDate); // Update the cat in Firestore
    Navigator.pop(
        context, updatedCat); // Return the updated cat to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Cat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: catnameController,
                decoration: const InputDecoration(labelText: 'Cat Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sexController,
                decoration: const InputDecoration(labelText: 'Sex'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: likesController,
                decoration: const InputDecoration(labelText: 'Likes'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dislikesController,
                decoration: const InputDecoration(labelText: 'Dislikes'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: personalityController,
                decoration: const InputDecoration(labelText: 'Personality'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: favoritePlaceController,
                decoration: const InputDecoration(labelText: 'Favorite Place'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dailyActivityController,
                decoration: const InputDecoration(labelText: 'Daily Activity'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: favoriteFoodController,
                decoration: const InputDecoration(labelText: 'Favorite Food'),
              ),
              const SizedBox(height: 20),
              VaccineDatePicker(controller: _vaccineDateController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
