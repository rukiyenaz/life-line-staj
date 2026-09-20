
import 'package:life_line/features/auth/domain/entities/user_model.dart';

abstract class AuthRepository {
  Future<DoctorUser?> getCurrentUser();
  Future<DoctorUser?> getUserData(String userId);
  Future<void> signInWithEmail(String email, String password);
  Future<DoctorUser?> signUpWithEmail(String email, String password);
  Future<void> saveFirebaseUser(DoctorUser user);
  Future<void> signOut();
}
