import 'package:flutter/material.dart';

class VegaHelpItem {
  final String heading;
  final String description;
  final List<dynamic> intents;

  const VegaHelpItem({
    @required this.heading,
    this.description,
    @required this.intents,
  });

  factory VegaHelpItem.fromJson(Map<String, dynamic> json) {
    return VegaHelpItem(
        heading: json['heading'],
        description: json['description'],
        intents: json['intents']);
  }
}
