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
import 'package:ultralytics_yolo_example/app/views/image_preview.dart';
import 'package:screenshot/screenshot.dart'; // Import the screenshot package
import 'package:image/image.dart' as img; // Import the image package

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({super.key});

  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final controller = UltralyticsYoloCameraController();
  final ScreenshotController screenshotController =
      ScreenshotController(); // Create a ScreenshotController

  int _objectCount = 0;
  ValueNotifier<int> objectCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // Check permissions when the page is initialized
    _checkPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Optionally check permissions here if needed
  }

  @override
  void dispose() {
    controller
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

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
                      objectCountNotifier:
                          objectCountNotifier, // Pass the notifier here
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
                  // StreamBuilder<int>(
                  //   stream: predictor.objectCount,
                  //   builder: (context, snapshot) {
                  //     // Update _objectCount without returning any UI
                  //     _objectCount = snapshot.data ?? 0; // Update _objectCount
                  //     return const SizedBox.shrink(); // Return an empty widget
                  //   },
                  // ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FloatingActionButton(
                        onPressed: () async {
                          objectCountNotifier.value =
                              _objectCount; // Update the state
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
      final io.Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access external storage')),
        );
        return;
      }

      final io.Directory appDir = io.Directory(
          '${externalDir.path}/Pictures/com.ultralytics.ultralytics_yolo_example');
      await appDir.create(recursive: true);
      final String fileName =
          'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      final Uint8List? capturedImage = await screenshotController.capture();
      if (capturedImage != null) {
        final int currentCount = objectCountNotifier.value;

        // Retrieve additional data from shared preferences
        final prefsManager = await SharedPreferencesManager.getInstance();
        final selectedEst =
            prefsManager.loadValue(PreferencesKeys.selectedEst) as String?;
        final selectedAfd =
            prefsManager.loadValue(PreferencesKeys.selectedAfd) as String?;
        final nameBlok =
            prefsManager.loadValue(PreferencesKeys.nameBlok) as String?;

        // Add watermark with new text
        final Uint8List watermarkedImage = await _addWatermark(
          capturedImage,
          currentCount,
          selectedEst ?? 'Unknown Estate',
          selectedAfd ?? 'Unknown Afdeling',
          nameBlok ?? 'Unknown Blok',
        );

        // Compress the image
        final Uint8List compressedImage =
            await _compressImage(watermarkedImage);

        // Save the compressed screenshot to the specified path
        final io.File file = io.File('${appDir.path}/$fileName');
        await file.writeAsBytes(compressedImage);

        // Navigate to the PreviewScreen with the captured image
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewScreen(imageBytes: compressedImage),
          ),
        );
      }
    } catch (e) {
      print('Error capturing screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing screenshot')),
      );
    }
  }

// Function to add watermark to the image
  // Function to add watermark to the image
  Future<Uint8List> _addWatermark(
    Uint8List imageBytes,
    int objectCount,
    String estate,
    String afdeling,
    String blokName,
  ) async {
    // Load the image
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Create a new picture recorder
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Draw the original image on the canvas
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());

    // Define watermark text
    final String watermarkText =
        'Estate: $estate\nAfdeling: $afdeling\nBlok: $blokName\nJanjang Terdeteksi: $objectCount buah';

    // Set watermark style
    final TextStyle style = const TextStyle(
      color: Colors.yellow, // Yellow color
      fontSize: 50, // Larger font size
      fontWeight: FontWeight.bold,
    );
    final TextSpan span = TextSpan(text: watermarkText, style: style);
    final TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.right,
      textDirection: ui.TextDirection.ltr,
    );
    painter.layout();

    // Define the right and bottom margins
    const double rightMargin = 50.0; // Margin from the right edge
    const double bottomMargin = 50.0; // Margin from the bottom edge

    // Position the watermark text in the bottom-right corner with margin
    final double offsetX = image.width - painter.width - rightMargin;
    final double offsetY = image.height - painter.height - bottomMargin;

    // Paint the watermark on the canvas with the calculated offsets
    painter.paint(canvas, ui.Offset(offsetX, offsetY));

    // End recording and convert to image
    final ui.Image watermarkedImage =
        await recorder.endRecording().toImage(image.width, image.height);
    final ByteData? pngBytes =
        await watermarkedImage.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    // Decode the image to an img.Image object
    img.Image originalImage = img.decodeImage(imageBytes)!;

    // Compress the image using JPEG with a quality parameter
    List<int> compressedImageBytes = img.encodeJpg(originalImage, quality: 85);

    return Uint8List.fromList(compressedImageBytes);
  }
  // Function to add watermark to the image

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
