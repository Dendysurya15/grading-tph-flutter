import 'package:ultralytics_yolo_example/app/data/models/user_model.dart';

class LoginModel {
  final int success;
  final String message;
  final UserModel? data;

  LoginModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['statusCode'],
      message: json['message'],
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }
}
