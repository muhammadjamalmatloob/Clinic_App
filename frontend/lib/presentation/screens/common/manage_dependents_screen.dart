import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ManageDependentsScreen extends StatelessWidget {
  const ManageDependentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dependents'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryPink,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Ali Ahmad'),
              subtitle: const Text('Son - 5 years old'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryPlum),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Dependent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPlum,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}
