import 'package:flutter/material.dart';

class Suggestion {
  final String id;
  final String firstName;
  final String lastName;
  final String department;
  final String photo;
  final bool verifiedKarmayogi;
  final rawDetails;

  Suggestion(
      {@required this.id,
      @required this.firstName,
      @required this.lastName,
      @required this.department,
      @required this.photo,
      @required this.rawDetails,
      this.verifiedKarmayogi});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as String,
      firstName: json['personalDetails']['firstname'] as String,
      lastName: json['personalDetails']['surname'] != null
          ? json['personalDetails']['surname']
          : '',
      department: json['employmentDetails']['departmentName'] as String,
      photo: json['photo'] != null ? json['photo'] : '',
      verifiedKarmayogi: json['verifiedKarmayogi'],
      rawDetails: json,
    );
  }
}
