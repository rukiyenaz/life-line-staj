import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/auth/domain/entities/user_model.dart';
import 'package:life_line/features/auth/domain/repositories/auth_repo.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepository) : super(AuthInitial());
  final AuthRepository authRepository;

  void checkAuth() async{
      final DoctorUser? user = await authRepository.getCurrentUser();
      if (user != null){
        emit(AuthAuthenticated(user));
        final DoctorUser? userData = await authRepository.getUserData(user.id  ?? '');
        emit(AuthAuthenticated(userData ?? user));
      }
      else{
        emit(AuthUnauthenticated());
      }
    }


  Future<void> signIn(String email, String password) async {
    try {
      await authRepository.signInWithEmail(email, password);
      final DoctorUser? user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      emit(AuthLoading());
      final DoctorUser? user = await authRepository.signUpWithEmail( email, password);
      if (user != null) {
        await authRepository.saveFirebaseUser(user);
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
