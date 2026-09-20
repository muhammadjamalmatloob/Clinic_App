import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';

class AiSymptomCheckerScreen extends StatefulWidget {
  const AiSymptomCheckerScreen({super.key});

  @override
  State<AiSymptomCheckerScreen> createState() => _AiSymptomCheckerScreenState();
}

class _AiSymptomCheckerScreenState extends State<AiSymptomCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [
    'Hello! I am the Clinic AI Assistant. Please describe your symptoms and I will help guide you.'
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add('You: ${_controller.text}');
      _messages.add('AI: Based on your symptoms, we recommend booking a General Consultation. Please remember this is not medical advice.');
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'AI Symptom Checker',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 10), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
