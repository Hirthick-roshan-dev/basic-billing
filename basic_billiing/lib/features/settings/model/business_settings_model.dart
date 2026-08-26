import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';

class BusinessSettingsModel {
  final int id;
  final String businessName;
  final String phoneNumber;
  final String address;
  final bool taxEnabled;
  final double taxPercent;
  final DateTime? updatedAt;

  const BusinessSettingsModel({
    this.id = 1,
    this.businessName = "BROTHER'S AUTO CARE",
    this.phoneNumber = '78 71 75 78 78',
    this.address = 'No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
    this.taxEnabled = false,
    this.taxPercent = 0.0,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colSettingsId: id,
      DatabaseConstants.colSettingsBusinessName: businessName,
      DatabaseConstants.colSettingsPhoneNumber: phoneNumber,
      DatabaseConstants.colSettingsAddress: address,
      DatabaseConstants.colSettingsTaxEnabled: taxEnabled ? 1 : 0,
      DatabaseConstants.colSettingsTaxPercent: CurrencyUtils.round(taxPercent),
      DatabaseConstants.colSettingsUpdatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory BusinessSettingsModel.fromMap(Map<String, dynamic> map) {
    return BusinessSettingsModel(
      id: map[DatabaseConstants.colSettingsId] as int? ?? 1,
      businessName: map[DatabaseConstants.colSettingsBusinessName] as String? ??
          "BROTHER'S AUTO CARE",
      phoneNumber:
          map[DatabaseConstants.colSettingsPhoneNumber] as String? ?? '78 71 75 78 78',
      address: map[DatabaseConstants.colSettingsAddress] as String? ??
          'No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
      taxEnabled: (map[DatabaseConstants.colSettingsTaxEnabled] as int? ?? 0) == 1,
      taxPercent: CurrencyUtils.round(
          (map[DatabaseConstants.colSettingsTaxPercent] as num?)?.toDouble() ?? 0.0),
      updatedAt: map[DatabaseConstants.colSettingsUpdatedAt] != null
          ? DateTime.parse(map[DatabaseConstants.colSettingsUpdatedAt] as String)
          : null,
    );
  }

  BusinessSettingsModel copyWith({
    int? id,
    String? businessName,
    String? phoneNumber,
    String? address,
    bool? taxEnabled,
    double? taxPercent,
    DateTime? updatedAt,
  }) {
    return BusinessSettingsModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      taxPercent: taxPercent != null ? CurrencyUtils.round(taxPercent) : this.taxPercent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
