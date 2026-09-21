import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import 'package:go_router/go_router.dart';

class CostEstimatorScreen extends StatefulWidget {
  const CostEstimatorScreen({super.key});

  @override
  State<CostEstimatorScreen> createState() => _CostEstimatorScreenState();
}

class _CostEstimatorScreenState extends State<CostEstimatorScreen> {
  String? _selectedProcedure;
  
  final Map<String, String> _costs = {
    'General Consultation': 'Rs. 1500 - Rs. 2000',
    'Ultrasound (Routine)': 'Rs. 2500',
    'Detailed Scan': 'Rs. 4000',
    'Normal Delivery': 'Rs. 40,000 - Rs. 50,000',
    'C-Section': 'Rs. 80,000 - Rs. 100,000',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'Procedure Cost Estimator',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Get a transparent estimate for your procedures.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Procedure',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
              ),
              items: _costs.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedProcedure = val;
                });
              },
            ),
            const SizedBox(height: 48),
            if (_selectedProcedure != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                    children: [
                      Text(
                        _selectedProcedure!,
                        style: const TextStyle(fontSize: 18, color: AppColors.primaryPlum),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text('Estimated Cost:', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        _costs[_selectedProcedure!]!,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '* Actual costs may vary depending on complications or additional medicines.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
            ]
          ],
        ),
      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
