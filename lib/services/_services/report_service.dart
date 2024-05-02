import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'dart:convert';
import 'dart:async';
import './../../constants/index.dart';

class ReportService {
  final String createFlagUrl = ApiUrl.baseUrl + ApiUrl.createFlag;
  final String getFlaggedDataByUserIdUrl =
      ApiUrl.baseUrl + ApiUrl.getFlaggedData;
  final String updateFlaggedDataUrl = ApiUrl.baseUrl + ApiUrl.updateFlaggedData;
  final _storage = FlutterSecureStorage();

  Future<dynamic> createFlag(
      String contextType, String contextTypeId, String reason) async {
    String token = await _storage.read(key: Storage.authToken);

    Map data = {
      "request": {
        "contextType": "$contextType",
        "contextTypeId": "$contextTypeId",
        "acquiredChannel": "mobile",
        "additionalParams": {"reason": "$reason"}
      }
    };
    var body = json.encode(data);

    // log(body.toString());

    Response res = await post(Uri.parse(createFlagUrl),
        headers: Helper.registerParichayUserPostHeaders(token), body: body);

    // log(res.body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      // print(contents);
      return contents;
    } else {
      return res.statusCode;
    }
  }

  Future<dynamic> getFlaggedDataByUserId() async {
    String token = await _storage.read(key: Storage.authToken);
    try {
      Response response = await get(Uri.parse(getFlaggedDataByUserIdUrl),
          headers: Helper.registerParichayUserPostHeaders(token));
      // log(response.body.toString());

      if (response.statusCode == 200) {
        // log(response.body.toString());
        var contents = jsonDecode(response.body)['result']['Content'];
        return contents;
      } else {
        throw response.statusCode;
      }
    } catch (e) {
      return [];
    }

    // developer.log(positions.toString());
    // return positions;
  }

  // Future<dynamic> updateFlag(String contextType, String contextTypeId,
  //     String reason, String contextStatus) async {
  //   String token = await _storage.read(key: Storage.authToken);

  //   Map data = {
  //     "request": {
  //       "contextType": "$contextType",
  //       "contextTypeId": "$contextTypeId",
  //       "contextStatus": "$contextStatus",
  //       "additionalParams": {"reason": "$reason"}
  //     }
  //   };
  //   var body = json.encode(data);

  //   log(body.toString());

  //   Response res = await patch(Uri.parse(updateFlaggedDataUrl),
  //       headers: Helper.registerParichayUserPostHeaders(token), body: body);
  //   log(res.body);

  //   // if (res.statusCode == 200) {
  //   //   var contents = jsonDecode(res.body);
  //   //   print(contents);
  //   //   return contents;
  //   // } else {
  //   //   return res.statusCode;
  //   // }
  // }
}
