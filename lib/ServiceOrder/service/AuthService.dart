import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  static const String clientId = '3e7e7865-a8b1-4406-b144-f2fbf821f31f';
  static const String tenantId = '2edfec93-4fa8-411f-b480-7a816d4ae02d';
  static const String redirectUri = 'com.example.sfcdashboard://auth';
  static const String authority = 'https://login.microsoftonline.com/2edfec93-4fa8-411f-b480-7a816d4ae02d';
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'https://graph.microsoft.com/User.Read'
  ];

  

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> login() async {
    try {
      final authUrl =
          '$authority/oauth2/v2.0/authorize?client_id=$clientId'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(_scopes.join(' '))}'
          '&prompt=login';

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'com.example.sfcdashboard', 
      );
      print('Authentication result: $result'); 

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No code returned');

    
      const tokenUrl = '$authority/oauth2/v2.0/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'scope': _scopes.join(' '),
        },
      );

      if (response.statusCode != 200) {
        print('Token response: ${response.body}'); 
        throw Exception('Failed to get token: ${response.body}');
      }

      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];
      if (accessToken == null) throw Exception('No access token returned');

      await _storage.write(key: 'access_token', value: accessToken);
      
      if (tokenData['refresh_token'] != null) {
        await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
      }

    
      final userInfo = await _getUserInfo(accessToken);

      if (userInfo != null) {
        await _storage.write(key: 'user_info', value: json.encode(userInfo));
      }
      
      return userInfo;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'UserId': data['id'] ?? '0',
          'Name': data['displayName'] ?? 'Unknown User',
          'Email': data['mail'] ?? data['userPrincipalName'] ?? 'unknown@email.com',
          'PhotoUrl': 'https://ui-avatars.com/api/?name=${(data['displayName'] ?? 'User').toString().replaceAll(' ', '+')}',
        };
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;
     
      try {
        await _getUserInfo(token);
        return true;
      } catch (e) {
    
        final refreshed = await _refreshToken();
        return refreshed != null;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userInfo = await _storage.read(key: 'user_info');
      if (userInfo != null) {
        return json.decode(userInfo);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;
   
      try {
        await _getUserInfo(token);
        return token;
      } catch (e) {
   
        return await _refreshToken();
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await getAccessToken();
          return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      const tokenUrl = '$authority/oauth2/v2.0/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'scope': _scopes.join(' '),
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);
        final accessToken = tokenData['access_token'];
        if (accessToken != null) {
          await _storage.write(key: 'access_token', value: accessToken);
         
          if (tokenData['refresh_token'] != null) {
            await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
          }
          
          return accessToken;
        }
      }
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }
}