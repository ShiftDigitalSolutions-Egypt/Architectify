import 'package:dartz/dartz.dart';
import 'package:your_project_name/domain/entities/auth_user_entity.dart';
import 'package:your_project_name/domain/entities/otp_response_entity.dart';
import 'package:your_project_name/domain/entities/otp_verify_response_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, OtpResponseEntity>> sendOtp(String phoneNumber);
  Future<Either<Failure, OtpVerifyResponseEntity>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });
  Future<Either<Failure, AuthUserEntity>> login(String token);
  bool get isAuthenticated;
}