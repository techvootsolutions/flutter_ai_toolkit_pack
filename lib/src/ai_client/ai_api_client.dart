import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiApiClient {
  static AiApiClient? _instance;

  final String apiToken;
  final String baseUrl;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  AiApiClient._internal({required this.apiToken, required this.baseUrl});

  static AiApiClient get instance {
    if (_instance == null) {
      throw Exception(
        'AiApiClient is not initialized. Call AiApiClient.initialize(...) in main() first.',
      );
    }
    return _instance!;
  }

  static void initialize({
    required String apiToken,
    String baseUrl = 'https://api-inference.huggingface.co/models',
  }) {
    _instance = AiApiClient._internal(apiToken: apiToken, baseUrl: baseUrl);
  }

  Future<dynamic> infer({
    required String model,
    required dynamic input,
    Map<String, dynamic>? options,
    bool returnRaw = false,
    VoidCallback? onStart,
    Function(dynamic resultOrError)? onComplete,
  }) async {
    dynamic result;
    final uri = Uri.parse('$baseUrl/$model');
    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'inputs': input, if (options != null) ...options});

    try {
      isLoading.value = true;
      onStart?.call();

      if (kDebugMode) {
        debugPrint('\nAI Text Inference Request');
        debugPrint('POST $uri');
        debugPrint('Headers: $headers');
        debugPrint('Body: $body');
      }

      final response = await http.post(uri, headers: headers, body: body);

      if (kDebugMode) {
        debugPrint('\nAI Text Inference Response');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        result = returnRaw ? response.body : jsonDecode(response.body);
        return result;
      } else {
        throw Exception(
          'AI API error: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      result = e;
      if (kDebugMode) {
        debugPrint('\nAI Text Inference Error');
        debugPrint(e.toString());
      }
      rethrow;
    } finally {
      isLoading.value = false;
      onComplete?.call(result);
    }
  }

  /// Image-based model inference
  Future<dynamic> inferWithImage({
    required String model,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
    VoidCallback? onStart,
    Function(dynamic resultOrError)? onComplete,
  }) async {
    dynamic result;
    final uri = Uri.parse('$baseUrl/$model');
    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': contentType,
    };

    try {
      isLoading.value = true;
      onStart?.call();

      if (kDebugMode) {
        debugPrint('\nAI Image Inference Request');
        debugPrint('POST $uri');
        debugPrint('Headers: $headers');
        debugPrint('ImageBytes: ${imageBytes.lengthInBytes} bytes');
      }

      final response = await http.post(uri, headers: headers, body: imageBytes);

      if (kDebugMode) {
        debugPrint('\nAI Image Inference Response');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception(
          'AI API error: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      result = e;
      if (kDebugMode) {
        debugPrint('\nAI Image Inference Error');
        debugPrint(e.toString());
      }
      rethrow;
    } finally {
      isLoading.value = false;
      onComplete?.call(result);
    }
  }
}
