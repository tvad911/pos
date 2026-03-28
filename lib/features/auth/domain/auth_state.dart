import 'package:equatable/equatable.dart';

/// Authentication state
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final String token;
  final String username;
  
  const AuthAuthenticated({
    required this.token,
    required this.username,
  });
  
  @override
  List<Object?> get props => [token, username];
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {}
