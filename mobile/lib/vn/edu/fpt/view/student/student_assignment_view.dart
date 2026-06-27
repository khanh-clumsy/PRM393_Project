import 'package:flutter/material.dart';

class StudentAssignmentView extends StatelessWidget {
  const StudentAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Bài Tập', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Chức năng Bài Tập đang được phát triển...'),
      ),
    );
  }
}
