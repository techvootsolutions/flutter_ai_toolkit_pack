import 'package:flutter/material.dart';

class AiFeatureScaffold extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final VoidCallback? onSubmit;
  final VoidCallback? onCustomSubmit;
  final String? result;
  final Widget? resultWidget;
  final String customButtonText;

  const AiFeatureScaffold({
    super.key,
    required this.title,
    this.controller,
    this.onSubmit,
    this.onCustomSubmit,
    this.result,
    this.resultWidget,
    this.customButtonText = 'Submit',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (controller != null)
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter input...',
                ),
                minLines: 1,
                maxLines: 4,
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onSubmit ?? onCustomSubmit,
              child: Text(customButtonText),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: resultWidget ??
                  SingleChildScrollView(
                    child: Text(result ?? '', style: const TextStyle(fontSize: 16)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
