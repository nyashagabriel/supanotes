import 'package:flutter/material.dart';
import 'package:supanotes/data/constants/app_strings.dart';
import 'package:supanotes/data/constants/app_constants.dart';
import 'package:supanotes/ui/pages/notes_page.dart';
import 'package:supanotes/ui/pages/home/home_controller.dart';
import 'package:supanotes/ui/widgets/custom_button.dart';
import 'package:supanotes/ui/widgets/custom_text_field.dart';
import 'package:supanotes/ui/widgets/custom_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await _controller.authenticate(context);

    if (!mounted) return;

    if (success) {
      scaffoldMessenger.clearSnackBars();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesPage()),
      );
    } else {
      CustomSnackBar.show(
        context,
        message: AppStrings.authFailed,
        type: SnackBarType.error,
      );
    }
  }

  Widget _buildTabButton(AuthMode mode, String label, ThemeData theme) {
    final isSelected = _controller.authMode == mode;
    return GestureDetector(
      onTap: () => _controller.toggleAuthMode(mode),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.r10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(AppAlphas.a60),
                    blurRadius: AppLayout.shadowBlurRadius,
                    offset: const Offset(0, AppLayout.shadowOffsetY),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface.withAlpha(AppAlphas.a150),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLogin = _controller.authMode == AuthMode.login;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24, 
              vertical: AppSpacing.s24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.note_alt_rounded,
                    size: AppLayout.iconLarge,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  
                  Text(
                    isLogin ? AppStrings.welcomeBack : AppStrings.welcomeNew,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: AppLayout.headerLetterSpacing,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    isLogin ? AppStrings.subtitleSignIn : AppStrings.subtitleSignUp,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a160),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(AppAlphas.a100),
                      borderRadius: BorderRadius.circular(AppRadii.r12),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton(AuthMode.login, AppStrings.signInLabel, theme)),
                        Expanded(child: _buildTabButton(AuthMode.register, AppStrings.signUpLabel, theme)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  CustomTextField(
                    controller: _controller.emailController,
                    hintText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_controller.isLoading,
                  ),
                  CustomTextField(
                    controller: _controller.passwordController,
                    hintText: AppStrings.password,
                    obscureText: true,
                    enabled: !_controller.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  CustomButton(
                    label: isLogin ? AppStrings.signInLabel : AppStrings.signUpLabel,
                    variant: ButtonVariant.primary,
                    icon: isLogin ? Icons.login_rounded : Icons.app_registration_rounded,
                    isLoading: _controller.isLoading,
                    onPressed: _handleAuth,
                  ),
                  const SizedBox(height: AppSpacing.s48),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withAlpha(AppAlphas.a30),
                      borderRadius: BorderRadius.circular(AppRadii.r12),
                      border: Border.all(color: theme.colorScheme.error.withAlpha(AppAlphas.a50)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined, 
                          color: theme.colorScheme.error, 
                          size: AppLayout.iconSmall,
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Text(
                            AppStrings.securityDisclaimer,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a180),
                              height: AppLayout.disclaimerLineHeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}