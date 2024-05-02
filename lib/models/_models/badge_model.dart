import 'package:flutter/material.dart';

class BadgeItem {
  final String image;
  final String name;
  final String group;
  final String recievedDate;

  const BadgeItem({
    @required this.image,
    @required this.name,
    @required this.group,
    @required this.recievedDate,
  });

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      image: json['image'] as String,
      name: json['badge_name'] as String,
      group: json['badge_group'] as String,
      recievedDate: json['first_received_date'] as String,
    );
  }
}
