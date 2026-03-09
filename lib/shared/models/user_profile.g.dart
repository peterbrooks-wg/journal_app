// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  subscriptionTier: json['subscription_tier'] as String,
  onboardingCompleted: json['onboarding_completed'] as bool,
  timezone: json['timezone'] as String,
  fcmToken: json['fcm_token'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscription_tier': instance.subscriptionTier,
      'onboarding_completed': instance.onboardingCompleted,
      'timezone': instance.timezone,
      'fcm_token': instance.fcmToken,
      'created_at': instance.createdAt.toIso8601String(),
    };
