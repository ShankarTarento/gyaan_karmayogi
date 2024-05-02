import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import '../../constants/_constants/storage_constants.dart';
import '../../util/helper.dart';

class FeedService {
  final _storage = FlutterSecureStorage();

  Future<dynamic> getFormFeed(userId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getFormFeed + userId),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  getFormById(formId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getFormId + formId.toString()),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    return response;
  }

  submitForm(formField, review, rating, formId) async {
    String ratingKey = 'Please rate your experience with the platform';
    String reviewKey = 'Tell us more about your experience';
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    if (formField != null) {
      List fields = formField['fields'] ?? [];
      fields.forEach((element) {
        if (element['fieldType'] == 'rating') {
          ratingKey = element['name'];
        }
        if (element['fieldType'] == 'textarea') {
          reviewKey = element['name'];
        }
      });
    }
    Map data = {
      "formId": formId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "version": formField['version'],
      "dataObject": rating == 0 ? {} : {ratingKey: rating, reviewKey: review}
    };
    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.submitForm),
        headers: Helper.getHeaders(token, wid, rootOrgId),
        body: body);
    return response;
  }

  deleteNPSFeed(userId, feedId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "userId": userId,
        "category": FeedCategory.nps,
        "feedId": feedId
      }
    };
    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.deleteFeed),
        headers: Helper.getHeaders(token, wid, rootOrgId),
        body: body);
    return response;
  }

  deleteInAppReviewFeed({@required String feedId}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "userId": wid,
        "category": FeedCategory.inAppReview,
        "feedId": feedId
      }
    };
    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.deleteFeed),
        headers: Helper.getHeaders(token, wid, rootOrgId),
        body: body);
    return response;
  }
}
