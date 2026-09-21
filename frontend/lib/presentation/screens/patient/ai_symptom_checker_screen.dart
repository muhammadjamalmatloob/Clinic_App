import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';

class AiSymptomCheckerScreen extends StatefulWidget {
  const AiSymptomCheckerScreen({super.key});

  @override
  State<AiSymptomCheckerScreen> createState() => _AiSymptomCheckerScreenState();
}

class _AiSymptomCheckerScreenState extends State<AiSymptomCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [
    'Hello! I am the Clinic AI Assistant. Please describe your symptoms and I will help guide you.'
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add('You: ${_controller.text}');
      _messages.add('AI: Based on your symptoms, we recommend booking a General Consultation. Please remember this is not medical advice.');
      _controller.clear();
    });
    
    // Auto-scroll to the bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            const AppHeader(
              title: 'AI Symptom Checker',
            ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final isUser = _messages[index].startsWith('You:');
                    final msgText = _messages[index].replaceAll('You: ', '').replaceAll('AI: ', '');
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            msgText,
                            style: TextStyle(
                              color: isUser ? AppColors.primaryPlum : AppColors.textPrimary,
                              fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
                child: GlassCard(
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type your symptoms...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPlum,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ).animate().scale(delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
