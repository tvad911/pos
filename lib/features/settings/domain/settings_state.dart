import 'package:equatable/equatable.dart';

/// Settings state
abstract class SettingsState extends Equatable {
  const SettingsState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {}

/// Loading state
class SettingsLoading extends SettingsState {}

/// Profile loaded state
class SettingsProfileLoaded extends SettingsState {
  final String name;
  final String email;
  final String username;
  final String cmsBaseUrl;
  final String cmsApiKey;
  
  const SettingsProfileLoaded({
    required this.name,
    required this.email,
    required this.username,
    this.cmsBaseUrl = '',
    this.cmsApiKey = '',
  });
  
  @override
  List<Object?> get props => [name, email, username, cmsBaseUrl, cmsApiKey];
}

/// Update success state
class SettingsUpdateSuccess extends SettingsState {
  final String message;
  
  const SettingsUpdateSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Settings error state
class SettingsError extends SettingsState {
  final String message;
  
  const SettingsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
