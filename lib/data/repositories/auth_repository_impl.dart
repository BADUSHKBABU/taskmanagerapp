import 'package:taskmanagerapp/data/datasources/auth_remote_datasource.dart';
import 'package:taskmanagerapp/domain/entities/user_entity.dart';
import 'package:taskmanagerapp/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return remoteDataSource.getCurrentUser();
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) {
    return remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String name) {
    return remoteDataSource.signUpWithEmailAndPassword(email, password, name);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
