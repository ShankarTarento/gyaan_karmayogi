import 'package:flutter/foundation.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class UserNudgeInfo {
  final int startSlot;
  final int endSlot;
  final String backgroundImage;
  final String centerImage;
  final String text;
  final String content;
  final String textColor;

  const UserNudgeInfo(
      {@required this.startSlot,
      @required this.endSlot,
      @required this.backgroundImage,
      @required this.centerImage,
      @required this.text,
      @required this.content,
      @required this.textColor});

  factory UserNudgeInfo.fromJson(Map<String, dynamic> json) {
    return UserNudgeInfo(
        startSlot: int.parse(json['startTime'].toString()),
        endSlot: int.parse(json['endTime'].toString()),
        backgroundImage: json['mobileBackgroupImage'] != null
            ? ApiUrl.baseUrl + json['mobileBackgroupImage']
            : '',
        centerImage: ApiUrl.baseUrl +
            json['centerImage']
                [Helper.getRandomNumber(range: json['info'].length)],
        text: json['greet'],
        content: json['info']
            [Helper.getRandomNumber(range: json['info'].length)],
        textColor: json['textColor']);
  }
}
