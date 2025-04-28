import 'package:flutter/material.dart';

enum MessageUserRole { sender, receiver }

class ChatMessage {
  final String message;
  final MessageUserRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.message,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum BubbleShape {
  classic,
  pill,
  angular,
  angularInverse,
  cloud,
  thinking,
  modern,
  modernInverse,
}

class AIChatBubbleStyle {
  final Color backgroundColor;
  final Color textColor;
  final BubbleShape shape;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxShadow? shadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;

  const AIChatBubbleStyle({
    required this.backgroundColor,
    required this.textColor,
    this.shape = BubbleShape.classic,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    this.shadow,
    this.borderRadius,
    this.border,
    this.borderColor,
    this.borderWidth = 0,
    this.gradient,
    this.boxShadow,
    this.textStyle,
  });

  BorderRadius getShapeBorderRadius() {
    if (borderRadius != null) return borderRadius!;

    switch (shape) {
      case BubbleShape.classic:
        return BorderRadius.circular(18);
      case BubbleShape.pill:
        return BorderRadius.circular(24);
      case BubbleShape.angular:
        return BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      case BubbleShape.angularInverse:
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      case BubbleShape.cloud:
        return BorderRadius.circular(24);
      case BubbleShape.thinking:
        return BorderRadius.circular(12);
      case BubbleShape.modern:
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      case BubbleShape.modernInverse:
        return BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      default:
        return BorderRadius.circular(18);
    }
  }

  AIChatBubbleStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    BubbleShape? shape,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadow? shadow,
    BorderRadius? borderRadius,
    Border? border,
    Color? borderColor,
    double? borderWidth,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    TextStyle? textStyle,
  }) {
    return AIChatBubbleStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      shape: shape ?? this.shape,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      gradient: gradient ?? this.gradient,
      boxShadow: boxShadow ?? this.boxShadow,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}

class AIChatTheme {
  final AIChatBubbleStyle senderBubbleStyle;
  final AIChatBubbleStyle receiverBubbleStyle;
  final Color backgroundColor;
  final Color inputBarBackgroundColor;
  final Color hintTextColor;
  final Color sendButtonColor;
  final Color sendButtonIconColor;
  final TextStyle inputTextStyle;
  final Widget? loadingIndicator;
  final Widget? userAvatar;
  final Widget? aiAvatar;
  final bool showAvatars;
  final bool showTimestamps;
  final TextStyle? timestampStyle;
  final InputDecoration? inputDecoration;
  final TextStyle? titleStyle;
  final BoxDecoration? inputBarDecoration;
  final BoxDecoration? chatBackgroundDecoration;

  const AIChatTheme({
    required this.senderBubbleStyle,
    required this.receiverBubbleStyle,
    this.backgroundColor = Colors.white,
    this.inputBarBackgroundColor = Colors.white,
    this.hintTextColor = Colors.grey,
    this.sendButtonColor = Colors.blue,
    this.sendButtonIconColor = Colors.white,
    this.inputTextStyle = const TextStyle(color: Colors.black),
    this.loadingIndicator,
    this.userAvatar,
    this.aiAvatar,
    this.showAvatars = true,
    this.showTimestamps = false,
    this.timestampStyle,
    this.inputDecoration,
    this.titleStyle,
    this.inputBarDecoration,
    this.chatBackgroundDecoration,
  });

  factory AIChatTheme.defaultTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFFF0F0F0),
        textColor: Colors.black,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  factory AIChatTheme.darkTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFF2C2C2C),
        textColor: Colors.white,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121212),
      inputBarBackgroundColor: const Color(0xFF1E1E1E),
      hintTextColor: Colors.grey,
      sendButtonColor: Colors.blueAccent,
      inputTextStyle: const TextStyle(color: Colors.white),
      chatBackgroundDecoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
    );
  }

  factory AIChatTheme.futuristicTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFF7B42F6),
        textColor: Colors.white,
        shape: BubbleShape.angularInverse,
        gradient: const LinearGradient(
          colors: [Color(0xFF7B42F6), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B42F6).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
        shape: BubbleShape.modernInverse,
        borderWidth: 1,
        borderColor: const Color(0xFF42A5F5),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      inputBarBackgroundColor: const Color(0xFF1A1A1A),
      hintTextColor: Colors.grey,
      sendButtonColor: const Color(0xFF7B42F6),
      inputTextStyle: const TextStyle(color: Colors.white),
      chatBackgroundDecoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // image: DecorationImage(
        //   image: AssetImage('assets/images/grid_background.png'),
        //   fit: BoxFit.cover,
        //   opacity: 0.1,
        // ),
      ),
      aiAvatar: const CircleAvatar(
        backgroundColor: Color(0xFF42A5F5),
        child: Icon(Icons.android, color: Colors.white),
      ),
      userAvatar: const CircleAvatar(
        backgroundColor: Color(0xFF7B42F6),
        child: Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  factory AIChatTheme.minimalistTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.black,
        textColor: Colors.white,
        shape: BubbleShape.pill,
        boxShadow: [],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFFF0F0F0),
        textColor: Colors.black,
        shape: BubbleShape.pill,
        boxShadow: [],
      ),
      backgroundColor: Colors.white,
      inputBarBackgroundColor: Colors.white,
      hintTextColor: Colors.grey,
      sendButtonColor: Colors.black,
      sendButtonIconColor: Colors.white,
      inputTextStyle: const TextStyle(color: Colors.black),
      showAvatars: false,
      showTimestamps: false,
      inputBarDecoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  factory AIChatTheme.organicTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFF4CAF50),
        textColor: Colors.white,
        shape: BubbleShape.cloud,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: const Color(0xFFE8F5E9),
        textColor: Colors.black87,
        shape: BubbleShape.thinking,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      inputBarBackgroundColor: const Color(0xFFF1F8E9),
      hintTextColor: Colors.green.shade800.withValues(alpha: 0.6),
      sendButtonColor: const Color(0xFF4CAF50),
      inputTextStyle: const TextStyle(color: Colors.black87),
      aiAvatar: const CircleAvatar(
        backgroundColor: Color(0xFF81C784),
        child: Icon(Icons.eco, color: Colors.white),
      ),
      userAvatar: const CircleAvatar(
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  factory AIChatTheme.glassmorphicTheme() {
    return AIChatTheme(
      senderBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.blue.withValues(alpha: 0.7),
        textColor: Colors.white,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      receiverBubbleStyle: AIChatBubbleStyle(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        textColor: Colors.white,
        shape: BubbleShape.classic,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderWidth: 1,
        borderColor: Colors.white.withValues(alpha: 0.2),
      ),
      backgroundColor: Colors.transparent,
      inputBarBackgroundColor: Colors.black.withValues(alpha: 0.3),
      hintTextColor: Colors.white.withValues(alpha: 0.6),
      sendButtonColor: Colors.blue.withValues(alpha: 0.7),
      inputTextStyle: const TextStyle(color: Colors.white),
      chatBackgroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.withValues(alpha: 0.6),
            Colors.purpleAccent.withValues(alpha: 0.6),
          ],
        ),
      ),
      inputBarDecoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      aiAvatar: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
      userAvatar: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.7),
        child: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  AIChatTheme copyWith({
    AIChatBubbleStyle? userBubbleStyle,
    AIChatBubbleStyle? aiBubbleStyle,
    Color? backgroundColor,
    Color? inputBarBackgroundColor,
    Color? hintTextColor,
    Color? sendButtonColor,
    Color? sendButtonIconColor,
    TextStyle? inputTextStyle,
    Widget? loadingIndicator,
    Widget? userAvatar,
    Widget? aiAvatar,
    bool? showAvatars,
    bool? showTimestamps,
    TextStyle? timestampStyle,
    InputDecoration? inputDecoration,
    TextStyle? titleStyle,
    BoxDecoration? inputBarDecoration,
    BoxDecoration? chatBackgroundDecoration,
  }) {
    return AIChatTheme(
      senderBubbleStyle: userBubbleStyle ?? this.senderBubbleStyle,
      receiverBubbleStyle: aiBubbleStyle ?? this.receiverBubbleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      inputBarBackgroundColor: inputBarBackgroundColor ?? this.inputBarBackgroundColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonIconColor: sendButtonIconColor ?? this.sendButtonIconColor,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      loadingIndicator: loadingIndicator ?? this.loadingIndicator,
      userAvatar: userAvatar ?? this.userAvatar,
      aiAvatar: aiAvatar ?? this.aiAvatar,
      showAvatars: showAvatars ?? this.showAvatars,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      timestampStyle: timestampStyle ?? this.timestampStyle,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      titleStyle: titleStyle ?? this.titleStyle,
      inputBarDecoration: inputBarDecoration ?? this.inputBarDecoration,
      chatBackgroundDecoration: chatBackgroundDecoration ?? this.chatBackgroundDecoration,
    );
  }
}

class AIChatBubble extends StatelessWidget {
  final ChatMessage message;
  final AIChatTheme theme;
  final Widget? customLoadingIndicator;
  final Widget? Function(BuildContext, ChatMessage)? bubbleBuilder;

  const AIChatBubble({
    super.key,
    required this.message,
    required this.theme,
    this.customLoadingIndicator,
    this.bubbleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Allow for completely custom bubble implementation
    if (bubbleBuilder != null) {
      final customBubble = bubbleBuilder!(context, message);
      if (customBubble != null) {
        return customBubble;
      }
    }

    final isUser = message.role == MessageUserRole.sender;
    final bubbleStyle = isUser ? theme.senderBubbleStyle : theme.receiverBubbleStyle;
    final avatar = isUser ? theme.userAvatar : theme.aiAvatar;

    // Create border if specified
    BoxBorder? border;
    if (bubbleStyle.borderColor != null && bubbleStyle.borderWidth > 0) {
      border = Border.all(
        color: bubbleStyle.borderColor!,
        width: bubbleStyle.borderWidth,
      );
    } else if (bubbleStyle.border != null) {
      border = bubbleStyle.border;
    }

    Widget bubbleContent;
    if (message.isLoading) {
      bubbleContent = customLoadingIndicator ??
          theme.loadingIndicator ??
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUser ? theme.senderBubbleStyle.textColor : theme.receiverBubbleStyle.textColor,
              ),
            ),
          );
    } else {
      TextStyle effectiveTextStyle = TextStyle(
        color: bubbleStyle.textColor,
        fontSize: bubbleStyle.fontSize,
        fontWeight: bubbleStyle.fontWeight,
        fontFamily: bubbleStyle.fontFamily,
      );

      if (bubbleStyle.textStyle != null) {
        effectiveTextStyle = bubbleStyle.textStyle!;
      }

      bubbleContent = Text(
        message.message,
        style: effectiveTextStyle,
      );
    }

    Widget bubble = Container(
      margin: bubbleStyle.margin,
      padding: bubbleStyle.padding,
      decoration: BoxDecoration(
        color: bubbleStyle.backgroundColor,
        borderRadius: bubbleStyle.getShapeBorderRadius(),
        boxShadow: bubbleStyle.boxShadow,
        gradient: bubbleStyle.gradient,
        border: border,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: bubbleContent,
    );

    // Add timestamp if enabled
    if (theme.showTimestamps) {
      bubble = Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubble,
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: bubbleStyle.margin.left,
              right: bubbleStyle.margin.right,
            ),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: theme.timestampStyle ??
                  TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      );
    }

    if (theme.showAvatars && avatar != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isUser
              ? [bubble, const SizedBox(width: 8), avatar]
              : [avatar, const SizedBox(width: 8), bubble],
        ),
      );
    } else {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    String formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return formattedTime;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $formattedTime';
    } else {
      return '${timestamp.day}/${timestamp.month}, $formattedTime';
    }
  }
}

class AnimatedTypingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedTypingIndicator({
    Key? key,
    this.color = Colors.grey,
    this.size = 8.0,
  }) : super(key: key);

  @override
  State<AnimatedTypingIndicator> createState() => _AnimatedTypingIndicatorState();
}

class _AnimatedTypingIndicatorState extends State<AnimatedTypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _repeatAnimation(_controllers[i]);
        }
      });
    }
  }

  void _repeatAnimation(AnimationController controller) {
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
