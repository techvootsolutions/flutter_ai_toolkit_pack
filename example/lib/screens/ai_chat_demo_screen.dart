import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit_pack/flutter_ai_toolkit_pack.dart';

class AiChatDemoScreen extends StatefulWidget {
  const AiChatDemoScreen({super.key});

  @override
  State<AiChatDemoScreen> createState() => _AiChatDemoScreenState();
}

class _AiChatDemoScreenState extends State<AiChatDemoScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', message: prompt));
      _isTyping = true;
      _controller.clear();
    });

    try {
      final result = await AiApiClient.instance.infer(
        model: 'mistralai/Mistral-7B-Instruct-v0.1',
        input: prompt,
        onStart: () {
          setState(() {
            _isTyping = true;
          });
        },
        onComplete: (res) {
          setState(() {
            _isTyping = false;
            if (res is Exception) {
              _messages.add(
                _ChatMessage(role: 'error', message: '❌ ${res.toString()}'),
              );
            } else {
              _messages.add(
                _ChatMessage(
                  role: 'ai',
                  message: res[0]['generated_text'].toString(),
                ),
              );
            }
          });
          _scrollToBottom();
        },
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(role: 'error', message: '❌ ${e.toString()}'),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    final isError = msg.role == 'error';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isError
                  ? Colors.red.shade100
                  : isUser
                  ? Colors.blue.shade100
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Text(
          msg.message,
          style: TextStyle(
            color: isError ? Colors.red.shade900 : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user', 'ai', or 'error'
  final String message;

  _ChatMessage({required this.role, required this.message});
}
