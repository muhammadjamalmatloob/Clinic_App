import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';

class BroadcastAnnouncementScreen extends ConsumerStatefulWidget {
  const BroadcastAnnouncementScreen({super.key});

  @override
  ConsumerState<BroadcastAnnouncementScreen> createState() => _BroadcastAnnouncementScreenState();
}

class _BroadcastAnnouncementScreenState extends ConsumerState<BroadcastAnnouncementScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  void _sendBroadcast() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    
    try {
      final user = ref.read(authProvider);
      await ref.read(clinicRepositoryProvider).createAnnouncement(
        createdById: user!.id,
        message: _messageController.text.trim(),
        audience: 'all_patients',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement broadcasted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to broadcast: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.campaign, size: 80, color: AppColors.primaryPlum),
            const SizedBox(height: 16),
            const Text(
              'Send Notification',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryPlum),
            ),
            const SizedBox(height: 8),
            const Text(
              'This message will be shown on the dashboards of all patients.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'E.g., The doctor is currently dealing with an emergency. Expected delay is 30 minutes.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPlum, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendBroadcast,
              icon: _isSending ? const SizedBox() : const Icon(Icons.send),
              label: _isSending 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Send Broadcast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPlum,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
