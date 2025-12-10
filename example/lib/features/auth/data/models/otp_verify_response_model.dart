import 'package:your_project_name/domain/entities/otp_verify_response_entity.dart';

class OtpVerifyResponseModel extends OtpVerifyResponseEntity {
  OtpVerifyResponseModel({required String message}) : super(message: message);

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponseModel(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}