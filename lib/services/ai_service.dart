import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_insight.dart';

class AiService {
  AiService({required this.baseUrl, required this.authToken, required this.consent});

  final String baseUrl;
  final String? authToken;
  final bool consent;

  Future<AiInsight> fetchInsights(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/ai/insights');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
        if (consent) 'X-AI-Consent': 'true',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('AI request failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AiInsight(
      summary: data['financial_summary'] as String? ?? '',
      analysis: data['spending_analysis'] as String? ?? '',
      observations: List<String>.from(data['key_observations'] as List? ?? []),
      predictions: data['predictions'] as String? ?? '',
      suggestions: List<String>.from(data['actionable_suggestions'] as List? ?? []),
      educationTips: List<String>.from(data['financial_education_tips'] as List? ?? []),
    );
  }
}
