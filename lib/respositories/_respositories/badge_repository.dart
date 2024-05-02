import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/models/_models/badge_model.dart';
import 'package:karmayogi_mobile/services/_services/badge_service.dart';

class BadgeRepository with ChangeNotifier {
  final BadgeService badgeService = BadgeService();
  String _errorMessage = '';
  Response _data;

  Future<List<BadgeItem>> getEarnedBadges() async {
    try {
      final response = await badgeService.getEarnedBadges();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = contents['earned'];
      List<BadgeItem> badges = body
          .map(
            (dynamic item) => BadgeItem.fromJson(item),
          )
          .toList();
      return badges;
    } else {
      // throw 'Can\'t get badges.';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<BadgeItem>> getCanEarnBadges() async {
    try {
      final response = await badgeService.getCanEarnBadges();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = contents['canEarn'];
      List<BadgeItem> badges = body
          .map(
            (dynamic item) => BadgeItem.fromJson(item),
          )
          .toList();
      return badges;
    } else {
      // throw 'Can\'t get badges.';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }
}
