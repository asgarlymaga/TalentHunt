import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'match_breakdown_screen.dart';

/// List of jobs where both seeker and employer swiped right
class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mockMatches = [
      {
        'jobId': 'job_1',
        'title': 'Senior Flutter Developer',
        'company': 'TechCorp',
        'matchedAt': '2 hours ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Matches'),
      ),
      body: SafeArea(
        child: mockMatches.isEmpty
            ? Center(
                child: Text('No matches yet', style: theme.textTheme.titleLarge),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mockMatches.length,
                itemBuilder: (context, index) {
                  final match = mockMatches[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.forestGreen, width: 1.5),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.bone,
                        child: Icon(Icons.favorite, color: AppColors.clayRed),
                      ),
                      title: Text(
                        match['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${match['company']} • ${match['matchedAt']}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MatchBreakdownScreen(
                              jobTitle: match['title']!,
                              companyName: match['company']!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
