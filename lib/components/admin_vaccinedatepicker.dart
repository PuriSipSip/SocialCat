import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับ format วันที่

class VaccineDatePicker extends StatefulWidget {
  final TextEditingController controller;

  const VaccineDatePicker({super.key, required this.controller});

  @override
  _VaccineDatePickerState createState() => _VaccineDatePickerState();
}

class _VaccineDatePickerState extends State<VaccineDatePicker> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: 'ได้รับวัคซีนวันที่',
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? 'กรุณาเลือกวันที่ได้รับวัคซีน' : null,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2026),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            selectedDate = pickedDate;
            widget.controller.text =
                formattedDate; // เก็บวันที่ใน TextEditingController
          });
        }
      },
    );
  }
}
