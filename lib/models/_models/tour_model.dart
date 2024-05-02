import 'package:flutter/material.dart';

class TourModel {
  final String title;
  final String description;
  final String insideTitle;

  TourModel(
      {@required this.title,
      @required this.description,
      @required this.insideTitle});

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      title: json['title'] as String,
      // description: json['teaser']['content'] as String,
      description: json['description'] as String,
      insideTitle: json['insideTitle'] as String,
    );
  }
}
