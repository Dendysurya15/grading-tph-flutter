import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For processing the response

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  File? _capturedImage;
  List<dynamic>? _detectionResults; // Store the detection results

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedImage = File(image.path);
        _detectionResults = null; // Reset detection results
      });

      // After capturing the image, send it to the server for processing
      await _processImageWithYOLO(_capturedImage!);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processImageWithYOLO(File imageFile) async {
    // Replace with your server URL
    final url = Uri.parse('http://your-server-url.com/process-image');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        setState(() {
          _detectionResults = decodedResponse['detections'];
        });
      } else {
        print('Failed to process image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Photo Capture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: _capturedImage == null
                      ? CameraPreview(_controller)
                      : Stack(
                          children: [
                            Image.file(_capturedImage!),
                            if (_detectionResults != null)
                              _buildBoundingBoxes(), // Overlay detection results
                          ],
                        ),
                ),
                ElevatedButton(
                  onPressed: _captureImage,
                  child: const Text('Capture Image'),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildBoundingBoxes() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: _detectionResults!.map((detection) {
              final boundingBox = detection['bounding_box'];
              final label = detection['label'];

              // Bounding box coordinates (from YOLO)
              final left = boundingBox[0] * constraints.maxWidth;
              final top = boundingBox[1] * constraints.maxHeight;
              final width = boundingBox[2] * constraints.maxWidth;
              final height = boundingBox[3] * constraints.maxHeight;

              return Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Text(
                    ~label,
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
