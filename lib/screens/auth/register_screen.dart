import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _cleanError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้งานแล้ว';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'weak-password':
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        case 'operation-not-allowed':
          return 'ยังไม่ได้เปิด Email/Password Login ใน Firebase';
        case 'network-request-failed':
          return 'เชื่อมต่ออินเทอร์เน็ตไม่สำเร็จ';
        default:
          return error.message ?? error.code;
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _register() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );

      await Future.delayed(const Duration(milliseconds: 300));

      final user = ref.read(currentUserProvider) ??
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('สมัครสำเร็จแต่ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
      }

      final initial = UserModel.initial(
        uid: user.uid,
        email: user.email ?? _emailController.text.trim(),
        displayName: _nameController.text.trim(),
      );

      await ref
          .read(profileNotifierProvider.notifier)
          .createInitialProfile(initial);

      ref.invalidate(userProfileProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('สมัครสมาชิกสำเร็จ! กรุณากรอกข้อมูลโปรไฟล์'),
            duration: Duration(seconds: 2),
          ),
        );

      context.go('/profile-setup');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(e);
      });

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(_cleanError(e)),
            duration: const Duration(seconds: 3),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLoading = ref.watch(authNotifierProvider).isLoading ||
        ref.watch(profileNotifierProvider).isLoading;
    final isLoading = _isSubmitting || providerLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: isLoading ? null : () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สร้างบัญชีใหม่',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'กรอกข้อมูลเพื่อเริ่มต้นติดตามโภชนาการ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'ชื่อที่แสดง'),
                  decoration: const InputDecoration(
                    labelText: 'ชื่อที่แสดง',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmController,
                  enabled: !isLoading,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                PrimaryButton(
                  label: 'สมัครสมาชิก',
                  onPressed: isLoading ? null : _register,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'มีบัญชีแล้ว? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/login'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}