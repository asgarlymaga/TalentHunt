import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../core/network/network_service.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// Riverpod provider for active seeker profile
final seekerProfileProvider =
    StateNotifierProvider<SeekerProfileNotifier, SeekerProfile>((ref) {
  return SeekerProfileNotifier();
});

class SeekerProfileNotifier extends StateNotifier<SeekerProfile> {
  SeekerProfileNotifier()
      : super(SeekerProfile(
          skills: [],
          minSalary: 80000,
          workStyle: 'Remote',
        ));

  void updateSkills(List<String> skills) {
    state = SeekerProfile(
      skills: skills,
      minSalary: state.minSalary,
      workStyle: state.workStyle,
      preferredCvId: state.preferredCvId,
    );
  }

  void updateMinSalary(int minSalary) {
    state = SeekerProfile(
      skills: state.skills,
      minSalary: minSalary,
      workStyle: state.workStyle,
      preferredCvId: state.preferredCvId,
    );
  }

  void updateWorkStyle(String workStyle) {
    state = SeekerProfile(
      skills: state.skills,
      minSalary: state.minSalary,
      workStyle: workStyle,
      preferredCvId: state.preferredCvId,
    );
  }

  void setPreferredCv(String? cvId) {
    state = SeekerProfile(
      skills: state.skills,
      minSalary: state.minSalary,
      workStyle: state.workStyle,
      preferredCvId: cvId,
    );
  }
}

/// Riverpod provider for CV List management
final cvListProvider =
    StateNotifierProvider<CvListNotifier, List<CvDocument>>((ref) {
  return CvListNotifier(ref);
});

class CvListNotifier extends StateNotifier<List<CvDocument>> {
  final Ref ref;

  CvListNotifier(this.ref)
      : super([
          CvDocument(
            id: 'cv_generated_1',
            source: 'Generated',
            fileUrl: 'https://stackt.io/cvs/generated_1.pdf',
            fileName: 'Generated_CV.pdf',
            isPreferred: true,
            createdAt: DateTime.now(),
          ),
        ]) {
    // Sync initial default CV with profile
    ref.read(seekerProfileProvider.notifier).setPreferredCv('cv_generated_1');
  }

  void setPreferredCv(String id) {
    state = state.map((cv) {
      return cv.copyWith(isPreferred: cv.id == id);
    }).toList();
    ref.read(seekerProfileProvider.notifier).setPreferredCv(id);
  }

  void addCv(CvDocument cv) {
    // If it's the first CV added, make it default
    final isFirst = state.isEmpty;
    final newCv = cv.copyWith(isPreferred: isFirst || cv.isPreferred);

    if (newCv.isPreferred) {
      state = state.map((c) => c.copyWith(isPreferred: false)).toList();
      ref.read(seekerProfileProvider.notifier).setPreferredCv(newCv.id);
    }
    state = [...state, newCv];
  }

  void deleteCv(String id) {
    final deletedCv = state.firstWhere((c) => c.id == id,
        orElse: () => CvDocument(
            id: '',
            source: '',
            fileUrl: '',
            fileName: '',
            createdAt: DateTime.now()));

    state = state.where((c) => c.id != id).toList();

    // If deleted CV was preferred, reset preferredCvId to null
    if (deletedCv.isPreferred) {
      ref.read(seekerProfileProvider.notifier).setPreferredCv(null);
    }
  }

  void generateNewCv() {
    final profile = ref.read(seekerProfileProvider);
    final newCv = CvDocument(
      id: 'cv_generated_${DateTime.now().millisecondsSinceEpoch}',
      source: 'Generated',
      fileUrl: 'https://stackt.io/cvs/generated.pdf',
      fileName: 'Profile_Generated_CV.pdf',
      isPreferred: state.isEmpty,
      createdAt: DateTime.now(),
    );
    addCv(newCv);
  }
}

/// Riverpod provider for deck jobs
final deckJobsProvider = StateNotifierProvider<DeckJobsNotifier, List<Job>>((ref) {
  return DeckJobsNotifier();
});

class DeckJobsNotifier extends StateNotifier<List<Job>> {
  DeckJobsNotifier()
      : super([
          Job(
            id: 'job_1',
            title: 'Senior Flutter Developer',
            companyName: 'TechCorp',
            oneLinePitch: 'Build high-volume consumer swiping experiences.',
            requiredSkills: ['Flutter', 'Dart', 'Riverpod', 'REST API'],
            salaryMin: 120000,
            salaryMax: 150000,
            workStyle: 'Remote',
            experienceLevel: 'Senior',
            compatibilityScore: 0.92,
          ),
          Job(
            id: 'job_2',
            title: 'Full Stack .NET Engineer',
            companyName: 'Stackt Inc',
            oneLinePitch: 'Architect async Hangfire pipelines for matching.',
            requiredSkills: ['C#', 'ASP.NET Core', 'PostgreSQL', 'Docker'],
            salaryMin: 110000,
            salaryMax: 140000,
            workStyle: 'Hybrid',
            experienceLevel: 'Mid',
            compatibilityScore: 0.85,
          ),
          Job(
            id: 'job_3',
            title: 'Frontend Angular Specialist',
            companyName: 'RecruiterHub',
            oneLinePitch: 'Design signal-based recruiter Kanban boards.',
            requiredSkills: ['Angular', 'TypeScript', 'RxJS', 'SCSS'],
            salaryMin: 100000,
            salaryMax: 130000,
            workStyle: 'Remote',
            experienceLevel: 'Senior',
            compatibilityScore: 0.78,
          ),
        ]);

  void removeTopCard() {
    if (state.isNotEmpty) {
      state = state.sublist(1);
    }
  }
}

/// Provider for submitted applications
final applicationsProvider =
    StateNotifierProvider<ApplicationsNotifier, List<ApplicationItem>>((ref) {
  return ApplicationsNotifier();
});

class ApplicationsNotifier extends StateNotifier<List<ApplicationItem>> {
  ApplicationsNotifier() : super([]);

  void addApplication(ApplicationItem item) {
    state = [item, ...state];
  }

  void updateStatus(String id, String status) {
    state = state.map((app) {
      if (app.id == id) {
        return ApplicationItem(
          id: app.id,
          jobTitle: app.jobTitle,
          companyName: app.companyName,
          cvFileName: app.cvFileName,
          cvSource: app.cvSource,
          status: status,
          sentAt: app.sentAt,
        );
      }
      return app;
    }).toList();
  }
}
