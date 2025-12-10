import 'package:dartz/dartz.dart';
import 'package:your_project_name/domain/repository/auth_repository.dart';
import 'package:your_project_name/domain/entities/otp_response_entity.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, OtpResponseEntity>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}