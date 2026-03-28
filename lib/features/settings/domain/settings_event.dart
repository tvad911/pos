import 'package:equatable/equatable.dart';

/// Settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object?> get props => [];
}

/// Update user profile event
class UpdateUserProfileRequested extends SettingsEvent {
  final String name;
  final String email;
  
  const UpdateUserProfileRequested({
    required this.name,
    required this.email,
  });
  
  @override
  List<Object?> get props => [name, email];
}

/// Change password event
class ChangePasswordRequested extends SettingsEvent {
  final String currentPassword;
  final String newPassword;
  
  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
  
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Load user profile event
class LoadUserProfileRequested extends SettingsEvent {}

/// Update CMS connection settings event
class UpdateCmsSettingsRequested extends SettingsEvent {
  final String baseUrl;
  final String apiKey;
  
  const UpdateCmsSettingsRequested({
    required this.baseUrl,
    required this.apiKey,
  });
  
  @override
  List<Object?> get props => [baseUrl, apiKey];
}
