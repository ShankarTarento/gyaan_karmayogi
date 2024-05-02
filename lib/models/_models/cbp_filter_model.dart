import 'dart:convert';

import 'package:flutter/material.dart';

CBPFilterModel cbpFilterModelFromJson(String str) =>
    CBPFilterModel.fromJson(json.decode(str));

class CBPFilterModel {
  String category;
  List<Filter> filters;

  CBPFilterModel({
    @required this.category,
    @required this.filters,
  });

  factory CBPFilterModel.fromJson(Map<String, dynamic> json) => CBPFilterModel(
        category: json["category"],
        filters:
            List<Filter>.from(json["filters"].map((x) => Filter.fromJson(x))),
      );
}

class Filter {
  String name;
  bool isSelected;
  String providerId;

  Filter({@required this.name, this.isSelected = false, this.providerId});

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
      name: json["name"],
      isSelected: json["isSelected"],
      providerId: json['providerId']);
}
