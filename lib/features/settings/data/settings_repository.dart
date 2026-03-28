import '../../../core/database/database.dart';

/// Settings repository for user profile management
class SettingsRepository {
  final AppDatabase _database;
  
  SettingsRepository({required AppDatabase database}) : _database = database;
  
  /// Get user profile and CMS settings
  Future<Map<String, String>> getUserProfile() async {
    final username = await _getSetting('username');
    final name = await _getSetting('user_name');
    final email = await _getSetting('user_email');
    final cmsBaseUrl = await _getSetting('cms_base_url');
    final cmsApiKey = await _getSetting('cms_api_key');
    
    return {
      'username': username ?? '',
      'name': name ?? username ?? '',
      'email': email ?? '',
      'cms_base_url': cmsBaseUrl ?? '',
      'cms_api_key': cmsApiKey ?? '',
    };
  }
  
  /// Update CMS connection settings
  Future<void> updateCmsSettings(String baseUrl, String apiKey) async {
    await _saveSetting('cms_base_url', baseUrl);
    await _saveSetting('cms_api_key', apiKey);
  }
  
  /// Update user profile
  Future<void> updateUserProfile(String name, String email) async {
    await _saveSetting('user_name', name);
    await _saveSetting('user_email', email);
  }
  
  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    // TODO: Implement actual password verification when API is ready
    // For now, just save the new password
    final savedPassword = await _getSetting('user_password');
    
    // Mock verification
    if (savedPassword != null && savedPassword != currentPassword) {
      return false;
    }
    
    await _saveSetting('user_password', newPassword);
    return true;
  }
  
  /// Get setting value
  Future<String?> _getSetting(String key) async {
    final setting = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    
    return setting?.value;
  }
  
  /// Save setting value
  Future<void> _saveSetting(String key, String value) async {
    await _database.into(_database.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
