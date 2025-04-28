import 'package:flutter/material.dart';

class AiFeatureDemoScreen extends StatelessWidget {
  const AiFeatureDemoScreen({super.key});

  final List<_AiFeature> features = const [
    _AiFeature(
      title: '🗨️ AI Generative Chat',
      description: 'Chat with an LLM model like Mistral, GPT, etc.',
      route: '/chat',
    ),
    _AiFeature(
      title: '🤖 AI Gemini Generative Chat',
      description: 'Interact with Google\'s powerful Gemini LLM for natural conversations, creative writing, problem-solving, and information retrieval. Supports multiple themes and real-time responses.',
      route: '/chat-gemini',
    ),
    _AiFeature(
      title: '🎨 AI Image Generation',
      description: 'Generate images from text prompts (e.g., Stable Diffusion)',
      route: '/image-generation',
    ),
    _AiFeature(
      title: '🖌️ AI Image Editing',
      description: 'Modify or inpaint images using AI tools',
      route: '/image-editing',
    ),
    _AiFeature(
      title: '🏷️ AI Image Labeling',
      description: 'Label and recognize objects or scenes in an image',
      route: '/image-labeling',
    ),
    _AiFeature(
      title: '🎨 AI Image Facial Kit',
      description: 'Beautify face in images using AI tools',
      route: '/facial-kit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter AI Toolkit Pack'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, feature.route),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  title: Text(feature.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(feature.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiFeature {
  final String title;
  final String description;
  final String route;

  const _AiFeature({
    required this.title,
    required this.description,
    required this.route,
  });
}
