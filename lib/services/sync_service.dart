import 'dart:convert';

import 'package:http/http.dart' as http;

class SyncService {
  SyncService({required this.baseUrl, required this.authToken});

  final String baseUrl;
  final String? authToken;

  Future<Map<String, dynamic>> sync(Map<String, dynamic> payload) async {
    if (authToken == null) {
      throw Exception('Missing auth token');
    }
    final uri = Uri.parse('$baseUrl/sync');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('Sync failed');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
