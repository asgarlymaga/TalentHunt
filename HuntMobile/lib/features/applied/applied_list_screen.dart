import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

/// Shows list of jobs swiped right with async submission status (Sending / Sent / Failed)
/// and CV source details.
class AppliedListScreen extends ConsumerWidget {
  const AppliedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: SafeArea(
        child: applications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_outlined,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No applications yet',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Right swipe on job cards to send applications.'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mutedGray),
                    ),
                    child: ListTile(
                      title: Text(app.jobTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.companyName,
                              style: const TextStyle(color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  size: 14, color: AppColors.forestGreen),
                              const SizedBox(width: 4),
                              Text(
                                '${app.cvFileName} (${app.cvSource})',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: _buildStatusBadge(app.status),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Sent':
        bg = AppColors.forestGreen.withValues(alpha: 0.1);
        fg = AppColors.forestGreen;
        break;
      case 'Sending':
        bg = Colors.orange.withValues(alpha: 0.1);
        fg = Colors.orange.shade800;
        break;
      case 'Failed':
      default:
        bg = AppColors.clayRed.withValues(alpha: 0.1);
        fg = AppColors.clayRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
