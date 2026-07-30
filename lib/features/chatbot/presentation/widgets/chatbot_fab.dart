import 'package:flutter/material.dart';
import 'package:kitabghar/features/chatbot/presentation/widgets/chatbot_panel.dart';

/// The small circular chat toggle button — appears above the Sell "+"
/// button on Home, and alone (in that same spot) on every other tab.
class ChatbotFab extends StatelessWidget {
  const ChatbotFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChatbotPanel.show(context),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}