import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';

class TakePhotoPage extends StatefulWidget {
  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final controller = UltralyticsYoloCameraController();

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
                  UltralyticsYoloCameraPreview(
                    controller: controller,
                    predictor: predictor,
                    onCameraCreated: () {
                      predictor.loadModel(useGpu: true);
                    },
                  ),
                  StreamBuilder<double?>(
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
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: StreamBuilder<int>(
                      stream: predictor.objectCount,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Objects: $count',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      },
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
    );
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
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.black54,
            ),
            child: Text(
              '${(inferenceTime ?? 0).toStringAsFixed(1)} ms  -  ${(fpsRate ?? 0).toStringAsFixed(1)} FPS',
              style: const TextStyle(color: Colors.white70),
            )),
      ),
    );
  }
}
