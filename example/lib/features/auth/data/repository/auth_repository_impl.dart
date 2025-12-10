@Injectable(as: AuthRepository)
class AuthRepositoryImpl {
  final ApIsManager apIsManager;

  AuthRepositoryImpl(this.apIsManager);

  @override
  Future<Either<Failure, OtpResponseModel>> sendOtp(String phoneNumber) async {
    try {
      final response = await apIsManager.send(
        request: SendOtpRequest(phoneNumber),
        responseFromMap: (map) => OtpResponseModel.fromJson(map),
      );

      return response.fold(
            (l) => Left(l),
            (r) => Right(r),
      );
    } catch (e) {
      return Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, OtpVerifyResponseModel>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await apIsManager.send(
        request: VerifyOtpRequest(phoneNumber, otpCode),
        responseFromMap: (map) => OtpVerifyResponseModel.fromJson(map),
      );

      return response.fold(
            (l) => Left(l),
            (r) => Right(r),
      );
    } catch (e) {
      return Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUserModel>> login(String token) async {
    try {
      final response = await apIsManager.send(
        request: LoginRequest(token),
        responseFromMap: (map) => AuthUserModel.fromJson(map),
      );

      return response.fold(
            (l) => Left(l),
            (r) => Right(r),
      );
    } catch (e) {
      return Left(ConnectionFailure());
    }
  }

  @override
  bool get isAuthenticated {
    return false;
  }
}
```