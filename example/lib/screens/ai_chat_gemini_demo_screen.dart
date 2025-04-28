import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit_pack/flutter_ai_toolkit_pack.dart';
import 'package:provider/provider.dart';

class AIChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void addUserMessage(String message) {
    if (message.trim().isEmpty) return;

    _messages.add(ChatMessage(
      message: message,
      role: MessageUserRole.sender,
    ));
    notifyListeners();

    _sendMessageToAI(message);
  }

  Future<void> _sendMessageToAI(String message) async {
    _isTyping = true;
    _messages.add(ChatMessage(
      message: "",
      role: MessageUserRole.receiver,
      isLoading: true,
    ));
    notifyListeners();

    try {
      final response = await AiGeminiClient.instance.generateContent(
        content: message,
        onStart: () => print("Request started"),
      );

      // Remove loading message
      _messages.removeLast();

      // Add actual AI response
      _messages.add(ChatMessage(
        message: response['candidates'][0]["content"]["parts"][0]["text"],
        role: MessageUserRole.receiver,
      ));
    } catch (e) {
      // Remove loading message
      _messages.removeLast();

      // Add error message
      _messages.add(ChatMessage(
        message: "Sorry, something went wrong. Please try again. Error: ${e.toString()}",
        role: MessageUserRole.receiver,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}

class ThemeManager extends ChangeNotifier {
  AIChatTheme _currentTheme = AIChatTheme.organicTheme();

  AIChatTheme get currentTheme => _currentTheme;

  void setTheme(AIChatTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIChatController()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Chat Demo'),
              backgroundColor: themeManager.currentTheme.backgroundColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () => _showThemeSelector(context),
                ),
              ],
            ),
            body: ChatScreenBody(theme: themeManager.currentTheme),
          );
        },
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => ThemeSelectorWidget(themeManager: themeManager),
    );
  }
}

class ThemeSelectorWidget extends StatelessWidget {
  final ThemeManager themeManager;

  const ThemeSelectorWidget({Key? key, required this.themeManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Theme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildThemeOption(
                context,
                'Default',
                AIChatTheme.defaultTheme(),
                Colors.blue,
              ),
              _buildThemeOption(
                context,
                'Dark',
                AIChatTheme.darkTheme(),
                Color(0xFF121212),
              ),
              _buildThemeOption(
                context,
                'Futuristic',
                AIChatTheme.futuristicTheme().copyWith(showTimestamps: true),
                Colors.purple,
              ),
              _buildThemeOption(
                context,
                'Minimalist',
                AIChatTheme.minimalistTheme(),
                Colors.teal,
              ),
              _buildThemeOption(
                context,
                'Organic',
                AIChatTheme.organicTheme(),
                Colors.tealAccent,
              ),
              _buildThemeOption(
                context,
                'Glassmorphic',
                AIChatTheme.glassmorphicTheme(),
                Colors.tealAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context,
      String name,
      AIChatTheme theme,
      Color color
      ) {
    return GestureDetector(
      onTap: () {
        themeManager.setTheme(theme);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }
}

class ChatScreenBody extends StatelessWidget {
  final AIChatTheme theme;

  const ChatScreenBody({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: theme.chatBackgroundDecoration ??
          BoxDecoration(color: theme.backgroundColor),
      child: Column(
        children: [
          Expanded(
            child: Consumer<AIChatController>(
              builder: (context, controller, _) {
                return ListView.builder(
                  reverse: true, // Show newest messages at the bottom
                  padding: const EdgeInsets.all(8.0),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                    controller.messages[controller.messages.length - 1 - index];
                    return AIChatBubble(
                      message: message,
                      theme: theme,
                      customLoadingIndicator: AnimatedTypingIndicator(
                        color: theme.receiverBubbleStyle.textColor,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          _ChatInputBar(theme: theme),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  final AIChatTheme theme;

  const _ChatInputBar({Key? key, required this.theme}) : super(key: key);

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    if (_textController.text.trim().isEmpty) {
      return;
    }

    final controller = Provider.of<AIChatController>(context, listen: false);
    controller.addUserMessage(_textController.text.trim());
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.theme.inputBarDecoration ??
          BoxDecoration(
            color: widget.theme.inputBarBackgroundColor,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: widget.theme.inputTextStyle,
              decoration: widget.theme.inputDecoration ??
                  InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: widget.theme.hintTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: widget.theme.inputBarBackgroundColor.withOpacity(
                        0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
              onSubmitted: (_) => _sendMessage(context),
            ),
          ),
          const SizedBox(width: 8.0),
          Material(
            color: widget.theme.sendButtonColor,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _sendMessage(context),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.send,
                  color: widget.theme.sendButtonIconColor,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}