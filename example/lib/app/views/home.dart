import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ultralytics_yolo_example/app/views/take_photo.dart';
import 'package:ultralytics_yolo_example/app/views/take_photo_manual.dart';
import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedTflite;
  String? selectedYaml;
  List<String> tfliteFiles = [];
  List<String> yamlFiles = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _loadSavedConfiguration();
  }

  Future<void> _loadAssets() async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    setState(() {
      tfliteFiles = manifestMap.keys
          .where((String key) => key.contains('.tflite'))
          .toList();
      yamlFiles = manifestMap.keys
          .where((String key) => key.contains('.yaml'))
          .toList();
    });
  }

  Future<void> _loadSavedConfiguration() async {
    final prefsManager = await SharedPreferencesManager.getInstance();
    setState(() {
      selectedTflite =
          prefsManager.loadValue(PreferencesKeys.selectedModel) as String?;
      selectedYaml =
          prefsManager.loadValue(PreferencesKeys.selectedYaml) as String?;
    });
  }

  void _openConfigModal() {
    // ... (existing _openConfigModal code remains the same)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePhotoPage()),
                );
              },
              child: const Text('Ambil Foto'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePictureScreen()),
                );
              },
              child: const Text('Ambil Foto Manual'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add functionality for uploading (placeholder for now)
              },
              child: const Text('Upload'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openConfigModal,
              icon: const Icon(Icons.settings),
              label: const Text('Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
