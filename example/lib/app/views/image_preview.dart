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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover, // Display the image to cover the screen
              ),
            ),
          ),
          // Two buttons at the bottom of the screen
          // Row(
          //   children: [
          //     // Save Data Button

          //     // Retake Photo Button
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: ElevatedButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(); // Go back to retake photo
          //           },
          //           style: ElevatedButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(
          //                 vertical: 16.0), // Increase height
          //             backgroundColor:
          //                 Colors.white, // Different color for retake button
          //           ),
          //           child: const Text('Retake Photo'),
          //         ),
          //       ),
          //     ),

          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: ElevatedButton(
          //           onPressed: () {
          //             _saveData(context);
          //           },
          //           style: ElevatedButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(
          //                 vertical: 16.0), // Increase height
          //             backgroundColor: Colors.green,
          //           ),
          //           child: const Text('Save Data'),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // Simulate saving data process
  void _saveData(BuildContext context) {
    // You can add your logic here to save the image or send it to a server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  }
}
