import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/util/login_error_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/_models/batch_model.dart';
import '../respositories/_respositories/login_respository.dart';
import './../constants/index.dart';
import 'package:http/http.dart' as http;

class Helper {
  // static String getInitials(String name) => name.isNotEmpty
  //     ? name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
  //     : '';

  static bool get itsProdRelease =>
    APP_ENVIRONMENT == Environment.prod && kReleaseMode;
  static String getInitials(String name) {
    final _whitespaceRE = RegExp(r"\s+");
    String cleanupWhitespace(String input) =>
        input.replaceAll(_whitespaceRE, " ");
    name = cleanupWhitespace(name);
    if (name.isNotEmpty) {
      return name
          .trim()
          .split(' ')
          .map((l) => l[0])
          .take(2)
          .join()
          .toUpperCase();
    } else {
      return '';
    }
  }

  static String getInitialsNew(String name) {
    String shortCode = 'UN';
    if (name != null) {
      name = name.trim();
      name = name.replaceAll(RegExp(r'\s+'), ' ');
      List temp = name.split(' ');
      // print(temp.toString());
      if (temp.length > 1) {
        shortCode = temp[0][0].toUpperCase() + temp[1][0].toUpperCase();
      } else if (temp[0] != '') {
        // print(temp.toString());
        // shortCode = temp[0][0].toUpperCase() + temp[0][1].toUpperCase();
        shortCode = temp[0][0].toUpperCase();
      }
    }
    return shortCode;
  }

  /// Return login auth token as response
  static Future<dynamic> getNewToken() async {
    final _storage = FlutterSecureStorage();
    String refreshToken = await _storage.read(key: Storage.refreshToken);

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      HttpHeaders.acceptHeader: '*/*',
    };

    Map body = {
      'client_id': Client.androidClientId,
      'scope': 'offline_access',
      'grant_type': 'refresh_token',
      'refresh_token': '$refreshToken'
    };

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.keyCloakLogin),
        headers: headers,
        body: body);

    return response;
  }

  static Map<String, String> getHeaders(
      String token, String wid, String rootOrgId) {
    if (!isTokenExpired(token)) {
      // getNewToken(token, wid);
    }
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'rootorg': 'igot',
      'userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> getCourseHeaders(
      String token, String wid, String courseId, String rootOrgId) {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'resourceId': '$courseId',
      'rootOrg': 'igot',
      // 'userid': '$wid',
      'userUUID': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> discussionGetHeaders(String token, String wid) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> getHeader() {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> formDataHeader() {
    Map<String, String> headers = {
      // 'Content-Type':
      //     'multipart/form-data; boundary=<calculated when request is sent>',
      // 'Accept': '*/*',
      // 'hostpath': ApiUrl.baseUrl,
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> knowledgeResourceGetHeaders(String token) {
    Map<String, String> headers = {
      'Authorization': 'bearer $token',
    };
    return headers;
  }

  static Map<String, String> postHeaders(
      String token, String wid, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json',
      'hostpath': ApiUrl.baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'wid': '$wid',
      'userId': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> notificationPostHeaders(
      String token, String wid, String rootOrgId) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> profilePostHeaders(
      String token, String wid, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json',
      'x-authenticated-userid': '$wid',
      'wid': '$wid',
      'userId': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> discussionPostHeaders(
      String token, String wid, String rootOrgId) {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> postCourseHeaders(
      String token, String wid, String courseId, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json; charset=utf-8',
      'hostpath': ApiUrl.baseUrl,
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

  static Map<String, String> curatedProgramPostHeaders(
      String token, String wid, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json; charset=utf-8',
      'hostpath': ApiUrl.baseUrl,
      'userUUID': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> knowledgeResourcePostHeaders(
      String token, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> registerPostHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    return headers;
  }

  static Map<String, String> registerRequestFieldHeader() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'rootOrg': 'igot',
      'org': 'dopt'
    };
    return headers;
  }

  static Map<String, String> registerParichayUserPostHeaders(token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
    };
    return headers;
  }

  static Map<String, String> signUpPostHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> insightHeader(String wid, String token) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'Content-Type': 'application/json',
      'hostpath': ApiUrl.baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'wid': '$wid',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
    };
    return headers;
  }

  static int calculateProfilePercent(profile) {
    double count = 30;
    if (profile.education.length != 0 &&
        (profile.education[0]['nameOfInstitute'] != '' ||
            profile.education[0]['nameOfQualification'] != '')) {
      count += 23;
    }
    // print(profile.department);
    if (profile.department != '' && profile.department != null) {
      count += 11.43;
    }
    if (profile.personalDetails['nationality'] != '' &&
        profile.personalDetails['nationality'] != null) {
      count += 11.43;
    }
    if (profile.photo != '' && profile.photo != null) {
      count += 11.43;
    }
    if (profile.designation != '' && profile.designation != null) {
      count += 11.43;
    }
    if (profile.skills != null) {
      if (profile.skills['additionalSkills'] != '' &&
          profile.skills['additionalSkills'] != null) {
        count += 11.43;
      }
    }
    if (profile.interests != null) {
      if (profile.interests['hobbies'] != null) {
        if (profile.interests['hobbies'].length > 0) {
          count += 11.43;
        }
      }
    }
    if (count > 100) {
      count = 100;
    }
    return count.round();
  }

  static capitalize(String s) {
    if (s.trim().isNotEmpty && (s[0] != null && s[0] != '')) {
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    } else
      return s;
  }

  static capitalizeFirstLetter(String s) {
    if (s.trim().isNotEmpty && (s[0] != null && s[0] != '')) {
      return s[0].toUpperCase() + s.substring(1);
    } else
      return s;
  }

  static getByteImage(base64Image) {
    dynamic _bytes = base64.decode(base64Image.split(',').last);
    return _bytes;
  }

  static checkEducationIsFilled(education) {
    bool isGiven = false;
    for (int i = 0; i < education.length; i++) {
      if (education[i]['nameOfQualification'] != '') {
        isGiven = true;
      }
    }
    return isGiven;
  }

  static getFileName(String url) {
    File file = new File(url);
    String fullFileName = file.path.split('/').last;
    List fileName = fullFileName.split('.');
    return fileName[0];
  }

  static getFileExtension(String url) {
    File file = new File(url);
    String fullFileName = file.path.split('/').last;
    List fileName = fullFileName.split('.');
    // print(fileName[fileName.length - 1]);
    return fileName[fileName.length - 1];
  }

  static getTimeFormat(duration) {
    int hours = Duration(seconds: int.parse(duration)).inHours;
    int minutes = Duration(seconds: int.parse(duration)).inMinutes;
    String time;
    if (hours > 0) {
      time = hours.toString() + 'h ' + (minutes - hours * 60).toString() + 'm';
    } else {
      time = minutes.toString() + ' m';
    }
    return time;
  }

  static TimeOfDay getTimeIn24HourFormat(String timeIn12HourFormat) {
    List timeSplits = timeIn12HourFormat.split(':'); // eg. 12:30 PM
    String hourString = timeSplits.first;
    String minString = timeSplits.last.split(' ').first;
    int min = int.parse(minString);
    int hour = int.parse(hourString);
    hour =
        (hour != 12 && timeSplits.last.toString().toLowerCase().contains('pm'))
            ? hour + 12
            : hour;

    return TimeOfDay(hour: hour, minute: min);
  }

  static bool isSessionLive(SessionDetailV2 session) {
    try {
      DateTime sessionDate = DateTime.parse(session.startDate);
      TimeOfDay startTime = getTimeIn24HourFormat(session.startTime);
      DateTime sessionStartDateTime = DateTime(sessionDate.year,
          sessionDate.month, sessionDate.day, startTime.hour, startTime.minute);
      DateTime sessionStartEndTime = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          startTime.hour +
              (int.parse((session.sessionDuration).split('hr')[0])) +
              AttendenceMarking.bufferHour,
          startTime.minute);
      final bool isLive = (DateTime.now().isAfter(sessionStartDateTime) &&
          DateTime.now().isBefore(sessionStartEndTime));
      return isLive;
    } catch (e) {
      return false;
    }
  }

  static String getDateTimeInFormat(String dateTime,
      {String desiredDateFormat}) {
    if (desiredDateFormat == null) {
      desiredDateFormat = IntentType.dateFormat;
    }
    final DateFormat formatter = DateFormat(desiredDateFormat);
    return formatter.format(DateTime.parse(dateTime));
  }

  static getFullTimeFormat(duration, {bool timelyDurationFlag = false}) {
    // print('duration: $duration');
    int hours = Duration(seconds: int.parse(duration)).inHours;
    int minutes = Duration(seconds: int.parse(duration)).inMinutes;
    int seconds = Duration(seconds: int.parse(duration)).inSeconds;
    String time;
    if (hours > 0) {
      if ((minutes - hours * 60) > 0) {
        time = hours.toString() +
            (timelyDurationFlag
                ? hours == 1
                    ? ' hour '
                    : ' hours '
                : 'h ') +
            (minutes - hours * 60).toString() +
            (timelyDurationFlag
                ? (minutes - hours * 60) == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ');
      } else {
        time = hours.toString() +
            (timelyDurationFlag
                ? hours == 1
                    ? ' hour '
                    : ' hours '
                : 'h ');
      }
    } else if (minutes > 0) {
      if ((seconds - minutes * 60) > 0) {
        time = minutes.toString() +
            (timelyDurationFlag
                ? minutes == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ') +
            (seconds - minutes * 60).toString() +
            (timelyDurationFlag
                ? seconds - minutes * 60 == 1
                    ? ' second '
                    : ' seconds '
                : 's');
      } else {
        time = minutes.toString() +
            (timelyDurationFlag
                ? minutes == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ');
      }
    } else {
      time = seconds.toString() +
          (timelyDurationFlag
              ? seconds == 1
                  ? ' second '
                  : ' seconds '
              : 's');
    }
    return time;
  }

  static getMilliSecondsFromTimeFormat(String duration) {
    List data = duration.split(' ');
    int totalDuration = 0;
    RegExp regex = RegExp(
        r'^\s*\d+\s*(h|hr|hour|hrs|m|min|minute|mins|s|sec|second|secs)\s*$',
        caseSensitive: false);
    data.removeWhere((element) => !(regex.hasMatch(element)));
    for (var i = 0; i < data.length; i++) {
      int value =
          int.parse(data[i].toString().substring(0, data[i].length - 1));
      if (data[i].contains('h')) {
        totalDuration = totalDuration + (value * 60 * 60);
      } else if (data[i].contains('m')) {
        totalDuration = totalDuration + (value * 60);
      } else if (data[i].contains('s')) {
        totalDuration = totalDuration + value;
      }
    }
    // print(totalDuration);
    return totalDuration;
  }

  static bool isTokenExpired(String token) {
    // print('isTokenExpired...');
    bool isTokenExpired = JwtDecoder.isExpired(token);
    if (isTokenExpired) {
      Provider.of<LoginRespository>(navigatorKey.currentContext, listen: false)
          .clearData();
      navigatorKey.currentState?.pushNamed(AppUrl.loginPage);
    }
    return isTokenExpired;
  }

  static String svgDecoder(String svgString) {
    // developer.log(svgString.length.toString());
    const encoderHash = {
      "%": "%25",
      "<": "%3C",
      ">": "%3E",
      " ": "%20",
      "!": "%21",
      "*": "%2A",
      "'": "%27",
      '"': "%22",
      "(": "%28",
      ")": "%29",
      ";": "%3B",
      ":": "%3A",
      "@": "%40",
      "&": "%26",
      "=": "%3D",
      "+": "%2B",
      // "\$": "%24",
      ",": "%2C",
      "/": "%2F",
      "?": "%3F",
      "#": "%23",
      "[": "%5B",
      "]": "%5D"
    };

    String svgImage = svgString;
    encoderHash.forEach((final String target, final String source) {
      svgImage = svgImage.replaceAll(source, target);
    });

    // developer.log("After: " + svgImage.replaceAll("data:image/svg+xml,", ""));

    return svgImage.replaceAll("data:image/svg+xml,", "");
    // return svgImage;
  }

  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static getMonth(String month) {
    int intMonth = 0;
    switch (month) {
      case 'Jan':
        intMonth = 1;
        break;
      case 'Feb':
        intMonth = 2;
        break;
      case 'Mar':
        intMonth = 3;
        break;
      case 'Apr':
        intMonth = 4;
        break;
      case 'May':
        intMonth = 5;
        break;
      case 'Jun':
        intMonth = 6;
        break;
      case 'Jul':
        intMonth = 7;
        break;
      case 'Aug':
        intMonth = 8;
        break;
      case 'Sep':
        intMonth = 9;
        break;
      case 'Oct':
        intMonth = 10;
        break;
      case 'Nov':
        intMonth = 11;
        break;
      case 'Dec':
        intMonth = 12;
        break;
      default:
    }
    return intMonth;
  }

  static showErrorScreen(context, String errorMsg, {int statusCode}) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginErrorPage(
          errorText: errorMsg,
          isHtmlErrorPage: statusCode == 401,
        ),
      ),
    );
  }

  static showErrorPopup(context, String errorMsg, {int statusCode}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unable to fetch the data',
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.12,
                height: 1.5)),
        content: Text(
          'Please try after sometime',
          style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        actions: <Widget>[
          Container(
            width: 87,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryThree,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                AppLocalizations.of(context).mStaticOk,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static convertToPortalUrl(String s) {
    if (s != null) {
      String cleaned = s.replaceAll("http://", "https://");
      return cleaned.replaceAll(Env.baseUrl, Env.portalBaseUrl);
    }
  }

  static convertImageUrl(String url) {
    if (url != null) {
      String cleaned = url.replaceAll("http://", "https://");
      List urlParts = cleaned.split('/content');
      return Env.host + '/' + Env.bucket + '/content' + urlParts.last;
    }
  }

  static convertPortalImageUrl(String url) {
    String splitValue;
    if (url != null) {
      if (APP_ENVIRONMENT == Environment.preProd) {
        splitValue = EnvironmentValues.igot.name;
      } else if (APP_ENVIRONMENT == Environment.qa) {
        splitValue = EnvironmentValues.igotqa.name;
      } else if (APP_ENVIRONMENT == Environment.bm) {
        splitValue = EnvironmentValues.igotbm.name;
      } else if (APP_ENVIRONMENT == Environment.prod) {
        splitValue = EnvironmentValues.igotprod.name;
      }
      List urlParts = url.split(splitValue);
      return Env.host + Env.bucket + urlParts.last;
    }
  }

  static extractIntegerOnly(String s) {
    String result = s.replaceAll(new RegExp(r'[^0-9]'), '');
    return int.parse(result[0]);
  }

  static getDownloadPath() async {
    Directory directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory(APP_DOWNLOAD_FOLDER);
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      throw "Cannot get download folder path";
    }
    return directory?.path;
  }

  static getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    return appDocumentsPath;
  }

  static generateRandomString() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-';
    Random _rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String randomString = getRandomString(16);
    return randomString;
  }

  String capitalizeFirstCharacter(String word) {
    return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
  }

  String capitalizeEachWordFirstCharacter(String word) {
    String formattedText = word
        .split(' ')
        .map((element) => textToTitleCase(element))
        .toList()
        .join(' ');
    return formattedText;
  }

  String textToTitleCase(String text) {
    if (text.length > 1) {
      return text[0].toUpperCase() + text.substring(1);
    } else if (text.length == 1) {
      return text[0].toUpperCase();
    }
    return '';
  }

  static int getRandomNumber({int range}) {
    Random random = new Random();
    return random.nextInt(range);
  }

  static Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response?.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  static getFormattedTopic(List<String> topics) {
    return topics.join('_');
  }

  static DateTime convertDDMMYYYYtoDateTime(String date) {
    return DateTime.parse(date.toString().split('-').reversed.join('-'));
  }

  static String convertDatetimetoDDMMYYYY(DateTime date) {
    return date.toString().split(' ').first.split('-').reversed.join('-');
  }

  static showSnackBarMessage(
      {@required BuildContext context,
      @required String text,
      @required Color bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            style: GoogleFonts.lato(
              color: Colors.white,
            )),
        backgroundColor: bgColor,
      ),
    );
  }

  static Future<void> doLaunchUrl(
      {String url, LaunchMode mode = LaunchMode.platformDefault}) async {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: mode);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      await launchUrl(Uri.parse(url));
    }
  }

  static String getLinkedlnUrlToShareCertificate(String certificateId) {
    return ApiUrl.linkedlnUrlToShareCertificate
        .replaceAll('#certId', certificateId);
  }

  static String formatDate(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.format(dateTime);
  }

  static String numberWithSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
