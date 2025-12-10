import 'package:your_project_name/domain/entities/otp_response_entity.dart';

class OtpResponseModel extends OtpResponseEntity {
  OtpResponseModel({required String message}) : super(message: message);

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}