import 'package:flutter/material.dart';

class CreatorModel {
  final String id;
  final String name;
  final String email;
  CreatorModel({
    @required this.id,
    @required this.name,
    @required this.email,
  });
  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
