class Job {
  final String id;
  final String title;
  final String companyName;
  final String oneLinePitch;
  final List<String> requiredSkills;
  final int salaryMin;
  final int salaryMax;
  final String workStyle; // Remote | Hybrid | OnSite
  final String experienceLevel;
  final double? compatibilityScore;

  Job({
    required this.id,
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

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String? ?? 'Company',
      oneLinePitch: json['oneLinePitch'] as String? ?? '',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      salaryMin: (json['salaryMin'] as num?)?.toInt() ?? 0,
      salaryMax: (json['salaryMax'] as num?)?.toInt() ?? 0,
      workStyle: json['workStyle'] as String? ?? 'Remote',
      experienceLevel: json['experienceLevel'] as String? ?? 'Mid',
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'companyName': companyName,
        'oneLinePitch': oneLinePitch,
        'requiredSkills': requiredSkills,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'workStyle': workStyle,
        'experienceLevel': experienceLevel,
        'compatibilityScore': compatibilityScore,
      };
}

class CvDocument {
  final String id;
  final String source; // 'Generated' | 'Uploaded'
  final String fileUrl;
  final String fileName;
  final bool isPreferred;
  final DateTime createdAt;

  CvDocument({
    required this.id,
    required this.source,
    required this.fileUrl,
    required this.fileName,
    this.isPreferred = false,
    required this.createdAt,
  });

  factory CvDocument.fromJson(Map<String, dynamic> json) {
    return CvDocument(
      id: json['id'] as String,
      source: json['source'] as String? ?? 'Generated',
      fileUrl: json['fileUrl'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'CV.pdf',
      isPreferred: json['isPreferred'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  CvDocument copyWith({bool? isPreferred}) {
    return CvDocument(
      id: id,
      source: source,
      fileUrl: fileUrl,
      fileName: fileName,
      isPreferred: isPreferred ?? this.isPreferred,
      createdAt: createdAt,
    );
  }
}

class SeekerProfile {
  final List<String> skills;
  final int minSalary;
  final String workStyle;
  final String? preferredCvId;

  SeekerProfile({
    required this.skills,
    required this.minSalary,
    required this.workStyle,
    this.preferredCvId,
  });

  factory SeekerProfile.fromJson(Map<String, dynamic> json) {
    return SeekerProfile(
      skills: List<String>.from(json['skills'] ?? []),
      minSalary: (json['minSalary'] as num?)?.toInt() ?? 0,
      workStyle: json['workStyle'] as String? ?? 'Remote',
      preferredCvId: json['preferredCvId'] as String?,
    );
  }
}

class ApplicationItem {
  final String id;
  final String jobTitle;
  final String companyName;
  final String cvFileName;
  final String cvSource; // Generated | Uploaded
  final String status; // Sending | Sent | Failed
  final DateTime sentAt;

  ApplicationItem({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.cvFileName,
    required this.cvSource,
    required this.status,
    required this.sentAt,
  });
}
