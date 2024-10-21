import 'package:flutter/material.dart';
import 'dart:typed_data';

class PreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const PreviewScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the camera screen
          },
        ),
      ),
      body: Center(
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover, // Display the image to cover the screen
        ),
      ),
    );
  }
}
