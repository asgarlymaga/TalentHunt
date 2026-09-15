import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../profile/profile_setup_wizard.dart';

/// Corresponds to Role Select Screen in mockup.
/// Seeker/Employer choice. If Employer selected, redirect to web via dialog/deep-link.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Stackt.',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe right on your next career move',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              _buildRoleTile(
                context: context,
                title: 'I am a Job Seeker',
                subtitle: 'Swipe through matches, build your profile & CV',
                icon: Icons.person_search_outlined,
                color: AppColors.forestGreen,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupWizard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildRoleTile(
                context: context,
                title: 'I am an Employer',
                subtitle: 'Post vacancies & manage candidate pipelines',
                icon: Icons.business_outlined,
                color: AppColors.clayRed,
                onTap: () {
                  _showEmployerRedirectDialog(context);
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showEmployerRedirectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Employer Portal'),
        content: const Text(
          'Employers use the Stackt Web Dashboard to create vacancies and manage applicants.\n\nRedirecting to https://recruiter.stackt.io...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
