import 'dart:convert';

ScannerModel scannerModelFromJson(String str) =>
    ScannerModel.fromJson(json.decode(str));

String scannerModelToJson(ScannerModel data) => json.encode(data.toJson());

class ScannerModel {
  final String courseId;
  final String batchId;
  final String sessionId;

  ScannerModel({
    this.courseId,
    this.batchId,
    this.sessionId,
  });

  factory ScannerModel.fromJson(Map<String, dynamic> json) => ScannerModel(
        courseId: json["courseId"],
        batchId: json["batchId"],
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "batchId": batchId,
        "sessionId": sessionId,
      };
}
