import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onnxruntime/onnxruntime.dart';

typedef OnnxCallback<T> = void Function(T result);
typedef OnnxError = void Function(Exception error);

class OnnxAiClient {
  OnnxAiClient._();
  static final OnnxAiClient instance = OnnxAiClient._();

  bool _isInitialized = false;
  final Map<String, OrtSession> _sessions = {};
  final Map<String, String> _modelPaths = {};

  /// Register a single model with a key and its path in assets
  void registerModel(String key, String assetPath) {
    if (_isInitialized) {
      throw Exception('Cannot register model after initialization.');
    }
    if (_modelPaths.containsKey(key)) {
      throw Exception('Model "$key" is already registered.');
    }
    _modelPaths[key] = assetPath;
  }

  /// Register multiple models at once
  void registerModels(Map<String, String> models) {
    for (final entry in models.entries) {
      registerModel(entry.key, entry.value);
    }
  }

  /// Initialize ONNX Runtime and preload all registered models
  Future<void> init() async {
    if (_isInitialized) return;

    OrtEnv.instance.init();

    for (final entry in _modelPaths.entries) {
      final assetPath = entry.value;
      final modelFileName = '${entry.key}.onnx';
      final modelFile = await _copyModelAndWeights(assetPath, modelFileName);
      final sessionOptions = OrtSessionOptions();
      // final session = OrtSession.fromFile(modelFile, sessionOptions);

      final rawAssetFile = await rootBundle.load(assetPath);
      final bytes = rawAssetFile.buffer.asUint8List();

      final session = OrtSession.fromBuffer(bytes, sessionOptions);
      _sessions[entry.key] = session;
    }

    _isInitialized = true;
  }

  /// Copy model and weight
  Future<File> _copyModelAndWeights(
    String assetPath,
    String modelFileName,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final modelFile = File('${tempDir.path}/$modelFileName');
    await modelFile.writeAsBytes(byteData.buffer.asUint8List());

    // Attempt to find and copy weights file (if referenced)
    final assetBase = assetPath.replaceAll('.onnx', '');
    final weightsAssetPath = '$assetBase.bin';
    final weightsFile = File(
      '${tempDir.path}/${modelFileName.replaceAll(".onnx", "_weights_1.bin")}',
    );

    try {
      final weightData = await rootBundle.load(weightsAssetPath);
      await weightsFile.writeAsBytes(weightData.buffer.asUint8List());
      print('[ONNX] Copied associated weights to ${weightsFile.path}');
    } catch (_) {
      print('[ONNX] No associated weights file found for $modelFileName');
    }

    return modelFile;
  }

  /// Copy model from assets to temp directory and return path
  Future<String> _copyAssetToTemp(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  /// Perform inference on a registered model using a simple Dart input
  Future<void> infer<T>({
    required String modelKey,
    required dynamic input,
    List<int>? shape,
    String inputName = 'input',
    OnnxCallback<T>? onComplete,
    VoidCallback? onStart,
    OnnxError? onError,
  }) async {
    try {
      if (!_isInitialized) throw Exception('OnnxAiClient not initialized.');
      if (!_sessions.containsKey(modelKey)) {
        throw Exception('Model "$modelKey" not found.');
      }

      onStart?.call();
      final session = _sessions[modelKey]!;
      final inferredShape = shape ?? _inferShape(input);

      final inputTensor = OrtValueTensor.createTensorWithDataList(
        input,
        inferredShape,
      );
      final outputs = await session.runAsync(OrtRunOptions(), {
        inputName: inputTensor,
      });

      final output = outputs?.first;
      final result = output?.value as T?;

      onComplete?.call(result as T);

      // Release resources
      inputTensor.release();
      outputs?.forEach((e) => e?.release());
    } catch (e) {
      if (e is Exception) {
        onError?.call(e);
      } else {
        rethrow;
      }
    }
  }

  /// Auto infer shape for 1D or 2D input
  List<int> _inferShape(dynamic input) {
    if (input is List<List>) {
      return [input.length, (input.first).length];
    } else if (input is List) {
      return [1, input.length];
    }
    throw Exception('Unsupported input type or shape inference failed.');
  }

  /// Unregister all models and release resources
  Future<void> dispose() async {
    for (final session in _sessions.values) {
      session.release();
    }
    _sessions.clear();
    _modelPaths.clear();
    _isInitialized = false;
    OrtEnv.instance.release();
  }
}

/// 1800 896 9999
