// import 'dart:io' as io;

// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:ultralytics_yolo/ultralytics_yolo.dart';
// import 'package:ultralytics_yolo/yolo_model.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final controller = UltralyticsYoloCameraController();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: FutureBuilder<bool>(
//           future: _checkPermissions(),
//           builder: (context, snapshot) {
//             // if (snapshot.connectionState == ConnectionState.waiting) {
//             //   return Center(child: CircularProgressIndicator());
//             // }

//             final allPermissionsGranted = snapshot.data ?? false;

//             if (!allPermissionsGranted) {
//               return const Center(child: Text('Permissions not granted'));
//             }

//             return FutureBuilder<ObjectDetector>(
//               future: _initObjectDetectorWithLocalModel(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final predictor = snapshot.data;

//                 if (predictor == null) {
//                   return const Center(
//                       child: Text('Failed to initialize predictor'));
//                 }

//                 return Stack(
//                   children: [
//                     UltralyticsYoloCameraPreview(
//                       controller: controller,
//                       predictor: predictor,
//                       onCameraCreated: () {
//                         predictor.loadModel(useGpu: true);
//                       },
//                     ),
//                     StreamBuilder<double?>(
//                       stream: predictor.inferenceTime,
//                       builder: (context, snapshot) {
//                         final inferenceTime = snapshot.data;

//                         return StreamBuilder<double?>(
//                           stream: predictor.fpsRate,
//                           builder: (context, snapshot) {
//                             final fpsRate = snapshot.data;

//                             return Times(
//                               inferenceTime: inferenceTime,
//                               fpsRate: fpsRate,
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.abc),
//           onPressed: () {
//             controller.toggleLensDirection();
//           },
//         ),
//       ),
//     );
//   }

//   Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
//     // final modelPath = await _copy('assets/yolov8n.mlmodel');
//     // final model = LocalYoloModel(
//     //   id: '',
//     //   task: Task.detect,
//     //   format: Format.coreml,
//     //   modelPath: modelPath,
//     // );
//     final modelPath = await _copy('assets/best_int8_sawit.tflite');
//     final metadataPath = await _copy('assets/metadata_sawit.yaml');
//     final model = LocalYoloModel(
//       id: '',
//       task: Task.detect,
//       format: Format.tflite,
//       modelPath: modelPath,
//       metadataPath: metadataPath,
//     );

//     return ObjectDetector(model: model);
//   }

//   Future<ImageClassifier> _initImageClassifierWithLocalModel() async {
//     final modelPath = await _copy('assets/yolov8n-cls.mlmodel');
//     final model = LocalYoloModel(
//       id: '',
//       task: Task.classify,
//       format: Format.coreml,
//       modelPath: modelPath,
//     );

//     // final modelPath = await _copy('assets/yolov8n-cls.bin');
//     // final paramPath = await _copy('assets/yolov8n-cls.param');
//     // final metadataPath = await _copy('assets/metadata-cls.yaml');
//     // final model = LocalYoloModel(
//     //   id: '',
//     //   task: Task.classify,
//     //   modelPath: modelPath,
//     //   paramPath: paramPath,
//     //   metadataPath: metadataPath,
//     // );

//     return ImageClassifier(model: model);
//   }

//   Future<String> _copy(String assetPath) async {
//     final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
//     await io.Directory(dirname(path)).create(recursive: true);
//     final file = io.File(path);
//     if (!await file.exists()) {
//       final byteData = await rootBundle.load(assetPath);
//       await file.writeAsBytes(byteData.buffer
//           .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//     }
//     return file.path;
//   }

//   Future<bool> _checkPermissions() async {
//     final cameraStatus = await Permission.camera.status;
//     // final storageStatus = await Permission.storage.status;

//     if (!cameraStatus.isGranted) {
//       await Permission.camera.request();
//     }
//     // if (!storageStatus.isGranted) {
//     //   await Permission.storage.request();
//     // }

//     return cameraStatus.isGranted;
//   }
// }

// class Times extends StatelessWidget {
//   const Times({
//     super.key,
//     required this.inferenceTime,
//     required this.fpsRate,
//   });

//   final double? inferenceTime;
//   final double? fpsRate;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Align(
//         alignment: Alignment.bottomCenter,
//         child: Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//               color: Colors.black54,
//             ),
//             child: Text(
//               '${(inferenceTime ?? 0).toStringAsFixed(1)} ms  -  ${(fpsRate ?? 0).toStringAsFixed(1)} FPS',
//               style: const TextStyle(color: Colors.white70),
//             )),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/app/views/home.dart';
import 'package:ultralytics_yolo_example/app/views/take_photo.dart';
import 'app/views/welcome.dart';
import 'app/views/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flexible Routing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Ensure the first route is WelcomePage
      home: WelcomePage(),
      // Define your routes
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/ambil_foto': (context) => TakePhotoPage(),
      },
    );
  }
}
