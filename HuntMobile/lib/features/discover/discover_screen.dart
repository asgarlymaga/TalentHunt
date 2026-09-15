import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../applied/applied_list_screen.dart';
import '../cv/cv_manager_screen.dart';
import '../matches/matches_list_screen.dart';
import 'swipe_card_stack.dart';

/// Discover screen handling job discovery with optimistic UI swiping
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(deckJobsProvider);
    final profile = ref.watch(seekerProfileProvider);
    final cvs = ref.watch(cvListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'CV Manager',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CvManagerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            tooltip: 'Applications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppliedListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Matches',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MatchesListScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: SwipeCardStack(
                  jobs: jobs,
                  onSwipe: (job, isRightSwipe) {
                    if (isRightSwipe) {
                      _handleRightSwipe(context, ref, job, profile, cvs);
                    } else {
                      // Left swipe: reject job
                      ref.read(deckJobsProvider.notifier).removeTopCard();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (jobs.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'pass_btn',
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.close,
                          color: AppColors.clayRed, size: 28),
                      onPressed: () {
                        if (jobs.isNotEmpty) {
                          ref.read(deckJobsProvider.notifier).removeTopCard();
                        }
                      },
                    ),
                    const SizedBox(width: 32),
                    FloatingActionButton(
                      heroTag: 'apply_btn',
                      backgroundColor: AppColors.forestGreen,
                      elevation: 4,
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        if (jobs.isNotEmpty) {
                          _handleRightSwipe(
                              context, ref, jobs.first, profile, cvs);
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRightSwipe(
    BuildContext context,
    WidgetRef ref,
    Job job,
    SeekerProfile profile,
    List<CvDocument> cvs,
  ) {
    // Critical validation check: Backend returns 400 if PreferredCvId is null
    if (profile.preferredCvId == null) {
      _showNoCvBottomSheet(context);
      return;
    }

    final preferredCv = cvs.firstWhere(
      (c) => c.id == profile.preferredCvId,
      orElse: () => CvDocument(
        id: 'cv_default',
        source: 'Generated',
        fileUrl: '',
        fileName: 'Default_CV.pdf',
        createdAt: DateTime.now(),
      ),
    );

    // Optimistic UI: Card disappears immediately
    ref.read(deckJobsProvider.notifier).removeTopCard();

    // Create Application item in background (Optimistic "Sending..." status)
    final newApp = ApplicationItem(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      jobTitle: job.title,
      companyName: job.companyName,
      cvFileName: preferredCv.fileName,
      cvSource: preferredCv.source,
      status: 'Sending',
      sentAt: DateTime.now(),
    );

    ref.read(applicationsProvider.notifier).addApplication(newApp);

    // Simulate async Hangfire confirmation email job completion
    Future.delayed(const Duration(seconds: 2), () {
      ref
          .read(applicationsProvider.notifier)
          .updateStatus(newApp.id, 'Sent');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to ${job.title}! Email enqueued via Hangfire.'),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNoCvBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.clayRed),
              const SizedBox(height: 12),
              const Text(
                'Choose a CV to apply',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You cannot swipe right without selecting a default CV. Choose or generate a CV first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('go_to_cv_manager_btn'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CvManagerScreen(),
                      ),
                    );
                  },
                  child: const Text('Go to CV Manager'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
