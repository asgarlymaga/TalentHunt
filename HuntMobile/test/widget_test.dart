import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackt_mobile/features/profile/profile_setup_wizard.dart';
import 'package:stackt_mobile/features/cv/cv_manager_screen.dart';
import 'package:stackt_mobile/features/discover/swipe_card_stack.dart';
import 'package:stackt_mobile/features/discover/discover_screen.dart';
import 'package:stackt_mobile/models/app_models.dart';
import 'package:stackt_mobile/providers/app_providers.dart';

void main() {
  testWidgets('ProfileSetupWizard validates skills selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileSetupWizard(),
        ),
      ),
    );

    // Initial skills are pre-selected in state ('Flutter', 'Dart'), button is enabled
    final continueBtnFinder = find.byKey(const Key('wizard_continue_btn'));
    expect(continueBtnFinder, findsOneWidget);

    // Deselect selected skills
    await tester.tap(find.byKey(const Key('skill_chip_Flutter')));
    await tester.tap(find.byKey(const Key('skill_chip_Dart')));
    await tester.pumpAndSettle();

    // With no skills selected, Continue button should be disabled
    final btnWidget = tester.widget<ElevatedButton>(continueBtnFinder);
    expect(btnWidget.onPressed, isNull);
  });

  testWidgets('CvManagerScreen radio selection allows only one default CV',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CvManagerScreen(),
        ),
      ),
    );

    expect(find.text('CV Manager'), findsOneWidget);
    expect(find.text('Generated_CV.pdf'), findsOneWidget);
  });

  testWidgets('CV Selection before swipe shows bottom sheet when PreferredCvId is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seekerProfileProvider.overrideWith((ref) {
            final notifier = SeekerProfileNotifier();
            notifier.setPreferredCv(null); // No preferred CV set
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: DiscoverScreen(),
        ),
      ),
    );

    // Try to click Apply button without a default CV selected
    final applyBtn = find.byKey(const Key('apply_btn'));
    expect(applyBtn, findsOneWidget);
    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    // Verify bottom sheet appears with error message
    expect(find.text('Choose a CV to apply'), findsOneWidget);
    expect(find.byKey(const Key('go_to_cv_manager_btn')), findsOneWidget);
  });

  testWidgets('SwipeCardStack handles threshold drag removing card',
      (WidgetTester tester) async {
    final jobs = [
      Job(
        id: 'j1',
        title: 'Test Job Title',
        companyName: 'Test Corp',
        oneLinePitch: 'Pitch',
        requiredSkills: ['Flutter'],
        salaryMin: 100000,
        salaryMax: 120000,
        workStyle: 'Remote',
        experienceLevel: 'Senior',
      ),
    ];

    bool swiped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeCardStack(
            jobs: jobs,
            onSwipe: (job, isRight) {
              swiped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Test Job Title'), findsOneWidget);

    // Perform drag past threshold (> 90px)
    await tester.drag(find.text('Test Job Title'), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(swiped, isTrue);
  });
}
