import 'package:flutter/material.dart';

class UsernameLoginTextField extends StatelessWidget {
  final TextEditingController controllerTyped;

  const UsernameLoginTextField({super.key, required this.controllerTyped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: TextField(
        controller: controllerTyped,
        decoration: InputDecoration(
          fillColor: const Color(0xFFFAFAFA),
          filled: true,
          hintText: 'Enter your email',
          hintStyle: const TextStyle(
            color: Color(0xFF8696BB),
          ),
          prefixIcon: const Icon(
            Icons.mail,
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
