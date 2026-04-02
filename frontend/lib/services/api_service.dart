import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Change this to your backend URL when deployed ───────────────────
  static const String _baseUrl = 'http://127.0.0.1:8000'; // Localhost for Web/Desktop

  // ── Emotion Analysis (text) ──────────────────────────────────────────
  static Future<Map<String, dynamic>> analyzeVibeText(String text) async {
    final uri = Uri.parse('$_baseUrl/emotion/analyze-vibe');
    final request = http.MultipartRequest('POST', uri)
      ..fields['text'] = text;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Emotion analysis failed: ${response.body}');
  }

  // ── Emotion Analysis (audio) ─────────────────────────────────────────
  static Future<Map<String, dynamic>> analyzeVibeAudio(File audioFile) async {
    final uri = Uri.parse('$_baseUrl/emotion/analyze-vibe');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Audio analysis failed: ${response.body}');
  }

  // ── Wisdom Reframe ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> wisdomReframe({
    required String stressor,
    String? emotion,
    int? stressLevel,
  }) async {
    final uri = Uri.parse('$_baseUrl/wisdom/wisdom-reframe');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'stressor': stressor,
        if (emotion != null) 'emotion': emotion,
        if (stressLevel != null) 'stress_level': stressLevel,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Wisdom reframe failed: ${response.body}');
  }

  // ── Raaga Recommendation ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRaagaForStress(int stressLevel) async {
    final uri = Uri.parse(
      '$_baseUrl/raagas/raaga-recommendation?stress_level=$stressLevel',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Raaga recommendation failed: ${response.body}');
  }

  // ── Health Check ─────────────────────────────────────────────────────
  static Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
