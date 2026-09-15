import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Corresponds to ticket/index-card UI in swipe-jobs-ui.html mockup
class JobCard extends StatelessWidget {
  final String title;
  final String companyName;
  final String oneLinePitch;
  final List<String> requiredSkills;
  final int salaryMin;
  final int salaryMax;
  final String workStyle;
  final String experienceLevel;
  final double? compatibilityScore;

  const JobCard({
    super.key,
    required this.title,
    required this.companyName,
    required this.oneLinePitch,
    required this.requiredSkills,
    required this.salaryMin,
    required this.salaryMax,
    required this.workStyle,
    required this.experienceLevel,
    this.compatibilityScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.15), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  companyName.toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (compatibilityScore != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.forestGreen),
                  ),
                  child: Text(
                    '${(compatibilityScore! * 100).toInt()}% Match',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            '"$oneLinePitch"',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.ink.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.mutedGray),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: requiredSkills
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bone,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.mutedGray),
                      ),
                      child: Text(
                        skill,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(Icons.attach_money,
                  '\$${salaryMin / 1000}k - \$${salaryMax / 1000}k'),
              _buildBadge(Icons.location_on_outlined, workStyle),
              _buildBadge(Icons.work_outline, experienceLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.forestGreen),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
