import 'package:dartz/dartz.dart';
import 'package:your_project_name/domain/repository/auth_repository.dart';
import 'package:your_project_name/domain/entities/auth_user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthUserEntity>> call(String token) {
    return repository.login(token);
  }
}
```