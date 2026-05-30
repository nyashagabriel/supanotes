import 'package:flutter/material.dart';
import 'package:supanotes/data/constants/app_strings.dart';
import 'package:supanotes/data/constants/app_constants.dart';
import 'package:supanotes/data/services/services.dart';
import 'package:supanotes/ui/pages/home_page.dart';
import 'package:supanotes/ui/widgets/custom_button.dart';
import 'package:supanotes/ui/widgets/custom_snack_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final success = await Services.of(context).authService.signOut();
    if (success && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false, 
      );
    } else if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: AppStrings.signOutFailed,
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Services.of(context).authService.auth.currentUser;
    final userEmail = currentUser?.email ?? AppStrings.unknownUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppLayout.avatarSizeLarge,
                height: AppLayout.avatarSizeLarge,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(AppAlphas.a40),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(AppAlphas.a100),
                    width: AppLayout.borderWidthThick,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: AppLayout.iconExtraLarge,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              AppStrings.loggedInAs,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a150),
                letterSpacing: AppLayout.labelLetterSpacing,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.s48),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.dark_mode_rounded, 
                color: theme.colorScheme.primary,
              ),
              title: const Text(AppStrings.themePreference),
              trailing: Text(
                AppStrings.darkMode, 
                style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a150)),
              ),
            ),
            Divider(color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a20)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.cloud_done_rounded, 
                color: theme.colorScheme.primary,
              ),
              title: const Text(AppStrings.databaseConnection),
              trailing: Text(
                AppStrings.connected, 
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            
            const SizedBox(height: AppSpacing.s48),
            CustomButton(
              label: AppStrings.signOutLabel,
              icon: Icons.logout_rounded,
              variant: ButtonVariant.secondary,
              onPressed: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}