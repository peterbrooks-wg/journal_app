import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// A user's profile extending Supabase auth.
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile {
  final String id;
  final String subscriptionTier;
  final bool onboardingCompleted;
  final String timezone;
  final String? fcmToken;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.subscriptionTier,
    required this.onboardingCompleted,
    required this.timezone,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
