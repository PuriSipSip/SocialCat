import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/admin_selectgender.dart';
import 'package:flutter_application_1/components/admin_vaccinedatepicker.dart';
import 'package:flutter_application_1/components/my_imagepreview.dart';
import 'package:flutter_application_1/components/my_postbutton.dart';
import 'package:flutter_application_1/models/cats_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddCatPage extends StatefulWidget {
  final XFile image;

  const AddCatPage({super.key, required this.image});

  @override
  _AddCatPageState createState() => _AddCatPageState();
}

class _AddCatPageState extends State<AddCatPage> {
  final _formKey = GlobalKey<FormState>(); // เพิ่ม GlobalKey สำหรับ Form
  bool _isLoading = false;
  final TextEditingController _catnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _vaccineDateController = TextEditingController();
  final TextEditingController _likesController = TextEditingController();
  final TextEditingController _dislikesController = TextEditingController();
  final TextEditingController _personalityController = TextEditingController();
  final TextEditingController _favoriteplaceController =
      TextEditingController();
  final TextEditingController _dailyactivityController =
      TextEditingController();
  final TextEditingController _favoritefoodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มข้อมูลแมวในระบบ',
          style: TextStyle(color: Colors.lightBlue),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Form widget
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePreview(imagePath: widget.image.path),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _catnameController, // ใช้ _catnameController สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'ชื่อแมว',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      FontAwesomeIcons.cat,
                      size: 22,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _bioController, //ใช้ bio controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'เรื่องราวโดนย่อ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 22.0),
                    child: Icon(Icons.edit),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _ageController, //ใช้ age controller สณาหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'อายุ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),

              const SizedBox(height: 16),
              SelectGender(
                selectedGender: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _breedController, //ใช้ breed controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'พันธุ์',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: FaIcon(
                      FontAwesomeIcons.tag,
                      size: 22,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              //controller: (), ใช้ _vaccineDateController สำหรับรับค่าจาก VaccineDatePicker
              VaccineDatePicker(controller: _vaccineDateController),

              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _likesController, // ใช้ likes controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'สิ่งที่ชอบ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.favorite_sharp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _dislikesController, // ใช้ dislikes controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'สิ่งที่ไม่ชอบ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.do_not_touch_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _personalityController, // ใช้ personality controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'นิสัยของแมว',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.pest_control_rodent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _favoriteplaceController, // ใช้ favoriteplace controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'สถานที่ชื่นชอบ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.beach_access_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _dailyactivityController, // ใช้ dailyactivity controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'กิจกรรมประจำวัน',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.sunny),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _favoritefoodController, // ใช้ favoritefood controller สำหรับรับค่าจากฟอร์ม
                decoration: InputDecoration(
                  labelText: 'อาหารชื่นชอบ',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.set_meal_sharp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PostButton(
                isLoading: _isLoading,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันเพิ่มข้อมูลแมวในระบบ
  Future<void> _createCat(XFile image) async {
    //check form validation
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบ'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // สร้าง CatsModel object
    CatsModel cat = CatsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      catname: _catnameController.text,
      bio: _bioController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      sex: _selectedGender ?? 'ไม่ทราบ',
      breed: _breedController.text,
      vaccineDate: _vaccineDateController.text.isNotEmpty
          ? DateTime.parse(_vaccineDateController.text)
          : DateTime.now(),
      catURL: widget.image.path,
      likes: _likesController.text,
      dislikes: _dislikesController.text,
      personality: _personalityController.text,
      favoriteplace: _favoriteplaceController.text,
      dailyactivity: _dailyactivityController.text,
      favoritefood: _favoritefoodController.text,
    );

    // เรียกใช้ service เพื่อสร้างข้อมูลแมว
    // CatsService catService = CatService();
    // await catService.createCat(cat);

    setState(() {
      _isLoading = false;
    });

    //กลับไปยังหน้า Home
    Navigator.of(context).pop();
  }
}
