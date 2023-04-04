import 'package:flutter/material.dart';

class SpalshScreen extends StatelessWidget {
  const SpalshScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 203, 65, 1),
              borderRadius: BorderRadius.circular(15)),
          child: const Text(
            'Blip',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60,
            ),
          ),
        ),
      ),
    );
  }
}
