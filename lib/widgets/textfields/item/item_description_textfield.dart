import 'package:flutter/material.dart';

class ItemDescriptionTextfield extends StatelessWidget {
  final TextEditingController controllerTyped;

  const ItemDescriptionTextfield({super.key, required this.controllerTyped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: SizedBox(
        child: TextField(
          controller: controllerTyped,
          maxLines: 6,
          minLines: 1,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            fillColor: const Color(0xFFFAFAFA),
            filled: true,
            hintText: 'Item Description',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF8696BB),
            ),
            prefixIcon: const Icon(
              Icons.description,
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
