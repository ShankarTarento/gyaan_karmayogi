import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helper {
  static Map<String, String> postHeaders(
      {@required String token,
      @required String wid,
      @required String apiBaseUrl,
      @required String apiKey,
      @required String rootOrgId}) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json',
      'hostpath': apiBaseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'wid': '$wid',
      'userId': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> getHeaders(
      {@required String apiKey, String token, String wid, String rootOrgId}) {
    // developer.log(token);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'rootorg': 'igot',
      'userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static String getDateTimeInFormat(
      {@required String dateTime, @required String desiredDateFormat}) {
    final DateFormat formatter = DateFormat(desiredDateFormat);
    return formatter.format(DateTime.parse(dateTime));
  }

  static capitalize(String s) {
    if (s.trim().isNotEmpty && (s[0] != null && s[0] != '')) {
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    } else
      return s;
  }

  static Map<String, String> postCourseHeaders(
      {String apiKey,
      String baseUrl,
      String token,
      String wid,
      String courseId,
      String rootOrgId}) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json; charset=utf-8',
      'hostpath': baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'courseId': '$courseId',
      'userUUID': '$wid',
      'x-authenticated-userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }
}
