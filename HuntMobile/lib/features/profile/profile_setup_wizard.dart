import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../cv/cv_manager_screen.dart';

/// 3-step profile wizard in PageView:
/// (1) skills chip-selector, (2) salary slider, (3) work-style selection.
class ProfileSetupWizard extends ConsumerStatefulWidget {
  const ProfileSetupWizard({super.key});

  @override
  ConsumerState<ProfileSetupWizard> createState() => _ProfileSetupWizardState();
}

class _ProfileSetupWizardState extends ConsumerState<ProfileSetupWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'C#',
    'ASP.NET Core',
    'PostgreSQL',
    'Angular',
    'TypeScript',
    'Docker',
    'REST API',
    'GraphQL'
  ];

  final List<String> _selectedSkills = ['Flutter', 'Dart'];
  double _minSalary = 90000;
  String _selectedWorkStyle = 'Remote';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup (${_currentStep + 1}/3)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.mutedGray,
              color: AppColors.forestGreen,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSkillsStep(theme),
                  _buildSalaryStep(theme),
                  _buildWorkStyleStep(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                            _pageController.animateToPage(
                              _currentStep,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.ink),
                        ),
                        child: const Text('Back',
                            style: TextStyle(color: AppColors.ink)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('wizard_continue_btn'),
                      onPressed: (_currentStep == 0 && _selectedSkills.isEmpty)
                          ? null
                          : () {
                              if (_currentStep < 2) {
                                setState(() {
                                  _currentStep++;
                                  _pageController.animateToPage(
                                    _currentStep,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              } else {
                                // Save profile to Riverpod
                                ref
                                    .read(seekerProfileProvider.notifier)
                                    .updateSkills(_selectedSkills);
                                ref
                                    .read(seekerProfileProvider.notifier)
                                    .updateMinSalary(_minSalary.toInt());
                                ref
                                    .read(seekerProfileProvider.notifier)
                                    .updateWorkStyle(_selectedWorkStyle);

                                // CV selection happens before swiping!
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const CvManagerScreen(),
                                  ),
                                );
                              }
                            },
                      child: Text(_currentStep == 2 ? 'Finish & Select CV' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Your Skills', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Choose at least one core skill to power compatibility matching.'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                key: Key('skill_chip_$skill'),
                label: Text(skill),
                selected: isSelected,
                selectedColor: AppColors.forestGreen.withValues(alpha: 0.2),
                checkmarkColor: AppColors.forestGreen,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Minimum Salary', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Jobs below this threshold will score lower in compatibility.'),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '\$${_minSalary.toInt() / 1000}k / year',
              style: theme.textTheme.displayLarge?.copyWith(
                color: AppColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _minSalary,
            min: 50000,
            max: 200000,
            divisions: 30,
            activeColor: AppColors.forestGreen,
            onChanged: (val) {
              setState(() {
                _minSalary = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStyleStep(ThemeData theme) {
    final styles = ['Remote', 'Hybrid', 'OnSite'];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferred Work Style', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Select your preferred work arrangement.'),
          const SizedBox(height: 24),
          ...styles.map((style) {
            final isSelected = _selectedWorkStyle == style;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.forestGreen : AppColors.mutedGray,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(style, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.forestGreen)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedWorkStyle = style;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
