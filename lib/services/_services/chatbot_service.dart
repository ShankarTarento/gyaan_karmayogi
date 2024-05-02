
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'dart:convert';

import 'package:karmayogi_mobile/util/helper.dart';

class ChatbotService {
  Future<dynamic> getFaqAvailableLang() async {
    final res = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getFaqAvailableLangUrl),
    );
    var content;
    if (res.statusCode == 200) {
      content = jsonDecode(res.body)['payload']['languages'];
    }
    return content;
  }

  Future<dynamic> getFaqData({String lang, String configType}) async {
    Map data = {"lang": lang, "config_type": configType};

    var body = jsonEncode(data);
    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.getFaqDataUrl),
        headers: Helper.registerPostHeaders(), body: body);
    var content;
    if (res.statusCode == 200) {
      try {
        content = jsonDecode(res.body)['payload']['config'];
      } catch (e) {
        print(e);
      }
    }
    return content;
  }
}
