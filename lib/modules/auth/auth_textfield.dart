import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0), // Применяем закругление
              borderSide: BorderSide.none, // Убираем границу
              // enabledBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 230, 231, 235)),
            ),
            fillColor: const Color.fromARGB(255, 230, 231, 235),
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}
