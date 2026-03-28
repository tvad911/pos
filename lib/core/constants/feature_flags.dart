import 'dart:convert';

/// Feature flags for module configuration
class FeatureFlags {
  // Flag keys
  static const String fnbEnabledKey = 'is_fnb_enabled';
  static const String batchTrackingEnabledKey = 'is_batch_tracking_enabled';
  static const String multiWarehouseKey = 'is_multi_warehouse';
  
  final Map<String, dynamic> _flags;
  
  FeatureFlags(this._flags);
  
  /// Parse feature flags from JSON string
  factory FeatureFlags.fromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return FeatureFlags(data);
  }
  
  /// Convert to JSON string
  String toJson() => json.encode(_flags);
  
  /// Check if F&B module is enabled
  bool get isFnBEnabled => _flags[fnbEnabledKey] ?? false;
  
  /// Check if batch tracking is enabled
  bool get isBatchTrackingEnabled => _flags[batchTrackingEnabledKey] ?? false;
  
  /// Check if multi-warehouse is enabled
  bool get isMultiWarehouse => _flags[multiWarehouseKey] ?? false;
  
  /// Update a feature flag
  void setFlag(String key, bool value) {
    _flags[key] = value;
  }
  
  /// Get all flags as map
  Map<String, dynamic> get allFlags => Map.unmodifiable(_flags);
}
