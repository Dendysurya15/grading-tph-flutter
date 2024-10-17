import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ultralytics_yolo_example/app/views/take_photo.dart';
import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';

class HomePage extends StatefulWidget {
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
    String? tempSelectedTflite = selectedTflite;
    String? tempSelectedYaml = selectedYaml;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Configuration',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: tempSelectedTflite,
                      decoration: InputDecoration(
                        labelText: 'Select TFLITE file',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setModalState(() {
                          tempSelectedTflite = newValue;
                        });
                      },
                      items: tfliteFiles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.split('/').last,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: tempSelectedYaml,
                      decoration: InputDecoration(
                        labelText: 'Select YAML file',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setModalState(() {
                          tempSelectedYaml = newValue;
                        });
                      },
                      items: yamlFiles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.split('/').last,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          selectedTflite = tempSelectedTflite;
                          selectedYaml = tempSelectedYaml;
                        });

                        // Save to SharedPreferences
                        final prefsManager =
                            await SharedPreferencesManager.getInstance();
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedModel,
                            selectedTflite ?? '');
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedYaml, selectedYaml ?? '');

                        print('Selected TFLITE file: $selectedTflite');
                        print('Selected YAML file: $selectedYaml');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Configuration saved:\nTFLITE: ${selectedTflite?.split('/').last}\nYAML: ${selectedYaml?.split('/').last}'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Save Configuration'),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePhotoPage()),
                );
              },
              child: Text('Ambil Foto'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add functionality for uploading (placeholder for now)
              },
              child: Text('Upload'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openConfigModal,
              icon: Icon(Icons.settings),
              label: Text('Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
