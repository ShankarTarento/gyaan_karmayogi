import 'package:flutter/material.dart';

class UserFeed {
  String feedId;
  String userId;
  String category;
  dynamic expireOn;
  int priority;
  String status;
  dynamic data;
  dynamic createdOn;
  final rawData;

  UserFeed({
    this.feedId,
    this.userId,
    this.category,
    this.expireOn,
    this.priority,
    this.status,
    this.data,
    this.createdOn,
    @required this.rawData,
  });

  factory UserFeed.fromJson(Map<String, dynamic> json) {
    return UserFeed(
      feedId: json['id'],
      userId: json['userId'],
      category: json['category'],
      expireOn: json['expireOn'],
      priority: json['priority'],
      status: json['status'],
      data: json['data'],
      createdOn: json['createdOn'],
      rawData: json,
    );
  }
}
