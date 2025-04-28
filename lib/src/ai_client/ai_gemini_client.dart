import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiGeminiClient {
  static AiGeminiClient? _instance;

  final String apiKey;
  final String baseUrl;
  final Map<String, String>? additionalHeaders;
  final Map<String, dynamic>? additionalParams;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  AiGeminiClient._internal({
    required this.apiKey,
    required this.baseUrl,
    this.additionalHeaders,
    this.additionalParams,
  });

  static AiGeminiClient get instance {
    if (_instance == null) {
      throw Exception(
        'GeminiProvider is not initialized. Call GeminiProvider.initialize(...) in main() first.',
      );
    }
    return _instance!;
  }

  static void initialize({
    required String apiKey,
    String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    Map<String, String>? additionalHeaders,
    Map<String, dynamic>? additionalParams,
  }) {
    _instance = AiGeminiClient._internal(
      apiKey: apiKey,
      baseUrl: baseUrl,
      additionalHeaders: additionalHeaders,
      additionalParams: additionalParams,
    );
  }

  Future<dynamic> generateContent({
    required dynamic content,
    Map<String, dynamic>? options,
    bool returnRaw = false,
    VoidCallback? onStart,
    Function(dynamic resultOrError)? onComplete,
  }) async {
    dynamic result;
    final uri = Uri.parse('$baseUrl?key=$apiKey');
    final headers = {
      'Content-Type': 'application/json',
      ...(additionalHeaders ?? {}),
    };

    // Format the content based on Gemini API requirements
    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {'text': content is String ? content : jsonEncode(content)}
          ]
        }
      ],
      ...(additionalParams ?? {}),
      if (options != null) ...options,
    };

    final body = jsonEncode(requestBody);

    try {
      isLoading.value = true;
      onStart?.call();

      if (kDebugMode) {
        debugPrint('\nGemini API Request');
        debugPrint('POST $uri');
        debugPrint('Headers: $headers');
        debugPrint('Body: $body');
      }

      final response = await http.post(uri, headers: headers, body: body);

      if (kDebugMode) {
        debugPrint('\nGemini API Response');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        result = returnRaw ? response.body : jsonDecode(response.body);
        return result;
      } else {
        throw Exception('Gemini API error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      result = e;
      if (kDebugMode) {
        debugPrint('\nGemini API Error');
        debugPrint(e.toString());
      }
      rethrow;
    } finally {
      isLoading.value = false;
      onComplete?.call(result);
    }
  }

  /// Generate content with image input
  Future<dynamic> generateContentWithImage({
    required Uint8List imageBytes,
    String? promptText,
    String mimeType = 'image/jpeg',
    Map<String, dynamic>? options,
    bool returnRaw = false,
    VoidCallback? onStart,
    Function(dynamic resultOrError)? onComplete,
  }) async {
    dynamic result;
    // Using the vision model endpoint
    final String visionEndpoint = baseUrl.replaceAll('gemini-pro', 'gemini-pro-vision');
    final uri = Uri.parse('$visionEndpoint?key=$apiKey');

    final headers = {
      'Content-Type': 'application/json',
      ...(additionalHeaders ?? {}),
    };

    // Convert image bytes to base64
    final String base64Image = base64Encode(imageBytes);

    // Format the request with image
    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            if (promptText != null && promptText.isNotEmpty)
              {'text': promptText},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      ...(additionalParams ?? {}),
      if (options != null) ...options,
    };

    final body = jsonEncode(requestBody);

    try {
      isLoading.value = true;
      onStart?.call();

      if (kDebugMode) {
        debugPrint('\nGemini Vision API Request');
        debugPrint('POST $uri');
        debugPrint('Headers: $headers');
        debugPrint('Body: ${body.substring(0, 100)}... (truncated)');
      }

      final response = await http.post(uri, headers: headers, body: body);

      if (kDebugMode) {
        debugPrint('\nGemini Vision API Response');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        result = returnRaw ? response.body : jsonDecode(response.body);
        return result;
      } else {
        throw Exception('Gemini Vision API error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      result = e;
      if (kDebugMode) {
        debugPrint('\nGemini Vision API Error');
        debugPrint(e.toString());
      }
      rethrow;
    } finally {
      isLoading.value = false;
      onComplete?.call(result);
    }
  }
}