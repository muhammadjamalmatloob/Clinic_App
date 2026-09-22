import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../../domain/entities/ai_entity.dart';
import '../../providers/ai_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/local_db/database_helper.dart';

class AiSymptomCheckerScreen extends ConsumerStatefulWidget {
  const AiSymptomCheckerScreen({super.key});

  @override
  ConsumerState<AiSymptomCheckerScreen> createState() => _AiSymptomCheckerScreenState();
}

class _AiSymptomCheckerScreenState extends ConsumerState<AiSymptomCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [
    ChatMessage(
      role: 'model', 
      content: 'Hello! I am the Clinic AI Assistant. Please describe your symptoms and I will help guide you.'
    )
  ];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await DatabaseHelper.instance.getChatMessages();
    if (msgs.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(msgs.map((m) => ChatMessage(
          role: m['role'] as String,
          content: m['content'] as String,
        )));
      });
      _scrollToBottom();
    } else {
      await DatabaseHelper.instance.saveChatMessage('model', _messages.first.content);
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final userMsg = ChatMessage(role: 'user', content: text);
    setState(() {
      _messages.add(userMsg);
      _controller.clear();
      _isLoading = true;
    });
    
    DatabaseHelper.instance.saveChatMessage(userMsg.role, userMsg.content);
    _scrollToBottom();
    
    try {
      final reply = await ref.read(aiRepositoryProvider).chat(_messages);
      if (mounted) {
        final modelMsg = ChatMessage(role: 'model', content: reply);
        setState(() {
          _messages.add(modelMsg);
          _isLoading = false;
        });
        DatabaseHelper.instance.saveChatMessage(modelMsg.role, modelMsg.content);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ChatMessage(role: 'model', content: 'I am sorry, but I am unable to connect to my services right now.');
        setState(() {
          _messages.add(errorMsg);
          _isLoading = false;
        });
        DatabaseHelper.instance.saveChatMessage(errorMsg.role, errorMsg.content);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Builder(
          builder: (context) {
            final sw = MediaQuery.of(context).size.width;
            final pad = sw > 800 ? (sw - 800) / 2 : 0.0;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: const AppHeader(
                    title: 'AI Symptom Checker',
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.0 + pad, vertical: 8.0),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                       return const Align(
                         alignment: Alignment.centerLeft,
                         child: Padding(
                           padding: EdgeInsets.only(bottom: 16, left: 16),
                           child: CircularProgressIndicator(color: AppColors.primaryPlum),
                         )
                       );
                    }
                    
                    final msg = _messages[index];
                    final isUser = msg.role == 'user';
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: isUser 
                            ? Text(
                                msg.content,
                                style: const TextStyle(
                                  color: AppColors.primaryPlum,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              )
                            : MarkdownBody(
                                data: msg.content,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                                  h1: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                                  h2: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                                  h3: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                  strong: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                  listBullet: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0 + pad, right: 16.0 + pad, top: 16.0, bottom: 120.0),
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
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPlum,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _isLoading ? null : _sendMessage,
                        ),
                      ).animate().scale(delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ],
            );
          },
        ),
      ),
    );
  }
}

