import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Match breakdown screen showing matched skills and missing/near filters
class MatchBreakdownScreen extends StatelessWidget {
  final String jobTitle;
  final String companyName;

  const MatchBreakdownScreen({
    super.key,
    required this.jobTitle,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Breakdown'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jobTitle, style: theme.textTheme.displayLarge?.copyWith(fontSize: 24)),
              Text(companyName, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              const Text('Matched Skills (100% Overlap)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: const [
                  Chip(
                    label: Text('Flutter'),
                    backgroundColor: AppColors.bone,
                    avatar: Icon(Icons.check, size: 16, color: AppColors.forestGreen),
                  ),
                  Chip(
                    label: Text('Dart'),
                    backgroundColor: AppColors.bone,
                    avatar: Icon(Icons.check, size: 16, color: AppColors.forestGreen),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Filter Evaluation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildFilterRow('Salary Range', '\$120k - \$150k (Fit: +25%)', true),
              _buildFilterRow('Work Style', 'Remote (Fit: +15%)', true),
              _buildFilterRow('Experience Level', 'Senior (Fit: +10%)', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(String label, String detail, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? AppColors.forestGreen : AppColors.clayRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(detail, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
