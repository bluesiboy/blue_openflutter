import 'package:blue_openflutter/models/user_profile.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile;
  UserProfileProvider(this._profile);
  UserProfile get profile => _profile;

  static Future<UserProfileProvider> load() async {
    final profile = await UserProfile.load();
    return UserProfileProvider(profile);
  }

  Future<void> updateAvatar(String avatar) async {
    _profile.avatar = avatar;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _profile.name = name;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    _profile.email = email;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updatePhone(String phone) async {
    _profile.phone = phone;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateGender(String gender) async {
    _profile.gender = gender;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateBio(String bio) async {
    _profile.bio = bio;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateLocation(String location) async {
    _profile.location = location;
    await _profile.save();
    notifyListeners();
  }

  Future<void> updateBirthday(String birthday) async {
    _profile.birthday = birthday;
    await _profile.save();
    notifyListeners();
  }

  Future<void> reload() async {
    _profile = await UserProfile.load();
    notifyListeners();
  }
}
