import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

typedef FacialCallback<T> = void Function(T result);
typedef FacialError = void Function(Exception error);

class FacialAIKitClient {
  FacialAIKitClient._();
  static final FacialAIKitClient instance = FacialAIKitClient._();

  bool _isInitialized = false;

  final Map<String, OrtSession> _sessions = {};
  final Map<String, String> _modelPaths = {};

  /// Register ONNX models
  void registerModels(Map<String, String> models) {
    if (_isInitialized) throw Exception('Cannot register after initialization.');
    _modelPaths.addAll(models);
  }

  /// Initialize ONNX environment and load sessions
  Future<void> init() async {
    if (_isInitialized) return;

    OrtEnv.instance.init();

    registerModels({
      'face_detector': 'packages/flutter_ai_toolkit_pack/assets/aimodels/face_detector.onnx',
      'beauty_gan': 'packages/flutter_ai_toolkit_pack/assets/aimodels/beauty_gan.onnx',
    });

    for (final entry in _modelPaths.entries) {
      final modelPath = await _copyAssetToTemp(entry.value, '${entry.key}.onnx');
      final session = OrtSession.fromFile(modelPath, OrtSessionOptions());
      _sessions[entry.key] = session;
    }

    _isInitialized = true;
  }

  /// Detect → Enhance → Composite
  Future<Uint8List> processFace(Uint8List inputImageBytes) async {
    if (!_isInitialized) throw Exception('FacialAIKitClient not initialized');

    // Decode image
    final inputImage = img.decodeImage(inputImageBytes);
    if (inputImage == null) throw Exception('Failed to decode image');

    // 1. Face detection
    final faceBox = await _detectFace(inputImage);
    if (faceBox == null) throw Exception('No face detected');

    // 2. Crop face
    final croppedFace = img.copyCrop(inputImage, x: faceBox.left.toInt(), y:faceBox.top.toInt(), width:faceBox.width.toInt(), height:faceBox.height.toInt());
    final croppedBytes = Uint8List.fromList(img.encodeJpg(croppedFace));

    // 3. Apply enhancement (e.g., BeautyGAN)
    final enhancedFace = await _beautifyFace(croppedBytes);

    // 4. Composite back onto original
    final finalImage = img.Image.from(inputImage);
    final overlay = img.decodeImage(enhancedFace);
    if (overlay != null) {
      img.compositeImage(finalImage, overlay, dstX: faceBox.left.toInt(), dstY: faceBox.top.toInt());
    }

    return Uint8List.fromList(img.encodeJpg(finalImage));
  }

  Future<Rect?> _detectFace(img.Image input) async {
    final session = _sessions['face_detector'];
    if (session == null) throw Exception('face_detector model not loaded');

    final inputTensor = _imageToTensor(input, [1, 3, 240, 320]);

    final outputs = await session.runAsync(
      OrtRunOptions(),
      {'input': inputTensor},
    );

    final output = outputs?.first?.value as List?;
    if (output == null || output.isEmpty) return null;

    final face = output.first as List; // Assuming [x1, y1, x2, y2, score]
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in face) {
      final x = point[0];
      final y = point[1];
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    final left = minX;
    final top = minY;
    final right = maxX;
    final bottom = maxY;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Future<Uint8List> _beautifyFace(Uint8List faceBytes) async {
    final session = _sessions['beauty_gan'];
    if (session == null) throw Exception('beauty_gan model not loaded');

    final faceImg = img.decodeImage(faceBytes);
    if (faceImg == null) throw Exception('Failed to decode cropped face');
    final inputNames = session.inputNames.map((e) => e).toList();
    print('🔥 beauty_gan model input names: $inputNames');
    // final tensor = _imageToTensor(faceImg, [1, 3, 256, 256]);
    final tensorA = _imageToTensor(faceImg, [1, 3, 256, 256]);

    final tensorB = OrtValueTensor.createTensorWithDataList(
      Float32List(1 * 3 * 256 * 256),
      [1, 3, 256, 256],
    );

    final outputs = await session.runAsync(OrtRunOptions(), {
      'img_A': tensorA,
      'img_B': tensorB,
    });
    // final outputs = await session.runAsync(OrtRunOptions(), {
    //   'img_A': tensor,
    //   'img_B': tensor, // using same image as fallback
    // },);
    final enhanced = outputs?.first?.value;

    // Convert back to image
    final outputFace = _tensorToImage1(enhanced, faceImg.width, faceImg.height);
    return Uint8List.fromList(img.encodeJpg(outputFace));
  }
  /// Resize before tensor conversion
  img.Image _resizeImage(img.Image image) {
    return img.copyResize(image, width: 320, height: 240); // match model dimensions
  }
  /// Converts image to normalized float32 tensor
  OrtValueTensor _imageToTensor(img.Image image, List<int> shape) {
    final resizedImage = _resizeImage(image); // resize here

    final pixels = resizedImage.getBytes();
    final floatPixels = Float32List(pixels.length);

    for (int i = 0; i < pixels.length; i++) {
      floatPixels[i] = pixels[i] / 255.0;
    }

    return OrtValueTensor.createTensorWithDataList(floatPixels, shape);
  }

  img.Image _tensorToImage(dynamic tensorData, int width, int height) {
    final flat = tensorData as List<double>;
    final imgBytes = Uint8List.fromList(
      List<int>.generate(
        width * height * 3,
            (i) => (flat[i] * 255).clamp(0, 255).toInt(),
      ),
    );
    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: imgBytes.buffer,
      order: img.ChannelOrder.rgb,
      numChannels: 3,
      format: img.Format.uint8,
    );
  }

  img.Image _tensorToImage1(dynamic tensorData, int width, int height, {int? upscaleWidth, int? upscaleHeight}) {
    final data = tensorData as List<List<List<List<double>>>>;
    final channels = data[0]; // shape: [3][H][W]

    final red = channels[0];
    final green = channels[1];
    final blue = channels[2];

    final imgBytes = Uint8List(width * height * 3);

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        imgBytes[index++] = (red[y][x] * 255).clamp(0, 255).toInt();
        imgBytes[index++] = (green[y][x] * 255).clamp(0, 255).toInt();
        imgBytes[index++] = (blue[y][x] * 255).clamp(0, 255).toInt();
      }
    }

    // Create the base image
    img.Image result = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: imgBytes.buffer,
      order: img.ChannelOrder.rgb,
      numChannels: 3,
      format: img.Format.uint8,
    );

    // Resize if upscale dimensions are provided
    if (upscaleWidth != null && upscaleHeight != null) {
      result = img.copyResize(result, width: upscaleWidth, height: upscaleHeight, interpolation: img.Interpolation.linear);
    }

    return result;
  }


  /// Copy model from assets to temp dir
  Future<File> _copyAssetToTemp(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

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
