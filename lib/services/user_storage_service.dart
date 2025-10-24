import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserStorageService {
  static const String _userKey = 'user_profile_data';
  
  // Save user profile data locally
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'userId': user.userId,
        'name': user.name,
        'email': user.email,
        'experience': user.experience,
        'skills': user.skills.toList(),
        'resumeFileName': user.resumeFileName,
        'resumeFilePath': user.resumeFilePath,
        'phoneNumber': user.phoneNumber,
        'location': user.location,
        'summary': user.summary,
        'workExperience': user.workExperience,
        'education': user.education,
        'portfolioUrl': user.portfolioUrl,
        'githubUrl': user.githubUrl,
        'linkedinUrl': user.linkedinUrl,
        'isGuest': user.isGuest,
        'authProvider': user.authProvider,
        'photoUrl': user.photoUrl,
      });
      
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Load user profile data from local storage
  static Future<UserModel?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel(
          userId: userData['userId'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          experience: userData['experience'] ?? 'Entry-Level',
          skills: (userData['skills'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{},
          resumeFileName: userData['resumeFileName'] ?? '',
          resumeFilePath: userData['resumeFilePath'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          location: userData['location'] ?? '',
          summary: userData['summary'] ?? '',
          workExperience: (userData['workExperience'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
          education: (userData['education'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
          portfolioUrl: userData['portfolioUrl'] ?? '',
          githubUrl: userData['githubUrl'] ?? '',
          linkedinUrl: userData['linkedinUrl'] ?? '',
          isGuest: userData['isGuest'] ?? false,
          authProvider: userData['authProvider'],
          photoUrl: userData['photoUrl'],
        );
        
        return user;
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }
  
  // Clear user profile data
  static Future<void> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      // Handle error silently
    }
  }
}