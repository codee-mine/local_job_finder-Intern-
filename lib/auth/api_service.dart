import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_job_finder/auth/auth_service.dart';

class ApiService {
  final baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$baseUrl$endpoint');

      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      http.Response response;

      switch (method.toLowerCase()) {
        case 'get':
          response = await http.get(url, headers: headers);
          break;
        case 'post':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'put':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'delete':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported format');
      }

      if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again');
      }

      if (response.body.isEmpty) {
        return {'statusCode': response.statusCode, 'body': {}};
      }

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String userType,
  ) async {
    return _makeRequest('post', '/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
    });
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    return await _makeRequest('post', '/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest('get', '/profile', null);
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await _makeRequest('put', '/profile', profileData);
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$baseUrl/auth/upload-profile-image');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authentication'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imagePath),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(responseData),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await _makeRequest('post', '/auth/reset-password', {
      'current_password': currentPassword,
      'new_passwird': newPassword,
    });
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    return await _makeRequest('delete', '/auth/delete-account', {
      'password': password,
    });
  }

  Future<Map<String, dynamic>> validatePassword(String password) async {
    return await _makeRequest('post', '/auth/validate-password', {
      'password': password,
    });
  }
}
