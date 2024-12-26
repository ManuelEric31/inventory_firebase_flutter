import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTextfield extends StatefulWidget {
  final TextEditingController controllerDate;

  const DateTextfield({super.key, required this.controllerDate});

  @override
  State<DateTextfield> createState() => _DateTextfieldState();
}

class _DateTextfieldState extends State<DateTextfield> {
  DateTime? _selectedDate;
  final DateFormat formatter = DateFormat.yMd();

  void _onPressedCalendar() async {
    final dateNow = DateTime.now();
    final firstDate = DateTime(dateNow.year - 40, dateNow.month, dateNow.day);
    final selectedDate = await showDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: dateNow,
        initialDate: dateNow);
    setState(() {
      _selectedDate = selectedDate;
      if (_selectedDate != null) {
        widget.controllerDate.text = formatter.format(_selectedDate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: SizedBox(
        child: TextField(
          readOnly: true,
          controller: widget.controllerDate,
          onTap: _onPressedCalendar,
          decoration: InputDecoration(
            fillColor: const Color(0xFFFAFAFA),
            filled: true,
            hintText: 'Tanggal Masuk / Keluar',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF8696BB),
            ),
            prefixIcon: const Icon(
              Icons.calendar_month,
              color: Color(0xFF8696BB),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF8696BB)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
