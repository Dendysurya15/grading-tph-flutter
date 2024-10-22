import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ultralytics_yolo_example/app/views/take_photo.dart';
import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedTflite;
  String? selectedYaml;
  String? selectedEst;
  String? selectedAfd;
  String? nameBlok;
  List<String> tfliteFiles = [];
  List<String> yamlFiles = [];
  List<String> estOptions = ['NBE'];
  List<String> afdOptions = ['OA', 'OB', 'OC', 'OD'];

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
      selectedEst =
          prefsManager.loadValue(PreferencesKeys.selectedEst) as String?;
      selectedAfd =
          prefsManager.loadValue(PreferencesKeys.selectedAfd) as String?;
      nameBlok = prefsManager.loadValue(PreferencesKeys.nameBlok) as String?;
    });
  }

  void _openConfigModal() {
    String? tempSelectedTflite = selectedTflite;
    String? tempSelectedYaml = selectedYaml;
    String? tempSelectedEst = selectedEst;
    String? tempSelectedAfd = selectedAfd;
    String? tempNameBlok = nameBlok;

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
                    Text('Configuration AI',
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
                    DropdownButtonFormField<String>(
                      value: tempSelectedEst,
                      decoration: InputDecoration(
                        labelText: 'Select EST',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setModalState(() {
                          tempSelectedEst = newValue;
                        });
                      },
                      items: estOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: tempSelectedAfd,
                      decoration: InputDecoration(
                        labelText: 'Select AFD',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setModalState(() {
                          tempSelectedAfd = newValue;
                        });
                      },
                      items: afdOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: tempNameBlok,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Name Blok',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      onChanged: (String value) {
                        tempNameBlok = value.toUpperCase();
                      },
                      inputFormatters: [
                        UpperCaseTextFormatter(), // Ensures text is always uppercase
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          selectedTflite = tempSelectedTflite;
                          selectedYaml = tempSelectedYaml;
                          selectedEst = tempSelectedEst;
                          selectedAfd = tempSelectedAfd;
                          nameBlok = tempNameBlok;
                        });

                        // Save to SharedPreferences
                        final prefsManager =
                            await SharedPreferencesManager.getInstance();
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedModel,
                            selectedTflite ?? '');
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedYaml, selectedYaml ?? '');
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedEst, selectedEst ?? '');
                        await prefsManager.saveValue(
                            PreferencesKeys.selectedAfd, selectedAfd ?? '');
                        await prefsManager.saveValue(
                            PreferencesKeys.nameBlok, nameBlok ?? '');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Configuration saved:\nTFLITE: ${selectedTflite?.split('/').last}\nYAML: ${selectedYaml?.split('/').last}\nEST: $selectedEst\nAFD: $selectedAfd\nName Blok: $nameBlok'),
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
      // appBar: AppBar(
      //   title: Text('Home Page'),
      // ),
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
              child: Text('Upload Foto'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openConfigModal,
              child: Text('Configuration AI'),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter to ensure uppercase input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
