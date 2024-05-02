import 'dart:convert';

CompetencyDataModel competencyDataModelFromJson(String str) =>
    CompetencyDataModel.fromJson(json.decode(str));

class CompetencyDataModel {
  CompetencyArea competencyArea;
  List<CompetencyTheme> competencyThemes;

  CompetencyDataModel({
    this.competencyArea,
    this.competencyThemes,
  });

  factory CompetencyDataModel.fromJson(Map<String, dynamic> json) =>
      CompetencyDataModel(
        competencyArea: CompetencyArea.fromJson(json["competencyArea"]),
        competencyThemes: List<CompetencyTheme>.from(
            json["competencyThemes"].map((x) => CompetencyTheme.fromJson(x))),
      );
}

class CompetencyArea {
  int id;
  String name;

  CompetencyArea({
    this.id,
    this.name,
  });

  factory CompetencyArea.fromJson(Map<String, dynamic> json) => CompetencyArea(
        id: json["id"],
        name: json["name"],
      );
}

class CompetencyTheme {
  CompetencyArea competencyArea;
  Theme theme;
  List<CourseData> courses;
  List<Theme> competencySubthemes;

  CompetencyTheme({
    this.competencyArea,
    this.theme,
    this.courses,
    this.competencySubthemes,
  });

  factory CompetencyTheme.fromJson(Map<String, dynamic> json) =>
      CompetencyTheme(
        competencyArea: CompetencyArea.fromJson(json["competencyArea"]),
        theme: Theme.fromJson(json["theme"]),
        courses: List<CourseData>.from(
            json["courses"].map((x) => CourseData.fromJson(x))),
        competencySubthemes: List<Theme>.from(
            json["competencySubthemes"].map((x) => Theme.fromJson(x))),
      );
}

class Theme {
  int id;
  String name;

  Theme({
    this.id,
    this.name,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        id: json["id"],
        name: json["name"],
      );
}

class CourseData {
  String courseId;
  String courseName;
  String completedOn;
  String certificateId;
  String primaryCategory;
  List<Theme> courseSubthemes;

  CourseData(
      {this.courseId,
      this.courseName,
      this.completedOn,
      this.certificateId,
      this.courseSubthemes,
      this.primaryCategory});

  factory CourseData.fromJson(Map<String, dynamic> json) => CourseData(
      courseId: json["courseId"],
      courseName: json["courseName"],
      completedOn: json["completedOn"],
      certificateId: json['certificateId'],
      primaryCategory: json['primaryCategory'],
      courseSubthemes: List<Theme>.from(
          json["courseSubthemes"].map((x) => Theme.fromJson(x))));
}
