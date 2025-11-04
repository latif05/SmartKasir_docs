class Settings {
  final int? id;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String storeEmail;
  final String accountName;
  final String accountEmail;
  final String receiptFormat;
  final int defaultMinStock;
  final bool enableOfflineMode;
  final bool enableLowStockNotification;
  final bool enableAutoSync;
  final DateTime? updatedAt;

  Settings({
    this.id,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.storeEmail,
    required this.accountName,
    required this.accountEmail,
    required this.receiptFormat,
    required this.defaultMinStock,
    required this.enableOfflineMode,
    required this.enableLowStockNotification,
    required this.enableAutoSync,
    this.updatedAt,
  });

  Settings copyWith({
    int? id,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeEmail,
    String? accountName,
    String? accountEmail,
    String? receiptFormat,
    int? defaultMinStock,
    bool? enableOfflineMode,
    bool? enableLowStockNotification,
    bool? enableAutoSync,
    DateTime? updatedAt,
  }) {
    return Settings(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeEmail: storeEmail ?? this.storeEmail,
      accountName: accountName ?? this.accountName,
      accountEmail: accountEmail ?? this.accountEmail,
      receiptFormat: receiptFormat ?? this.receiptFormat,
      defaultMinStock: defaultMinStock ?? this.defaultMinStock,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      enableLowStockNotification:
          enableLowStockNotification ?? this.enableLowStockNotification,
      enableAutoSync: enableAutoSync ?? this.enableAutoSync,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int?,
      storeName: map['store_name'] as String? ?? '',
      storeAddress: map['store_address'] as String? ?? '',
      storePhone: map['store_phone'] as String? ?? '',
      storeEmail: map['store_email'] as String? ?? '',
      accountName: map['account_name'] as String? ?? '',
      accountEmail: map['account_email'] as String? ?? '',
      receiptFormat: map['receipt_format'] as String? ?? '',
      defaultMinStock: map['default_min_stock'] is int
          ? map['default_min_stock'] as int
          : int.tryParse(map['default_min_stock']?.toString() ?? '0') ?? 0,
      enableOfflineMode: (map['enable_offline_mode'] ?? 0) == 1,
      enableLowStockNotification:
          (map['enable_low_stock_notification'] ?? 0) == 1,
      enableAutoSync: (map['enable_auto_sync'] ?? 0) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'store_email': storeEmail,
      'account_name': accountName,
      'account_email': accountEmail,
      'receipt_format': receiptFormat,
      'default_min_stock': defaultMinStock,
      'enable_offline_mode': enableOfflineMode ? 1 : 0,
      'enable_low_stock_notification': enableLowStockNotification ? 1 : 0,
      'enable_auto_sync': enableAutoSync ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
