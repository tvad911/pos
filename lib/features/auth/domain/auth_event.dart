import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Login event
class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  
  const LoginRequested({
    required this.username,
    required this.password,
  });
  
  @override
  List<Object?> get props => [username, password];
}

/// Logout event
class LogoutRequested extends AuthEvent {}

/// Check authentication status event
class AuthCheckRequested extends AuthEvent {}
