import 'package:karmayogi_mobile/models/_models/course_config_model.dart';

class LearnConfig {
  final CourseConfig continueLearning;
  final CourseConfig mandatoryCourse;
  final CourseConfig recommendedCourse;
  final CourseConfig basedOnInterest;
  final CourseConfig newlyAddedCourse;
  final CourseConfig curatedCollectionConfig;
  final CourseConfig featuredCoursesConfig;
  final CourseConfig programsConfig;
  final CourseConfig moderatedCoursesConfig;
  final CourseConfig blendedProgramsConfig;
  final raw;

  LearnConfig(
      {this.continueLearning,
      this.mandatoryCourse,
      this.basedOnInterest,
      this.recommendedCourse,
      this.newlyAddedCourse,
      this.curatedCollectionConfig,
      this.featuredCoursesConfig,
      this.programsConfig,
      this.moderatedCoursesConfig,
      this.blendedProgramsConfig,
      this.raw});

  factory LearnConfig.fromJson(Map<String, dynamic> json) {
    return LearnConfig(
        continueLearning: json['continueLearning'],
        mandatoryCourse: json['mandatoryCourse'],
        recommendedCourse: json['recommendedCourse'],
        basedOnInterest: json['recommendedCourse'],
        newlyAddedCourse: json['latestCourses'],
        curatedCollectionConfig: json['curatedCollections'],
        featuredCoursesConfig: json['featuredCourses'],
        programsConfig: json['programs'],
        moderatedCoursesConfig: json['moderatedCourses'],
        blendedProgramsConfig: json['blendedPrograms'],
        raw: json);
  }
}
