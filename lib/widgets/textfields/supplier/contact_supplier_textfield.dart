import 'package:flutter/material.dart';

class ContactSupplierTextfield extends StatelessWidget {
  final TextEditingController controllerTyped;

  const ContactSupplierTextfield({super.key, required this.controllerTyped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: TextField(
        controller: controllerTyped,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          fillColor: const Color(0xFFFAFAFA),
          filled: true,
          hintText: 'Supplier Contact',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF8696BB),
          ),
          prefixIcon: const Icon(
            Icons.phone,
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
