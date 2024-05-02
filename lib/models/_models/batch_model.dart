import 'package:flutter/material.dart';

class Batch {
  final String id;
  final String batchId;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String enrollmentEndDate;
  final int status;
  BatchAttribute batchAttributes;

  Batch(
      {@required this.id,
      @required this.batchId,
      @required this.name,
      @required this.description,
      @required this.startDate,
      @required this.endDate,
      @required this.enrollmentEndDate,
      @required this.status,
      this.batchAttributes});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
        id: json['id'] as String,
        batchId: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        startDate: json['startDate'] as String,
        endDate: json['endDate'] as String,
        enrollmentEndDate: json['enrollmentEndDate'] as String,
        status: json['status'] as int,
        batchAttributes: json["batchAttributes"] == null
            ? BatchAttribute.fromJson({})
            : BatchAttribute.fromJson(json["batchAttributes"]));
  }
}

class BatchAttribute {
  final bool enableQR;
  final String latlong;
  final String batchLocationDetails;
  final String currentBatchSize;
  final List<SessionDetailV2> sessionDetailsV2;
  String courseId;

  BatchAttribute(
      {this.enableQR,
      this.latlong,
      this.batchLocationDetails,
      this.currentBatchSize,
      @required this.sessionDetailsV2,
      this.courseId});

  factory BatchAttribute.fromJson(Map<String, dynamic> json) => BatchAttribute(
        enableQR: json['enableQR'],
        latlong: json["latlong"],
        batchLocationDetails: json["batchLocationDetails"],
        currentBatchSize: json["currentBatchSize"],
        courseId: json["courseId"] != null ? json["courseId"] : '',
        sessionDetailsV2: json["sessionDetails_v2"] == null
            ? []
            : List<SessionDetailV2>.from(json["sessionDetails_v2"]
                .map((x) => SessionDetailV2.fromJson(x))),
      );
}

class SessionDetailV2 {
  final List<AttachLink> attachLinks;
  final List<String> facilatorIDs;
  final List<dynamic> sessionHandouts;
  final List<FacilatorDetail> facilatorDetails;
  final String description;
  final String sessionType;
  final String startTime;
  final String sessionId;
  final String endTime;
  final String title;
  final String sessionDuration;
  final String startDate;
  bool sessionAttendanceStatus;

  SessionDetailV2(
      {@required this.attachLinks,
      @required this.facilatorIDs,
      @required this.sessionHandouts,
      @required this.facilatorDetails,
      @required this.description,
      @required this.sessionType,
      @required this.startTime,
      @required this.sessionId,
      @required this.endTime,
      @required this.title,
      @required this.sessionDuration,
      @required this.startDate,
      @required this.sessionAttendanceStatus});

  factory SessionDetailV2.fromJson(Map<String, dynamic> json) =>
      SessionDetailV2(
          attachLinks: List<AttachLink>.from(
              json["attachLinks"].map((x) => AttachLink.fromJson(x))),
          facilatorIDs: List<String>.from(json["facilatorIDs"].map((x) => x)),
          sessionHandouts:
              List<dynamic>.from(json["sessionHandouts"].map((x) => x)),
          facilatorDetails: List<FacilatorDetail>.from(
              json["facilatorDetails"].map((x) => FacilatorDetail.fromJson(x))),
          description: json["description"],
          sessionType: json["sessionType"],
          startTime: json["startTime"],
          sessionId: json["sessionId"],
          endTime: json["endTime"],
          title: json["title"],
          sessionDuration: json["sessionDuration"],
          startDate: json["startDate"],
          sessionAttendanceStatus: json["sessionAttendanceStatus"] != null
              ? json["sessionAttendanceStatus"]
              : false);
}

class AttachLink {
  final String title;
  final String url;

  AttachLink({
    @required this.title,
    @required this.url,
  });

  factory AttachLink.fromJson(Map<String, dynamic> json) => AttachLink(
        title: json["title"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "url": url,
      };
}

class FacilatorDetail {
  final String name;
  final String id;
  final String email;

  FacilatorDetail({
    @required this.name,
    @required this.id,
    @required this.email,
  });

  factory FacilatorDetail.fromJson(Map<String, dynamic> json) =>
      FacilatorDetail(
        name: json["name"],
        id: json["id"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "email": email,
      };
}

class BatchCountStatus {
  String currentStatus;
  int statusCount;
  BatchCountStatus({@required this.currentStatus, @required this.statusCount});
  factory BatchCountStatus.fromJson(Map<String, dynamic> json) {
    return BatchCountStatus(
      currentStatus: json["currentStatus"],
      statusCount: json["statusCount"],
    );
  }
}
