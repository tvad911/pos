
import '../../../core/database/database.dart';

/// Authentication repository
class AuthRepository {

  final AppDatabase _database;
  
  AuthRepository({
    required AppDatabase database,
  })  : _database = database;
  
  /// Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // For now, use mock authentication
      if (username == 'admin' && password == 'admin123') {
        final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        
        // Save token to database
        await saveToken(token);
        await saveUsername(username);
        
        return {
          'success': true,
          'token': token,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }
      
      /* Actual API call (uncomment when backend is ready):
      final response = await _dio.post(
        ApiEndpoints.LOGIN,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        await saveUsername(username);
        
        return {
          'success': true,
          'token': token,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _database.into(_database.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: 'auth_token',
        value: token,
        updatedAt: DateTime.now(),
      ),
    );
  }
  
  /// Get authentication token
  Future<String?> getToken() async {
    final setting = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals('auth_token')))
        .getSingleOrNull();
    
    return setting?.value;
  }
  
  /// Save username
  Future<void> saveUsername(String username) async {
    await _database.into(_database.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: 'username',
        value: username,
        updatedAt: DateTime.now(),
      ),
    );
  }
  
  /// Get username
  Future<String?> getUsername() async {
    final setting = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals('username')))
        .getSingleOrNull();
    
    return setting?.value;
  }
  
  /// Logout
  Future<void> logout() async {
    // Delete token from database
    await (_database.delete(_database.settings)
          ..where((tbl) => tbl.key.equals('auth_token')))
        .go();
    
    await (_database.delete(_database.settings)
          ..where((tbl) => tbl.key.equals('username')))
        .go();
  }
}
