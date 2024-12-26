import 'package:flutter/material.dart';

class LatitudeSupplierTextfield extends StatelessWidget {
  final TextEditingController controllerTyped;

  const LatitudeSupplierTextfield({super.key, required this.controllerTyped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: TextField(
        controller: controllerTyped,
        readOnly: true,
        decoration: InputDecoration(
          fillColor: const Color(0xFFFAFAFA),
          filled: true,
          hintText: 'Supplier Latitude',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF8696BB),
          ),
          prefixIcon: const Icon(
            Icons.location_on,
            color: Color(0xFF8696BB),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
