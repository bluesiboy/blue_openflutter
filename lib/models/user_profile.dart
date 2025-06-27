import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  static const String _prefsKey = 'user_profile';

  String avatar;
  String name;
  String email;
  String phone;
  String gender;
  String bio;
  String location;
  String birthday;

  UserProfile({
    this.avatar = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.bio = '',
    this.location = '',
    this.birthday = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json['avatar'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      birthday: json['birthday'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'bio': bio,
      'location': location,
      'birthday': birthday,
    };
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) {
      return UserProfile();
    }
    try {
      final json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    } catch (e) {
      return UserProfile();
    }
  }
}
