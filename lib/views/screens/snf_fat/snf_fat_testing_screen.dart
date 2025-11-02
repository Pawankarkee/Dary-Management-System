import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class SNFFatTestingScreen extends StatelessWidget {
  const SNFFatTestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNF & Fat Testing'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'SNF & Fat Testing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Quality testing module - Models ready',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
