import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit_pack/flutter_ai_toolkit_pack.dart';
import 'package:image_picker/image_picker.dart';

import 'common/ai_feature_scaffold.dart';

class AiImageLabelingScreen extends StatefulWidget {
  const AiImageLabelingScreen({super.key});

  @override
  State<AiImageLabelingScreen> createState() => _AiImageLabelingScreenState();
}

class _AiImageLabelingScreenState extends State<AiImageLabelingScreen> {
  Uint8List? _imageBytes;
  String _result = '';

  Future<void> _pickImageAndLabel() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    _imageBytes = bytes;

    await AiApiClient.instance.inferWithImage(
      model: 'google/vit-base-patch16-224',
      imageBytes: bytes,
      onStart: () => setState(() => _result = 'Labeling...'),
      onComplete: (res) {
        _result = res is Exception ? 'Error: ${res.toString()}' : res.toString();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiFeatureScaffold(
      title: 'Image Labeling',
      result: _result,
      customButtonText: 'Pick Image',
      onCustomSubmit: _pickImageAndLabel,
      resultWidget: _imageBytes != null ? Column(
        children: [
          Text(_result ?? '', style: const TextStyle(fontSize: 16)),
          SizedBox(height: 20,),
          Image.memory(_imageBytes!),
        ],
      ) : null,
    );
  }
}
