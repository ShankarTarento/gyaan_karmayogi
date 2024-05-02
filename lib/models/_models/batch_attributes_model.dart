import 'package:meta/meta.dart';
import 'dart:convert';

BatchAttributes batchAttributesFromJson(String str) =>
    BatchAttributes.fromJson(json.decode(str));

class BatchAttributes {
  final bool enableQR;
  final String latlong;
  final String batchLocationDetails;
  final String currentBatchSize;
  final List<SessionDetailsV2> sessionDetailsV2;
  String courseId;

  BatchAttributes(
      {@required this.enableQR,
      @required this.latlong,
      @required this.batchLocationDetails,
      @required this.currentBatchSize,
      @required this.sessionDetailsV2,
      @required this.courseId});

  factory BatchAttributes.fromJson(Map<String, dynamic> json) =>
      BatchAttributes(
        enableQR: json['enableQR'],
        latlong: json["latlong"],
        batchLocationDetails: json["batchLocationDetails"],
        currentBatchSize: json["currentBatchSize"],
        courseId: json["courseId"] != null ? json["courseId"] : '',
        sessionDetailsV2: List<SessionDetailsV2>.from(
            json["sessionDetails_v2"].map((x) => SessionDetailsV2.fromJson(x))),
      );
}

class SessionDetailsV2 {
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
  String lastCompletedTime;

  SessionDetailsV2(
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
      this.lastCompletedTime,
      @required this.sessionAttendanceStatus});

  factory SessionDetailsV2.fromJson(Map<String, dynamic> json) =>
      SessionDetailsV2(
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
