// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      dateFormat: json['date_format'] as String? ?? 'DD/MM/YYYY',
      theme: json['theme'] as String? ?? 'system',
      pinHash: json['pin_hash'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      aiInsightEnabled: json['ai_insight_enabled'] as bool? ?? true,
      budgetAlertEnabled: json['budget_alert_enabled'] as bool? ?? true,
      recurringReminderEnabled:
          json['recurring_reminder_enabled'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'currency_code': instance.currencyCode,
      'date_format': instance.dateFormat,
      'theme': instance.theme,
      'pin_hash': instance.pinHash,
      'biometric_enabled': instance.biometricEnabled,
      'onboarding_completed': instance.onboardingCompleted,
      'ai_insight_enabled': instance.aiInsightEnabled,
      'budget_alert_enabled': instance.budgetAlertEnabled,
      'recurring_reminder_enabled': instance.recurringReminderEnabled,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
