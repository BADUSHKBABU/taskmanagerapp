import 'package:taskmanagerapp/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String name);
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
}
