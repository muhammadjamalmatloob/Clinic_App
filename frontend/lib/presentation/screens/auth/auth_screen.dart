import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/glass_card.dart';
import '../../../presentation/widgets/custom_toast.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    HapticFeedback.lightImpact();
    if (_isLogin) {
      _login();
    } else {
      _signup();
    }
  }

  void _login() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      final user = ref.read(authProvider);
      if (user?.role == UserRole.staff) {
        context.go('/staff');
      } else {
        context.go('/patient');
      }
    } else if (mounted) {
      CustomToast.showSuccess(context, 'Success');
    }
  }

  void _signup() async {
    setState(() => _isLoading = true);
    final errorMsg = await ref.read(authProvider.notifier).register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );
    setState(() => _isLoading = false);
    
    if (errorMsg == null && mounted) {
      CustomToast.showSuccess(context, 'Success');
      setState(() => _isLogin = true);
    } else if (mounted) {
      CustomToast.showError(context, errorMsg ?? 'Signup failed');
    }
  }

  void _continueWithGoogle() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    
    final success = await ref.read(authProvider.notifier).googleSignIn();
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      final user = ref.read(authProvider);
      if (user?.role == UserRole.staff) {
        context.go('/staff');
      } else {
        context.go('/patient');
      }
    } else if (mounted) {
      CustomToast.showSuccess(context, 'Success');
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Reset Password', style: TextStyle(color: AppColors.primaryPlum)),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email, color: AppColors.primaryPlum),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPlum),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) return;
                
                Navigator.pop(context);
                setState(() => _isLoading = true);
                final error = await ref.read(authProvider.notifier).resetPassword(email);
                setState(() => _isLoading = false);
                
                if (mounted) {
                  if (error == null) {
                    CustomToast.showSuccess(context, 'Success');
                  } else {
                    CustomToast.showError(context, error);
                  }
                }
              },
              child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/clinic.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.favorite, size: 40, color: AppColors.primaryPink),
                        ),
                      ),
                    ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPlum,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(target: _isLogin ? 1 : 0).fadeIn(duration: 300.ms),
                  
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to access your health vault' : 'Join us to manage your health seamlessly',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Custom Toggle
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isLogin = true);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isLogin ? AppColors.primaryPlum : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: _isLogin ? [
                                  BoxShadow(color: AppColors.primaryPlum.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: _isLogin ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isLogin = false);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isLogin ? AppColors.primaryPlum : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: !_isLogin ? [
                                  BoxShadow(color: AppColors.primaryPlum.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: !_isLogin ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // Form Area
                  GlassCard(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLogin) ...[
                            _buildTextField('Full Name', Icons.person, _nameController),
                            const SizedBox(height: 16),
                            _buildTextField('Phone Number', Icons.phone, _phoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                          ],
                          _buildTextField('Email Address', Icons.email, _emailController, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField('Password', Icons.lock, _passwordController, isPassword: true),
                          
                            if (_isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading ? null : _showForgotPasswordDialog,
                                  child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                                ),
                              )
                            else
                            const SizedBox(height: 24),
                            
                          // Submit Button
                          GestureDetector(
                            onTap: _isLoading ? null : _submit,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryPlum, AppColors.primaryPink],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPink.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Create Account',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // Google Sign in
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.5))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('OR', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: _isLoading ? null : _continueWithGoogle,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 36, color: Colors.black87),
                          const SizedBox(width: 8),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.primaryPlum, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: AppColors.primaryPlum.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: AppColors.primaryPlum),
          suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryPlum.withValues(alpha: 0.5)),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
