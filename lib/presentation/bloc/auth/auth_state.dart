import 'package:equatable/equatable.dart';
import 'package:taskmanagerapp/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  final UserEntity user;

  const AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);
}
