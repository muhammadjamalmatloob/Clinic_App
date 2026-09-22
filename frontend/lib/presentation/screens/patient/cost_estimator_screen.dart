import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_header.dart';
import '../../../domain/entities/service_entity.dart';
import '../../providers/appointment_provider.dart';

class CostEstimatorScreen extends ConsumerStatefulWidget {
  const CostEstimatorScreen({super.key});

  @override
  ConsumerState<CostEstimatorScreen> createState() => _CostEstimatorScreenState();
}

class _CostEstimatorScreenState extends ConsumerState<CostEstimatorScreen> {
  ServiceEntity? _selectedProcedure;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

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
              child: Builder(
                builder: (context) {
                  final sw = MediaQuery.of(context).size.width;
                  final pad = sw > 800 ? (sw - 800) / 2 : 0.0;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.0 + pad, 16.0, 16.0 + pad, 16.0),
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
                      servicesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPlum)),
                        error: (error, _) => Center(child: Text('Error: $error')),
                        data: (services) {
                          if (services.isEmpty) {
                            return const Center(child: Text('No procedures available.'));
                          }
                          return DropdownButtonFormField<ServiceEntity>(
                            decoration: InputDecoration(
                              labelText: 'Select Procedure',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.5),
                            ),
                            value: _selectedProcedure,
                            items: services.map((ServiceEntity service) {
                              return DropdownMenuItem<ServiceEntity>(
                                value: service,
                                child: Text(service.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedProcedure = val;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 48),
                      if (_selectedProcedure != null) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text(
                                _selectedProcedure!.name,
                                style: const TextStyle(fontSize: 18, color: AppColors.primaryPlum),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text('Estimated Cost:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(
                                _selectedProcedure!.priceMin != null && _selectedProcedure!.priceMax != null
                                    ? 'Rs. ${_selectedProcedure!.priceMin!.toStringAsFixed(0)} - Rs. ${_selectedProcedure!.priceMax!.toStringAsFixed(0)}'
                                    : 'Cost info not available',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
