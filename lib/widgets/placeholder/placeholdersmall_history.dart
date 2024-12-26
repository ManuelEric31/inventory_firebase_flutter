import 'package:flutter/material.dart';

class PlaceholdersmallNoItem extends StatelessWidget {
  const PlaceholdersmallNoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 32,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                width: 140, height: 140, 'assets/images/placeholderhome.png'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'There is no item stored in here',
          style: TextStyle(fontSize: 12),
        )
      ],
    );
  }
}
