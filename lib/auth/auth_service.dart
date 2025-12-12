import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'loggedInToken';
  static const String _userRoleKey = 'userRole';
  static const String _userEmailKey = 'userEmail';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _isLoggedInKey = 'isLoggedIn';

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLoggedInData({
    required String token,
    required String role,
    required String email,
    String? userId,
    String? userName,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userRoleKey, value: role);
    await _storage.write(key: _userEmailKey, value: email);

    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }

    if (userName != null) {
      await _storage.write(key: _userNameKey, value: userName);
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
  }

  Future<void> deleteAccount() async {
    await _storage.deleteAll();
  }

  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;

      try {
        final parts = token.split('.');
        if (parts.length != 3) return true;

        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(decoded);

        if (payloadMap['exp'] != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(
            payloadMap['exp'] * 1000,
          );
          return expiry.isAfter(DateTime.now());
        }
      } catch (e) {
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String?>> getUserData() async {
    try {
      return {
        'token': await getToken(),
        'role': await getUserRole(),
        'email': await getUserEmail(),
        'userId': await getUserId(),
        'name': await getUserName(),
      };
    } catch (e) {
      return {};
    }
  }
}

String base64UrlDecode(String input) {
  String output = input.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
  }

  return utf8.decode(base64Url.decode(output));
}

class EmployeeUserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? profileImage;
  final String? bio;
  final String userType;
  final String? skills;
  final String? experience;
  final String? education;
  final String? companyName;
  final String? companyWebsite;
  final String? companySize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmployeeUserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.profileImage,
    this.bio,
    required this.userType,
    this.skills,
    this.experience,
    this.education,
    this.companyName,
    this.companyWebsite,
    this.companySize,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeUserProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeUserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      profileImage: json['profile_image'],
      bio: json['bio'],
      userType: json['user_type'] ?? '',
      skills: json['skills'],
      experience: json['experience'],
      education: json['education'],
      companyName: json['company_name'],
      companyWebsite: json['company_website'],
      companySize: json['company_size'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'profile_image': profileImage,
      'bio': bio,
      'user_type': userType,
      'skills': skills,
      'experience': experience,
      'education': education,
      'company_name': companyName,
      'company_website': companyWebsite,
      'company_size': companySize,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayRole => userType == 'employee' ? 'Employee' : 'Employer';
  bool get isEmployee => userType == 'employee';
  bool get isEmployer => userType == 'employer';
}

class EmployerUserProfile {
  final String id;
  final String name;
  final String email;
  final String userType;
  final String? phone;
  final String? address;
  final String? bio;
  final int? experienceYears;
  final List<String>? skills;
  final List<dynamic>? experiences;
  final String? companyName;
  final String? companyLocation;
  final String? companyWebsite;
  final String? companyDescription;
  final String? cvPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  EmployerUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone,
    this.address,
    this.bio,
    this.experienceYears,
    this.skills,
    this.experiences,
    this.companyName,
    this.companyLocation,
    this.companyWebsite,
    this.companyDescription,
    this.cvPath,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
  });

  factory EmployerUserProfile.fromJson(Map<String, dynamic> json) {
    final userData = json;
    final profileData = json['profile'] ?? {};

    List<String>? skillsList;
    if (profileData['skills'] != null) {
      if (profileData['skills'] is List) {
        skillsList = List<String>.from(
          profileData['skills'].map((x) => x.toString()),
        );
      } else if (profileData['skills'] is String) {
        // If skills is stored as JSON string
        try {
          final parsed = jsonDecode(profileData['skills']) as List;
          skillsList = List<String>.from(parsed.map((x) => x.toString()));
        } catch (e) {
          skillsList = [profileData['skills'].toString()];
        }
      }
    }

    List<dynamic>? experiencesList;
    if (profileData['experiences'] != null) {
      if (profileData['experiences'] is List) {
        experiencesList = profileData['experiences'];
      } else if (profileData['experiences'] is String) {
        try {
          experiencesList = jsonDecode(profileData['experiences']);
        } catch (e) {
          experiencesList = [];
        }
      }
    }

    return EmployerUserProfile(
      id: userData['id']?.toString() ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      userType: userData['user_type'] ?? 'employee',
      phone: profileData['phone'],
      address: profileData['address'],
      bio: profileData['bio'],
      experienceYears: profileData['experience_years'] != null
          ? int.tryParse(profileData['experience_years'].toString())
          : null,
      skills: skillsList,
      experiences: experiencesList,
      companyName: profileData['company_name'],
      companyLocation: profileData['company_location'],
      companyWebsite: profileData['company_website'],
      companyDescription: profileData['company_description'],
      cvPath: profileData['cv_path'],
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : null,
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'])
          : null,
      isActive: userData['is_active'] ?? true,
    );
  }

  String get displayRole => userType == 'employee' ? 'Employee' : 'Employer';

  bool get isEmployee => userType == 'employee';
  bool get isEmployer => userType == 'employer';

  String? get companySize {
    if (companyDescription?.contains('1-10') == true) return '1-10';
    if (companyDescription?.contains('11-50') == true) return '11-50';
    if (companyDescription?.contains('51-200') == true) return '51-200';
    if (companyDescription?.contains('201-500') == true) return '201-500';
    if (companyDescription?.contains('500+') == true) return '500+';
    return null;
  }
}
