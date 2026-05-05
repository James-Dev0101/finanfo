import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/core/error/app_exception.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/core/widgets/app_text_field.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_notifier.dart';
import 'package:finanfo/features/auth/presentation/widgets/currency_onboarding_step.dart';
import 'package:finanfo/features/auth/presentation/widgets/onboarding_step_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Step index: 0 = name+email, 1 = passwords, 2 = currency
  int _step = 0;
  static const int _totalSteps = 3;

  // Step 1 controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 2 controllers
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Step 3 state
  String _selectedCurrency = AppConfig.defaultCurrency;

  // Form keys per step
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation between steps
  // ---------------------------------------------------------------------------

  void _next() {
    final valid = switch (_step) {
      0 => _step0Key.currentState?.validate() ?? false,
      1 => _step1Key.currentState?.validate() ?? false,
      _ => true,
    };
    if (!valid) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          currency: _selectedCurrency,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError(state.error!);
    }
    // GoRouter redirect handles navigation on successful auth.
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

    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    final isLastStep = _step == _totalSteps - 1;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: isLoading ? null : _back,
              )
            : null,
        title: Text(
          'Create account',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: onBg,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // ── Step indicator ────────────────────────────────────────────
              OnboardingStepIndicator(
                totalSteps: _totalSteps,
                currentStep: _step,
              ),
              SizedBox(height: 32.h),

              // ── Step content ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: switch (_step) {
                        0 => _StepNameEmail(
                            formKey: _step0Key,
                            nameCtrl: _nameCtrl,
                            emailCtrl: _emailCtrl,
                          ),
                        1 => _StepPasswords(
                            formKey: _step1Key,
                            passwordCtrl: _passwordCtrl,
                            confirmCtrl: _confirmCtrl,
                            obscurePassword: _obscurePassword,
                            obscureConfirm: _obscureConfirm,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onToggleConfirm: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        _ => CurrencyOnboardingStep(
                            selectedCurrency: _selectedCurrency,
                            onCurrencySelected: (code) =>
                                setState(() => _selectedCurrency = code),
                          ),
                      },
                    ),
                  ),
                ),
              ),

              // ── Actions ───────────────────────────────────────────────────
              SizedBox(height: 16.h),
              AppButton(
                label: isLastStep ? 'Create Account' : 'Next',
                onPressed: isLoading ? null : _next,
                isLoading: isLoading && isLastStep,
              ),
              SizedBox(height: 16.h),

              // ── Sign-in link ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14.sp, color: muted),
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step sub-widgets
// ---------------------------------------------------------------------------

class _StepNameEmail extends StatelessWidget {
  const _StepNameEmail({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you?',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: onBg,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tell us your name and email to get started.',
            style: TextStyle(fontSize: 14.sp, color: muted, height: 1.5),
          ),
          SizedBox(height: 32.h),
          AppTextField(
            controller: nameCtrl,
            label: 'Full name',
            hint: 'Jane Doe',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.trim().length < 2) return 'Name is too short';
              return null;
            },
          ),
          SizedBox(height: 16.h),
          AppTextField(
            controller: emailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _StepPasswords extends StatelessWidget {
  const _StepPasswords({
    required this.formKey,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secure your account',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: onBg,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose a strong password with at least 8 characters.',
            style: TextStyle(fontSize: 14.sp, color: muted, height: 1.5),
          ),
          SizedBox(height: 32.h),
          AppTextField(
            controller: passwordCtrl,
            label: 'Password',
            hint: '••••••••',
            obscureText: obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: onTogglePassword,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Use at least 8 characters';
              return null;
            },
          ),
          SizedBox(height: 16.h),
          AppTextField(
            controller: confirmCtrl,
            label: 'Confirm password',
            hint: '••••••••',
            obscureText: obscureConfirm,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: onToggleConfirm,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
