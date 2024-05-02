import 'dart:convert';

import 'package:flutter/material.dart';

import '../index.dart';

TocPlayerModel tocPlayerModelFromJson(String str) => TocPlayerModel.fromJson(json.decode(str));

class TocPlayerModel {
    List<Course> enrolmentList;
    List navigationItems;
    var contentProgressResponse;
    bool isCuratedProgram;
    String batchId, courseId;
    String lastAccessContentId;
    bool isFeatured;
    final VoidCallback onPopCallback;


    TocPlayerModel({
        @required this.enrolmentList,
        this.navigationItems,
        this.contentProgressResponse,
        this.isCuratedProgram,
        @required this.batchId,
        @required this.courseId,
        @required this.lastAccessContentId,
        this.isFeatured,
        this.onPopCallback
    });

    factory TocPlayerModel.fromJson(Map<String, dynamic> json) => TocPlayerModel(
        enrolmentList: json['enrolmentList'],
        navigationItems: json['navigationItems'] != null ?json['navigationItems'] : [],
        contentProgressResponse: json['contentProgressResponse'],
        isCuratedProgram: json['isCuratedProgram'] != null? json['isCuratedProgram']: false,
        batchId: json['batchId'],
        lastAccessContentId: json['lastAccessContentId'],
        isFeatured: json['isFeatured'] != null ? json['isFeatured'] : false,
        courseId: json['courseId'],
        onPopCallback: json['onPopCallback']
    );
}
