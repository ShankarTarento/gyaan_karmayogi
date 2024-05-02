import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../index.dart';

class Course {
  final String id;
  final String appIcon;
  final String name;
  final String description;
  final String duration;
  final String programDuration;
  final double rating;
  final String creatorIcon;
  final String creatorLogo;
  final String contentType;
  final String source;
  final int completedOn;
  final List additionalTags;
  final List<CompetencyPassbook> competenciesV5;
  final String endDate;
  final List<dynamic> createdFor;
  final int completionPercentage;
  final raw;

  Course({
    @required this.id,
    @required this.appIcon,
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.programDuration,
    this.completionPercentage,
    this.creatorIcon,
    this.rating,
    this.creatorLogo,
    this.contentType,
    this.source,
    this.additionalTags,
    this.competenciesV5,
    this.endDate,
    this.createdFor,
    this.raw,
    this.completedOn,
  });

  factory Course.fromJson(Map<String, dynamic> json, {String endDate}) {
    return Course(
      id: json['identifier'] as String,
      appIcon: Helper.convertToPortalUrl(json['posterImage']),
      name: json['name'] as String,
      description: json['description'] as String,
      duration: json['duration'] != null
          ? json['duration']
          : ((json['content'] != null && json['content']['duration'] != null)
              ? json['content']['duration']
              : null) as String,
      programDuration: json['programDuration'] != null
          ? json['programDuration'].toString()
          : null,
      rating: json['avgRating'] != null ? json['avgRating'].toDouble() : 0.0,
      creatorIcon: json['creatorIcon'] as String,
      creatorLogo: json['creatorLogo'] != null
          ? Helper.convertToPortalUrl(json['creatorLogo'])
          : '',
      contentType: json['primaryCategory'] != null
          ? json['primaryCategory']
          : ((json['content'] != null &&
                  json['content']['primaryCategory'] != null)
              ? json['content']['primaryCategory']
              : ''),
      source: json['source'] != null
          ? json['source'].toString()
          : ((json['content'] != null &&
                  json['content']['organisation'] != null)
              ? json['content']['organisation'].first
              : (json['organisation'] != null &&
                      json['organisation'].isNotEmpty)
                  ? json['organisation'].first
                  : '') as String,
      additionalTags:
          json['additionalTags'] != null ? json['additionalTags'] : [],
      competenciesV5: json["competencies_v5"] != null
          ? List<CompetencyPassbook>.from(json["competencies_v5"]
              .map((x) => CompetencyPassbook.fromJson(x, json['identifier'])))
          : null,
      endDate: endDate != null
          ? endDate
          : json['endDate'] != null
              ? json['endDate']
              : null,
      createdFor: json['createdFor'] != null ? json['createdFor'] : null,
      completedOn: json['completedOn'] != null ? json['completedOn'] : null,
      completionPercentage: json['completionPercentage'] != null
          ? json['completionPercentage']
          : null,
      raw: json,
    );
  }
  // int getDomainCout() => this.additionalTags.every((element) => element.area = 458).length;
}
