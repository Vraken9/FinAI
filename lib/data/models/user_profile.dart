import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserProfile({
    required String id,
    @Default('') String fullName,
    String? avatarUrl,
    @Default('IDR') String currencyCode,
    @Default('DD/MM/YYYY') String dateFormat,
    @Default('system') String theme,
    String? pinHash,
    @Default(false) bool biometricEnabled,
    @Default(false) bool onboardingCompleted,
    @Default(true) bool aiInsightEnabled,
    @Default(true) bool budgetAlertEnabled,
    @Default(true) bool recurringReminderEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
