import 'dart:convert';

NavigationItemModel navigationItemModelFromJson(String str) => NavigationItemModel.fromJson(json.decode(str));

class NavigationItemModel {
    int index;
    String courseName;
    String moduleName;
    String mimeType;
    String identifier;
    String name;
    String parentCourseId;
    String artifactUrl;
    String contentId;
    String currentProgress;
    String completionPercentage;
    int status;
    String moduleDuration;
    String courseDuration;
    String duration;

    NavigationItemModel({
        this.index,
        this.courseName,
        this.moduleName,
        this.mimeType,
        this.identifier,
        this.name,
        this.parentCourseId,
        this.artifactUrl,
        this.contentId,
        this.currentProgress,
        this.completionPercentage,
        this.status,
        this.moduleDuration,
        this.courseDuration,
        this.duration,
    });

    factory NavigationItemModel.fromJson(Map<String, dynamic> json) => NavigationItemModel(
        index: json["index"],
        courseName: json["courseName"],
        moduleName: json["moduleName"],
        mimeType: json["mimeType"],
        identifier: json["identifier"],
        name: json["name"],
        parentCourseId: json["parentCourseId"],
        artifactUrl: json["artifactUrl"],
        contentId: json["contentId"],
        currentProgress: json["currentProgress"],
        completionPercentage: json["completionPercentage"],
        status: json["status"],
        moduleDuration: json["moduleDuration"],
        courseDuration: json["courseDuration"],
        duration: json["duration"],
    );
}
