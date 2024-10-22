import 'package:ultralytics_yolo_example/app/data/models/login_model.dart';
import 'package:ultralytics_yolo_example/app/utils/app_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginRepository {
  final uri = Uri.parse('${AppKeys.mainApiUrl}/loginAuth');

  Future<LoginModel> login(String email, String password) async {
    var request = http.MultipartRequest('POST', uri);
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final response = await request.send();
    var responseString = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseString);
      return LoginModel.fromJson(jsonResponse);
    } else {
      debugPrint('Failed to login');
      return LoginModel(
        success: 0,
        message: '',
      );
    }
  }
}
