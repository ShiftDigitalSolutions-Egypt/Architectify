import 'package:dartz/dartz.dart';
import 'package:your_project_name/domain/repository/auth_repository.dart';
import 'package:your_project_name/domain/entities/otp_verify_response_entity.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, OtpVerifyResponseEntity>> call({
    required String phoneNumber,
    required String otpCode,
  }) {
    return repository.verifyOtp(phoneNumber: phoneNumber, otpCode: otpCode);
  }
}