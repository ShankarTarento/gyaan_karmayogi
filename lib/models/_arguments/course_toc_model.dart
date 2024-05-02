import 'dart:convert';

import 'package:flutter/material.dart';

CourseTocModel courseTocModelFromJson(String str) => CourseTocModel.fromJson(
      json.decode(str),
    );

String courseTocModelToJson(CourseTocModel data) => json.encode(data.toJson());

class CourseTocModel {
  String courseId;
  bool isFeaturedCourse;
  bool isBlendedProgram;
  bool isModeratedContent;
  bool showCourseCompletionMessage;

  CourseTocModel(
      {@required this.courseId,
      this.isFeaturedCourse,
      this.isBlendedProgram,
      this.isModeratedContent = false,
      this.showCourseCompletionMessage});

  factory CourseTocModel.fromJson(Map<String, dynamic> json) {
    return CourseTocModel(
        courseId: json["courseId"],
        isFeaturedCourse:
            json["isFeaturedCourse"] != null ? json["isFeaturedCourse"] : false,
        isBlendedProgram:
            json["isBlendedProgram"] != null ? json["isBlendedProgram"] : false,
        isModeratedContent: json["isModeratedContent"] != null
            ? json["isModeratedContent"]
            : false,
        showCourseCompletionMessage: json['showCourseCompletionMessage'] != null
            ? json['showCourseCompletionMessage']
            : false);
  }
  Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "isFeaturedCourse": isFeaturedCourse,
      };
}
