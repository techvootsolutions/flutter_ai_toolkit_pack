import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit_pack/flutter_ai_toolkit_pack.dart';
import 'package:image_picker/image_picker.dart';

class FaceEnhancerScreen extends StatefulWidget {
  const FaceEnhancerScreen({super.key});

  @override
  _FaceEnhancerScreenState createState() => _FaceEnhancerScreenState();
}

class _FaceEnhancerScreenState extends State<FaceEnhancerScreen> {
  Uint8List? originalImage;
  Uint8List? enhancedImage;
  bool isProcessing = false;

  Future<void> _pickAndProcessImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      isProcessing = true;
      originalImage = null;
      enhancedImage = null;
    });

    final bytes = await picked.readAsBytes();

    try {
      await FacialAIKitClient.instance.init();
      final processed = await FacialAIKitClient.instance.processFace(bytes);

      setState(() {
        originalImage = bytes;
        enhancedImage = processed;
      });
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to process image: $e')));
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Enhancer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isProcessing ? null : _pickAndProcessImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            if (isProcessing) const CircularProgressIndicator(),
            if (originalImage != null) ...[
              const Text('Original Image'),
              Image.memory(originalImage!, height: 350, width: double.infinity),
            ],
            if (enhancedImage != null) ...[
              const SizedBox(height: 20),
              const Text('Enhanced Image'),
              Image.memory(enhancedImage!, height: 350, width: double.infinity),
            ],
          ],
        ),
      ),
    );
  }
}
