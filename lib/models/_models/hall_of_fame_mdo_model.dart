// To parse this JSON data, do
//
//     final hallOfFameMdoListModel = hallOfFameMdoListModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

HallOfFameMdoListModel hallOfFameMdoListModelFromJson(String str) =>
    HallOfFameMdoListModel.fromJson(json.decode(str));

String hallOfFameMdoListModelToJson(HallOfFameMdoListModel data) =>
    json.encode(data.toJson());

class HallOfFameMdoListModel {
  final List<MdoList> mdoList;
  final String title;

  HallOfFameMdoListModel({
    @required this.mdoList,
    @required this.title,
  });

  factory HallOfFameMdoListModel.fromJson(Map<String, dynamic> json) =>
      HallOfFameMdoListModel(
        mdoList:
            List<MdoList>.from(json["mdoList"].map((x) => MdoList.fromJson(x))),
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "mdoList": List<dynamic>.from(mdoList.map((x) => x.toJson())),
        "title": title,
      };
}

class MdoList {
  final String negativeOrPositive;
  final int year;
  final String kpLastCalculated;
  final int month;
  final String orgId;
  final int totalKp;
  final int rank;
  final int progress;
  final double averageKp;
  final int totalUsers;
  final String orgName;
  final String orgLogo;
  final String latestCreditDate;

  static MdoList defaultMdo = MdoList(
    averageKp: 0.0,
    kpLastCalculated: '',
    latestCreditDate: '',
    month: 0,
    year: 0,
    negativeOrPositive: '',
    orgId: '',
    totalKp: 0,
    orgLogo: '',
    orgName: '',
    progress: 0,
    rank: 0,
    totalUsers: 0,
  );

  MdoList({
    @required this.negativeOrPositive,
    @required this.year,
    @required this.kpLastCalculated,
    @required this.month,
    @required this.orgId,
    @required this.totalKp,
    @required this.rank,
    @required this.progress,
    @required this.averageKp,
    @required this.totalUsers,
    @required this.orgName,
    @required this.orgLogo,
    @required this.latestCreditDate,
  });

  factory MdoList.fromJson(Map<String, dynamic> json) => MdoList(
        negativeOrPositive: json["negativeOrPositive"],
        year: json["year"],
        kpLastCalculated: json["kp_last_calculated"],
        month: json["month"],
        orgId: json["org_id"],
        totalKp: json["total_kp"],
        rank: json["rank"],
        progress: json["progress"] is String
            ? int.parse(json["progress"])
            : json["progress"],
        averageKp: json["average_kp"].toDouble(),
        totalUsers: json["total_users"],
        orgName: json["org_name"],
        orgLogo: json["org_logo"],
        latestCreditDate: json["latest_credit_date"],
      );

  Map<String, dynamic> toJson() => {
        "negativeOrPositive": negativeOrPositive,
        "year": year,
        "kp_last_calculated": kpLastCalculated,
        "month": month,
        "org_id": orgId,
        "total_kp": totalKp,
        "rank": rank,
        "progress": progress,
        "average_kp": averageKp,
        "total_users": totalUsers,
        "org_name": orgName,
        "org_logo": orgLogo,
        "latest_credit_date": latestCreditDate,
      };
}
