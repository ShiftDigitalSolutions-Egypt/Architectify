import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/logic/auth_state.dart';
import 'presentation/logic/get_auth_use_case.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetAuthUseCase getAuthUseCase;

  AuthCubit(this.getAuthUseCase) : super(AuthInitial());

  void login(String email, String password) async {
    emit(AuthLoading());
    final result = await getAuthUseCase.execute(email, password);
    result.fold(
      (failure) => emit(AuthFailure(failure.toString())),
      (user) => emit(AuthSuccess(user)),
    );
  }
}