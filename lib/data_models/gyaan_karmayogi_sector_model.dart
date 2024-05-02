import 'package:flutter/material.dart';

class GyaanKarmayogiSector {
  final String identifier;
  final String code;
  final String name;
  final String description;
  bool isSelected;
  final String iconUrl;
  List<SubSector> subSectors;

  GyaanKarmayogiSector({
    @required this.identifier,
    @required this.code,
    @required this.name,
    @required this.iconUrl,
    this.isSelected = false,
    @required this.description,
    @required this.subSectors,
  });

  factory GyaanKarmayogiSector.fromJson(Map<String, dynamic> json) {
    List<SubSector> subSectors = (json['children'] as List)
        .map((subSectorJson) => SubSector.fromJson(subSectorJson))
        .toList();

    return GyaanKarmayogiSector(
      identifier: json['identifier'],
      code: json['code'],
      name: json['name'],
      iconUrl: json["imgUrl"],
      description: json['description'],
      subSectors: subSectors,
    );
  }
}

class SubSector {
  final String identifier;
  final String name;
  final String description;
  bool isSelected;

  SubSector({
    @required this.identifier,
    this.isSelected = false,
    @required this.name,
    @required this.description,
  });

  factory SubSector.fromJson(Map<String, dynamic> json) {
    return SubSector(
      identifier: json['identifier'],
      name: json['name'],
      description: json['description'],
    );
  }
}
