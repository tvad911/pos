import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../data/settings_repository.dart';

/// Settings BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  
  SettingsBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(SettingsInitial()) {
    on<LoadUserProfileRequested>(_onLoadUserProfile);
    on<UpdateUserProfileRequested>(_onUpdateUserProfile);
    on<ChangePasswordRequested>(_onChangePassword);
    on<UpdateCmsSettingsRequested>(_onUpdateCmsSettings);
  }
  
  /// Load user profile
  Future<void> _onLoadUserProfile(
    LoadUserProfileRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    try {
      final profile = await _settingsRepository.getUserProfile();
      
      emit(SettingsProfileLoaded(
        name: profile['name']!,
        email: profile['email']!,
        username: profile['username']!,
        cmsBaseUrl: profile['cms_base_url']!,
        cmsApiKey: profile['cms_api_key']!,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
  
  /// Update user profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfileRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    try {
      await _settingsRepository.updateUserProfile(event.name, event.email);
      
      // Reload profile
      final profile = await _settingsRepository.getUserProfile();
      
      emit(const SettingsUpdateSuccess('Cập nhật thông tin thành công'));
      
      // Return to profile loaded state
      emit(SettingsProfileLoaded(
        name: profile['name']!,
        email: profile['email']!,
        username: profile['username']!,
        cmsBaseUrl: profile['cms_base_url']!,
        cmsApiKey: profile['cms_api_key']!,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  /// Update CMS connection settings
  Future<void> _onUpdateCmsSettings(
    UpdateCmsSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    try {
      await _settingsRepository.updateCmsSettings(event.baseUrl, event.apiKey);
      
      // Reload profile to get all settings
      final profile = await _settingsRepository.getUserProfile();
      
      emit(const SettingsUpdateSuccess('Cập nhật kết nối CMS thành công'));
      
      emit(SettingsProfileLoaded(
        name: profile['name']!,
        email: profile['email']!,
        username: profile['username']!,
        cmsBaseUrl: profile['cms_base_url']!,
        cmsApiKey: profile['cms_api_key']!,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
  
  /// Change password
  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    emit(SettingsLoading());
    
    try {
      final success = await _settingsRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      
      if (success) {
        emit(const SettingsUpdateSuccess('Đổi mật khẩu thành công'));
        
        // Return to previous state
        if (currentState is SettingsProfileLoaded) {
          emit(currentState);
        }
      } else {
        emit(const SettingsError('Mật khẩu hiện tại không đúng'));
        
        // Return to previous state
        if (currentState is SettingsProfileLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
      
      // Return to previous state
      if (currentState is SettingsProfileLoaded) {
        emit(currentState);
      }
    }
  }
}
