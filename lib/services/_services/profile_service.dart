import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import './../../constants/index.dart';
import './../../util/helper.dart';

class ProfileService {
  final _storage = FlutterSecureStorage();

  Future<dynamic> getProfileDetails() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    String profileDetailsUrl = ApiUrl.baseUrl + ApiUrl.getProfileDetails;
    Response response = await get(Uri.parse(profileDetailsUrl),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  Future<dynamic> getProfileMandatoryFields() async {
    String mandatoryFieldsUrl =
        ApiUrl.baseUrl + ApiUrl.getProfileMandatoryFields;
    Response response =
        await get(Uri.parse(mandatoryFieldsUrl), headers: Helper.getHeader());
    var content = jsonDecode(response.body);
    List mandatoryFields = [];
    if (response.statusCode == 200) {
      mandatoryFields =
          (content['result'] != null && content['result']['response'] != null)
              ? content['result']['response']['value'].toString().split(',')
              : [];
    } else {
      return mandatoryFields;
    }

    return mandatoryFields;
  }

  Future<dynamic> getProfileDetailsById(String id) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    String profileDetailsUrl =
        ApiUrl.baseUrl + ApiUrl.getProfileDetailsByUserId;
    // print("profilrdetailsbyid url ${profileDetailsUrl + id}");
    Response response = await get(
        Uri.parse(profileDetailsUrl + (id == '' ? wid : id)),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // log('Profile details' + response.body);
    return response;
  }

  Future<dynamic> updateProfileDetails(Map profileDetails) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    // var _profileDetails = json.encode(profileDetails);
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return jsonDecode(response.body);
  }

  Future<dynamic> updateGetStarted({bool isSkipped = false}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map getStartedObj = {"visited": true, "skipped": isSkipped};
    Map profileDetails = {'get_started_tour': getStartedObj};
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return jsonDecode(response.body);
  }

  Future<dynamic> getInReviewFields() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "serviceName": "profile",
      "applicationStatus": "SEND_FOR_APPROVAL"
    };

    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getInReviewFields),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);

    return jsonDecode(response.body);
  }

  Future<dynamic> getNationalities() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getNationalities),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  Future<dynamic> getLanguages() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLanguages),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getDegrees(String type) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getDegrees),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body);
    return response;
  }

  Future<dynamic> getOrganisations() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDepartments),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getIndustries() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getIndustries),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getDesignations() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDesignationsAndGradePay),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getEhrmsDetails() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getEhrmsDetails),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    return response;
  }

  Future<dynamic> getGradePay() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfilePageMeta),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  // getServicesAndCadre

  Future<dynamic> getServices() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getServicesAndCadre),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getCadre() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    Response response = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getCadre),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getProfilePageMeta() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfilePageMeta),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      // print(contents['designations']);
      return contents;
    } else {
      throw 'Can\'t get profile page meta.';
    }
  }

  /// Return username
  Future<dynamic> getUserName(String wid) async {
    final _storage = FlutterSecureStorage();

    String token = await _storage.read(key: Storage.authToken);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.basicUserInfo + wid),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    return response;
  }

  // To send the OTP to mobile number
  Future<dynamic> generateMobileNumberOTP(String mobileNumber) async {
    Map data = {
      "request": {"type": "phone", "key": "$mobileNumber"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTP;
    // print("$url");
    final response = await post(Uri.parse(url),
        headers: Helper.signUpPostHeaders(), body: body);
    return jsonDecode(response.body);
  }

  //To verify the OTP
  Future<dynamic> verifyMobileNumberOTP(String mobileNumber, String otp) async {
    Map data = {
      "request": {"type": "phone", "key": "$mobileNumber", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTP;
    final response = await post(Uri.parse(url),
        headers: Helper.signUpPostHeaders(), body: body);
    // developer.log(jsonDecode(response.body).toString());
    return jsonDecode(response.body);
  }

  // To send the OTP to email
  Future<dynamic> generatePrimaryEmailOTP(String email) async {
    String token = await _storage.read(key: Storage.authToken);
    Map data = {
      "request": {
        "type": "email",
        "key": "$email",
        "contextType": "extPatch",
        "contextAttributes": [
          "profileDetails.personalDetails.primaryEmail",
        ]
      }
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTPv3;
    // print("$url");
    final response = await post(Uri.parse(url),
        headers: Helper.registerParichayUserPostHeaders(token), body: body);
    // log(response.body.toString());
    return jsonDecode(response.body);
  }

  //To verify the OTP of email
  Future<dynamic> verifyPrimaryEmailOTP(String email, String otp) async {
    String token = await _storage.read(key: Storage.authToken);
    Map data = {
      "request": {"type": "email", "key": "$email", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTPv3;
    final response = await post(Uri.parse(url),
        headers: Helper.registerParichayUserPostHeaders(token), body: body);
    // log('verify otp: ' + response.body.toString());
    return jsonDecode(response.body);
  }

  Future<dynamic> updateUserPrimaryEmail(
      {@required String email, @required String contextToken}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "request": {
        "userId": "$wid",
        "profileDetails": {
          "personalDetails": {"primaryEmail": "$email"}
        },
        "contextToken": "$contextToken"
      }
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetailsV2;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    // log('update primary email: ' + response.body.toString());
    return jsonDecode(response.body);
  }

  // To send the OTP to email address
  Future<dynamic> generateEmailOTP(String emailAddress) async {
    Map data = {
      "request": {"type": "email", "key": "$emailAddress"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTP;
    // print("$url");
    final response = await post(Uri.parse(url),
        headers: Helper.signUpPostHeaders(), body: body);
    return jsonDecode(response.body);
  }

  // To verify the Email OTP
  Future<dynamic> verifyEmailOTP(String emailId, String otp) async {
    Map data = {
      "request": {"type": "email", "key": "$emailId", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTP;
    final response = await post(Uri.parse(url),
        headers: Helper.signUpPostHeaders(), body: body);
    // developer.log(jsonDecode(response.body).toString());
    return jsonDecode(response.body);
  }

  //get edit profile configuration
  Future<dynamic> getProfileEditConfig() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfileEditConfig),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return jsonDecode(response.body);
  }

  // To get user insights
  Future<dynamic> getUserInsights() async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    String url = ApiUrl.baseUrl + ApiUrl.getInsights;
    Map data = {
      "request": {
        "filters": {
          "primaryCategory": "programs",
          "organisations": ["across", rootOrgId]
        }
      }
    };
    var body = json.encode(data);
    final response = await post(Uri.parse(url),
        headers: Helper.insightHeader(wid, token), body: body);
    return response;
  }

  // To update profile photo
  Future<dynamic> uploadProfilePhoto(File image) async {
    String url = ApiUrl.baseUrl + ApiUrl.uploadProfilePhoto;

    var formData = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(Helper.formDataHeader());
    formData.files.add(await MultipartFile.fromPath('file', image.path));
    try {
      final response = await formData.send();
      return response;
    } catch (e) {
      print(e);
    }
  }

  // Read karma points(or get history of karma points)
  Future<dynamic> getKarmaPointHistory({limit, offset}) async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    Map data = {'limit': limit, 'offset': offset.toString()};
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.karmaPointRead;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  // Get Total karma point info
  Future<dynamic> getTotalKarmaPoint() async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    var body = json.encode({});
    String url = ApiUrl.baseUrl + ApiUrl.totalKarmaPoint;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  // read karma point for course
  Future<dynamic> getKarmaPointCourseRead(String courseId) async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    var body = json.encode({
      "request": {
        "filters": {"contextType": "Course", "contextId": courseId}
      }
    });
    String url = ApiUrl.baseUrl + ApiUrl.karmapointCourseRead;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  // Claim karma points
  Future<dynamic> claimKarmaPoints(String courseId) async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    var body = json.encode({"userId": wid, "courseId": courseId});
    String url = ApiUrl.baseUrl + ApiUrl.claimKarmaPoints;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  /// share course -start
  Future<dynamic> getRecipientList(String query, int limit) async {
    final _storage = FlutterSecureStorage();
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "query": query,
        "filters": {"rootOrgId": rootOrgId, "status": 1},
        "fields": ["firstName", "maskedEmail", "userId", "profileDetails"],
        "limit": limit
      }
    };

    String body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUsersByEndpoint),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);

    Map usersList = json.decode(response.body);

    return usersList;
  }

  Future<dynamic> shareCourse(formId, recipients, courseId, courseName,
      coursePosterImageUrl, courseProvider, primaryCategory) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "courseId": courseId,
        "courseName": courseName,
        "coursePosterImageUrl": coursePosterImageUrl,
        "courseProvider": courseProvider,
        "primaryCategory": primaryCategory,
        "recipients": recipients
      }
    };

    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.shareCourse),
        headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['params']['status'];
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  ///Share course -end

  /// Learner leaderboard
  Future<dynamic> getLeaderboardData() async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    String url = ApiUrl.baseUrl + ApiUrl.getLeaderboardData;

    final response = await get(Uri.parse(url), headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  Future<dynamic> updateLeaderboardNudgeData(String currentDate) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map profileDetails = {'lastMotivationalMessageTime': '$currentDate'};
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId), body: body);
    return jsonDecode(response.body);
  }
}
