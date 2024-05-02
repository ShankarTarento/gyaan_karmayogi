class AssessmentInfo {
  final String name;
  final int maxQuestions;
  final List<dynamic> questions;
  final int expectedDuration;
  final String primaryCategory;
  final String objectType;
  final maxAssessmentRetakeAttempts;

  const AssessmentInfo(
      {this.name,
      this.maxQuestions,
      this.questions,
      this.expectedDuration,
      this.primaryCategory,
      this.objectType,
      this.maxAssessmentRetakeAttempts});

  factory AssessmentInfo.fromJson(Map<String, dynamic> json) {
    return AssessmentInfo(
        name: json['name'] as String,
        maxQuestions: json['maxQuestions'].toInt(),
        questions: json['children'],
        expectedDuration: json['expectedDuration'].toInt(),
        primaryCategory: json['primaryCategory'],
        objectType: json['objectType'],
        maxAssessmentRetakeAttempts: json['maxAssessmentRetakeAttempts']);
  }
}
