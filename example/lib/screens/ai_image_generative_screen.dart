import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit_pack/flutter_ai_toolkit_pack.dart';

import 'common/ai_feature_scaffold.dart';

class AiImageGenerativeScreen extends StatefulWidget {
  const AiImageGenerativeScreen({super.key});

  @override
  State<AiImageGenerativeScreen> createState() =>
      _AiImageGenerativeScreenState();
}

class _AiImageGenerativeScreenState extends State<AiImageGenerativeScreen> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _generatedImage;
  String? _error;

  void _generateImage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    final bytes = await AiApiClient.instance.infer(
      model: 'stabilityai/stable-diffusion-2',
      input: prompt,
      onStart: () {
        setState(() {
          _generatedImage = null;
          _error = null;
        });
      },
      onComplete: (res) {
        // if (res is Uint8List) {
        _generatedImage = base64Decode(res);
        // } else {
        //   _error = 'Failed to generate image';
        // }
        setState(() {});
      },
      returnRaw: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiFeatureScaffold(
      title: 'Image Generation',
      controller: _controller,
      onSubmit: _generateImage,
      resultWidget:
          _generatedImage != null
              ? Image.memory(
                _generatedImage!,
                color: Colors.lightGreen,
                height: 100,
                width: 100,
              )
              : _error != null
              ? Text(_error!)
              : null,
    );
  }
}
