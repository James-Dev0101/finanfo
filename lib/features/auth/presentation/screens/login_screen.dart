import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/error/app_exception.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/core/widgets/app_text_field.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_notifier.dart';
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

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await runWithLoading(
      context,
      () => ref
          .read(authNotifierProvider.notifier)
          .signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text),
    );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) _showError(state.error!);
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) _showError(state.error!);
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
              'Enter your email and we will send you a reset link.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: emailCtrl,
              hint: 'you@example.com',
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
              await runWithLoading(
                context,
                () => ref
                    .read(authNotifierProvider.notifier)
                    .sendPasswordReset(email),
              );
              if (!mounted) return;
              final state = ref.read(authNotifierProvider);
              if (state.hasError) {
                _showError(state.error!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset email sent. Check your inbox.',
                    ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifierState = ref.watch(authNotifierProvider);
    final isLoading = notifierState.isLoading;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final onBg = isDark
        ? AppColors.darkOnBackground
        : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final muted = isDark
        ? AppColors.darkOnSurfaceMuted
        : AppColors.lightOnSurfaceMuted;
    final iconColor = isDark
        ? AppColors.darkOnSurfaceMuted
        : AppColors.lightOnSurfaceMuted;
    final dividerColor = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: constraints.maxWidth > 520 ? 420 : double.infinity,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 32.h),
                          Center(
                            child: Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 32.w,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            'Finanfo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w700,
                              color: onBg,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Sign in to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, color: muted),
                          ),
                          SizedBox(height: 36.h),
                          AppTextField(
                            controller: _emailCtrl,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: iconColor,
                              size: 20.w,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          AppTextField(
                            controller: _passwordCtrl,
                            hint: 'Password',
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: iconColor,
                              size: 20.w,
                            ),
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: iconColor,
                                size: 20.w,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 6.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading ? null : _showForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 4.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          SizedBox(height: 22.h),
                          AppButton(
                            label: 'Sign In',
                            onPressed: isLoading ? null : _signIn,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(child: Divider(color: dividerColor)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: muted,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: dividerColor)),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          GoogleSignInButton(
                            onPressed: isLoading ? null : _signInWithGoogle,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 28.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: muted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.go('/register'),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
