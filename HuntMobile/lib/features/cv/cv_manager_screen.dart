import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../discover/discover_screen.dart';

/// CV selection happens BEFORE swipe discovery to preserve the
/// "one card = one decision" principle of the swipe UX.
class CvManagerScreen extends ConsumerWidget {
  const CvManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvList = ref.watch(cvListProvider);
    final profile = ref.watch(seekerProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Generate / Upload CV',
            onPressed: () => _showAddCvOptions(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (profile.preferredCvId == null)
              Container(
                width: double.infinity,
                color: AppColors.clayRed.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.clayRed),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Default CV was deleted. Choose or generate a new default CV before swiping.',
                        style: TextStyle(
                            color: AppColors.clayRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a default CV to automatically attach with right-swipes during job discovery.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: cvList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.note_add_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No CVs available',
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddCvOptions(context, ref),
                            child: const Text('Generate or Upload CV'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cvList.length,
                      itemBuilder: (context, index) {
                        final cv = cvList[index];
                        return _buildCvTile(context, ref, cv);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('start_swiping_btn'),
                  onPressed: profile.preferredCvId == null
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const DiscoverScreen(),
                            ),
                          );
                        },
                  child: const Text('Start Discovering Jobs'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvTile(BuildContext context, WidgetRef ref, CvDocument cv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cv.isPreferred ? AppColors.forestGreen : AppColors.mutedGray,
          width: cv.isPreferred ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Radio<bool>(
          value: true,
          groupValue: cv.isPreferred,
          activeColor: AppColors.forestGreen,
          onChanged: (_) {
            ref.read(cvListProvider.notifier).setPreferredCv(cv.id);
          },
        ),
        title: Text(
          cv.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Source: ${cv.source} • Added ${cv.createdAt.day}/${cv.createdAt.month}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 20),
              tooltip: 'Preview PDF',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening PDF Preview: ${cv.fileName}')),
                );
              },
            ),
            IconButton(
              key: Key('delete_cv_${cv.id}'),
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.clayRed),
              onPressed: () => _showDeleteConfirmation(context, ref, cv),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, CvDocument cv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete CV?'),
        content: Text('Are you sure you want to delete ${cv.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_delete_btn'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.clayRed),
            onPressed: () {
              ref.read(cvListProvider.notifier).deleteCv(cv.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCvOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.forestGreen),
              title: const Text('Generate CV from Profile'),
              subtitle: const Text('Creates a formatted PDF via ICvGenerator'),
              onTap: () {
                ref.read(cvListProvider.notifier).generateNewCv();
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: AppColors.clayRed),
              title: const Text('Upload PDF/DOCX File'),
              subtitle: const Text('Select a custom CV document from your device'),
              onTap: () {
                ref.read(cvListProvider.notifier).addCv(
                      CvDocument(
                        id: 'cv_upload_${DateTime.now().millisecondsSinceEpoch}',
                        source: 'Uploaded',
                        fileUrl: 'https://stackt.io/uploads/custom.pdf',
                        fileName: 'My_Custom_Resume.pdf',
                        isPreferred: false,
                        createdAt: DateTime.now(),
                      ),
                    );
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
