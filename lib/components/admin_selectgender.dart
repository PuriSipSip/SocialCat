// Dropdown สำหรับเลือกเพศ
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectGender extends StatelessWidget {
  final String? _selectedGender;
  final Function(String?) onChanged;

  const SelectGender({
    super.key,
    required String? selectedGender,
    required this.onChanged,
  }) : _selectedGender = selectedGender;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'เพศ',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12.0),
          child: FaIcon(
            FontAwesomeIcons.venusMars,
            size: 22,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'เพศผู้',
          child: Text('เพศผู้'),
        ),
        DropdownMenuItem(
          value: 'เพศเมีย',
          child: Text('เพศเมีย'),
        ),
      ],
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      validator: (value) {
        if (value == null) {
          return 'กรุณาเลือกเพศ';
        }
        return null;
      },
      iconEnabledColor: Colors.grey[500],
      isExpanded: true,
      // ปรับให้กรอบ dropdown โค้งมน
      menuMaxHeight: 160,
      borderRadius: BorderRadius.circular(12), // กำหนดความโค้งของกรอบ dropdown
    );
  }
}
