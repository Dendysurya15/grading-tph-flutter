import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';
import 'package:screenshot/screenshot.dart'; // Import the screenshot package

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({super.key});

  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final controller = UltralyticsYoloCameraController();
  final ScreenshotController screenshotController =
      ScreenshotController(); // Create a ScreenshotController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkPermissions(),
        builder: (context, snapshot) {
          final allPermissionsGranted = snapshot.data ?? false;

          if (!allPermissionsGranted) {
            return const Center(child: Text('Permissions not granted'));
          }

          return FutureBuilder<ObjectDetector>(
            future: _initObjectDetectorWithLocalModel(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final predictor = snapshot.data;

              if (predictor == null) {
                return const Center(
                    child: Text('Failed to initialize predictor'));
              }

              return Stack(
                children: [
                  Screenshot(
                    controller:
                        screenshotController, // Wrap the camera preview with Screenshot
                    child: UltralyticsYoloCameraPreview(
                      controller: controller,
                      predictor: predictor,
                      onCameraCreated: () {
                        predictor.loadModel(useGpu: true);
                      },
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 40,
                    child: StreamBuilder<double?>(
                      stream: predictor.inferenceTime,
                      builder: (context, snapshot) {
                        final inferenceTime = snapshot.data;
                        return StreamBuilder<double?>(
                          stream: predictor.fpsRate,
                          builder: (context, snapshot) {
                            final fpsRate = snapshot.data;
                            return Times(
                              inferenceTime: inferenceTime,
                              fpsRate: fpsRate,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FloatingActionButton(
                        onPressed: () async {
                          // Capture screenshot
                          await _captureScreenshot(context);
                        },
                        child: const Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.flip_camera_ios),
        onPressed: () {
          controller.toggleLensDirection();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _captureScreenshot(BuildContext context) async {
    try {
      // Get the external storage directory
      final io.Directory? externalDir = await getExternalStorageDirectory();

      // Check if externalDir is not null
      if (externalDir == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access external storage')),
        );
        return;
      }

      // Create a directory for your app if it doesn't exist
      final io.Directory appDir = io.Directory(
          '${externalDir.path}/Pictures/com.ultralytics.ultralytics_yolo_example');
      await appDir.create(
          recursive: true); // Create the directory if it doesn't exist

      // Create a unique file name for the screenshot
      final String fileName =
          'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      // Capture the screenshot
      final Uint8List? capturedImage = await screenshotController.capture();

      if (capturedImage != null) {
        // Add watermark to the captured image
        final Uint8List watermarkedImage =
            await _addWatermark(capturedImage, 'Objects:');

        // Save the watermarked screenshot to the specified path
        final io.File file = io.File('${appDir.path}/$fileName');
        await file.writeAsBytes(watermarkedImage);

        // Optionally show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved: ${file.path}')),
        );

        // Show the screenshot preview in a dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Screenshot Preview'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300, // Adjust height as needed
                child: Image.memory(
                  watermarkedImage, // Use the watermarked image
                  fit: BoxFit.cover,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle any errors that occur during the screenshot capture
      print('Error capturing screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing screenshot')),
      );
    }
  }

  // Function to add watermark to the image
  Future<Uint8List> _addWatermark(
      Uint8List imageBytes, String watermarkText) async {
    // Load the image
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Create a new picture recorder
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Draw the original image on the canvas
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());

    // Set watermark style
    final TextStyle style = const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
    final TextSpan span = TextSpan(text: watermarkText, style: style);
    final TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    );
    painter.layout();

    // Position the watermark in the bottom right corner
    painter.paint(
        canvas,
        ui.Offset(image.width - painter.width - 10,
            image.height - painter.height - 10));

    // End recording and convert to image
    final ui.Image watermarkedImage =
        await recorder.endRecording().toImage(image.width, image.height);
    final ByteData? pngBytes =
        await watermarkedImage.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
    final prefsManager = await SharedPreferencesManager.getInstance();
    final savedModelPath =
        prefsManager.loadValue(PreferencesKeys.selectedModel) as String?;
    final savedMetadataPath =
        prefsManager.loadValue(PreferencesKeys.selectedYaml) as String?;

    final modelPath =
        await _copy(savedModelPath ?? 'assets/best_int8_sawit.tflite');
    final metadataPath =
        await _copy(savedMetadataPath ?? 'assets/metadata_sawit.yaml');

    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.tflite,
      modelPath: modelPath,
      metadataPath: metadataPath,
    );

    return ObjectDetector(model: model);
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    return cameraStatus.isGranted;
  }
}

class Times extends StatelessWidget {
  const Times({
    super.key,
    required this.inferenceTime,
    required this.fpsRate,
  });

  final double? inferenceTime;
  final double? fpsRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(inferenceTime ?? 0).toStringAsFixed(1)} ms - ${(fpsRate ?? 0).toStringAsFixed(1)} FPS',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
