import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/models/_models/hall_of_fame_mdo_model.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';

import '../../constants/_constants/api_endpoints.dart';
import '../../models/_models/course_model.dart';

class LandingPageService {
  Future<HallOfFameMdoListModel> getListOfMdo({String pathUrl}) async {
    String _errorMessage;

    String headerData = 'application/json';
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: headerData,
      HttpHeaders.acceptHeader: headerData,
    };

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getListOfMdo),
        headers: headers);
    if (response.statusCode == 200) {
      try {
        var contents = jsonDecode(response.body);
        HallOfFameMdoListModel mdoList =
            HallOfFameMdoListModel.fromJson(contents);
        return mdoList;
      } catch (e) {
        throw 'error';
      }
    } else {
      _errorMessage = response.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<LandingPageInfo> getLandingPageInfo() async {
    Response response = await get(
      Uri.parse(Env.configUrl),
    );
    var contents = jsonDecode(response.body);
    LandingPageInfo landingPageInfo = LandingPageInfo.fromJson(contents);
    return landingPageInfo;
  }

  Future<List<Course>> getFeaturedCourses({String pathUrl}) async {
    String _errorMessage;
    List<Course> courses = [];
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl +
          (pathUrl != null ? pathUrl : ApiUrl.getFeaturedCourses)),
    );
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      List<dynamic> body = contents['result']['content'];
      if (body == null) return [];
      courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      // print(courses);
      return courses;
    } else {
      _errorMessage = response.statusCode.toString();
      throw _errorMessage;
    }
    // LandingPageInfo landingPageInfo = LandingPageInfo.fromJson(contents);
    // return landingPageInfo;
  }

  static Future<dynamic> getUserNudgeInfo() async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserNudgeConfig),
    );

    var contents = jsonDecode(response.body);
    return contents;
  }

  static Future<dynamic> getOverlayThemeData() async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getOverlayThemeData),
    );

    var contents = jsonDecode(response.body);
    return contents;
  }
}
