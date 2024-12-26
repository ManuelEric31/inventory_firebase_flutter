import 'package:flutter/material.dart';

class PlaceholderNoSupplier extends StatelessWidget {
  const PlaceholderNoSupplier({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 32,
          width: 32,
        ),
        Image.asset(
          'assets/images/placeholderhome2.png',
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16),
        const Text(
          'There is no supplier stored in here',
          style: TextStyle(fontSize: 14),
        )
      ],
    );
  }
}
