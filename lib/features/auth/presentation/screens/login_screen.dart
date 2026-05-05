import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/error/app_exception.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/core/widgets/app_text_field.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_notifier.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/auth/presentation/widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError(state.error!);
    }
    // Navigation is handled by the auth guard / redirect in GoRouter.
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError(state.error!);
    }
  }

  Future<void> _showForgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email and we\'ll send you a reset link.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordReset(email);
              if (!mounted) return;
              final state = ref.read(authNotifierProvider);
              if (state.hasError) {
                _showError(state.error!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent. Check your inbox.'),
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
  }

  void _showError(Object error) {
    final message = error is AppException ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifierState = ref.watch(authNotifierProvider);
    final isLoading = notifierState.isLoading;

    // Watch auth state — if user becomes authenticated, router redirect handles
    // navigation; nothing to do here explicitly.
    ref.listen(authStateProvider, (_, next) {
      if (next case AsyncData(:final value) when value != null) {
        if (mounted) context.go('/dashboard');
      }
    });

    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 56.h),

                // ── Logo / app name ─────────────────────────────────────────
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 36.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Finanfo',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Track your finances, effortlessly.',
                  style: TextStyle(fontSize: 14.sp, color: muted),
                ),
                SizedBox(height: 48.h),

                // ── Email ───────────────────────────────────────────────────
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // ── Password ────────────────────────────────────────────────
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                SizedBox(height: 8.h),

                // ── Forgot password ─────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : _showForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 4.h),
                    ),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Sign-in button ──────────────────────────────────────────
                AppButton(
                  label: 'Sign In',
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                ),
                SizedBox(height: 24.h),

                // ── Divider ─────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'or',
                        style: TextStyle(fontSize: 13.sp, color: muted),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider)),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Google button ───────────────────────────────────────────
                GoogleSignInButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  isLoading: false,
                ),
                SizedBox(height: 32.h),

                // ── Register link ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14.sp, color: muted),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : () => context.go('/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
