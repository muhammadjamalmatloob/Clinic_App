import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/app_header.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  bool _isUrdu = false;
  bool _notificationsEnabled = true;

  final TextEditingController _nameController = TextEditingController(text: 'Patient User');
  final TextEditingController _phoneController = TextEditingController(text: '+92 300 1234567');
  
  // Translation map
  String t(String englishText) {
    if (!_isUrdu) return englishText;
    switch (englishText) {
      case 'Profile & Settings': return 'پروفائل اور ترتیبات';
      case 'Update Profile': return 'پروفائل اپ ڈیٹ کریں';
      case 'Full Name': return 'پورا نام';
      case 'Phone Number': return 'فون نمبر';
      case 'Family Profiles': return 'فیملی پروفائلز';
      case 'Manage Dependents': return 'زیر کفالت افراد کا نظم کریں';
      case 'Vaccination Tracker (Kids)': return 'ویکسینیشن ٹریکر (بچوں)';
      case 'App Preferences': return 'ایپ کی ترجیحات';
      case 'Language (English / Urdu)': return 'زبان (انگریزی / اردو)';
      case 'Push Notifications': return 'پش اطلاعات';
      case 'Support & Feedback': return 'سپورٹ اور تاثرات';
      case 'Health & Wellness Blog': return 'ہیلتھ اور ویلنیس بلاگ';
      case 'Post-Visit Feedback': return 'دورے کے بعد کے تاثرات';
      case 'Admin Controls': return 'ایڈمن کنٹرولز';
      case 'Add New Admin': return 'نیا ایڈمن شامل کریں';
      case 'Invite a staff member': return 'اسٹاف ممبر کو مدعو کریں';
      case 'Save Changes': return 'تبدیلیاں محفوظ کریں';
      case 'Logout': return 'لاگ آؤٹ';
      default: return englishText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isUrdu ? 'پروفائل کو اپ ڈیٹ کر دیا گیا' : 'Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: t('Profile & Settings'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 32, color: AppColors.primaryPlum),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Guest User',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPlum),
                              ),
                              Text(
                                user?.phoneNumber ?? '',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

            // Profile Edit Form
            _buildSectionHeader(t('Update Profile')),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: t('Full Name'),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryPlum),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: t('Phone Number'),
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPlum),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (user?.role != UserRole.staff) ...[
              // Settings Sections
              _buildSectionHeader(t('Family Profiles')),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.child_care, color: AppColors.primaryPlum),
                      title: Text(t('Manage Dependents')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/profile/dependents');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.vaccines, color: AppColors.primaryPlum),
                      title: Text(t('Vaccination Tracker (Kids)')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/profile/vaccination');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(t('App Preferences')),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primaryPlum),
                      title: Text(t('Language (English / Urdu)')),
                      trailing: Switch(
                        value: _isUrdu,
                        onChanged: (val) => setState(() => _isUrdu = val),
                        activeColor: AppColors.primaryPlum,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: AppColors.primaryPlum),
                      title: Text(t('Push Notifications')),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (val) => setState(() => _notificationsEnabled = val),
                        activeColor: AppColors.primaryPlum,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(t('Support & Feedback')),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.health_and_safety, color: AppColors.primaryPlum),
                      title: Text(t('Health & Wellness Blog')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/profile/health_blog');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.feedback, color: AppColors.primaryPlum),
                      title: Text(t('Post-Visit Feedback')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/profile/feedback');
                      },
                    ),
                  ],
                ),
              ),
            ],
            
            if (user?.role == UserRole.staff) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(t('Admin Controls')),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.primaryPlum),
                  title: Text(t('Add New Admin')),
                  subtitle: Text(t('Invite a staff member')),
                  trailing: const Icon(Icons.add_circle, color: AppColors.primaryPlum),
                  onTap: () {
                    context.push('/profile/add_admin');
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: Text(t('Save Changes')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPlum,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/auth');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(t('Logout'), style: const TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
