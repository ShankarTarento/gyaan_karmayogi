import 'package:flutter/material.dart';

class FilterModel {
  String title;
  bool isSelected;

  FilterModel({@required this.title, this.isSelected = false});
}
