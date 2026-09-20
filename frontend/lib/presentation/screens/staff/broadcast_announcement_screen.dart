import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class BroadcastAnnouncementScreen extends StatefulWidget {
  const BroadcastAnnouncementScreen({super.key});

  @override
  State<BroadcastAnnouncementScreen> createState() => _BroadcastAnnouncementScreenState();
}

class _BroadcastAnnouncementScreenState extends State<BroadcastAnnouncementScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  void _sendBroadcast() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isSending = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement broadcasted successfully to all waiting patients!')),
      );
      Navigator.of(context).pop();
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
              'This message will be sent as a push notification to all patients currently waiting in the live queue.',
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
                  ? const CircularProgressIndicator(color: Colors.white)
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
