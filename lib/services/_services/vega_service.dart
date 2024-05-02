import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/vega_help.dart';
import 'package:karmayogi_mobile/models/_models/vega_help_model.dart';
import 'dart:convert';
import 'dart:async';
import './../../util/helper.dart';

class VegaService {
  final String suggestionsUrl = ApiUrl.vegaSocketUrl + ApiUrl.vegaSuggestionUrl;
  Future<dynamic> getVegaSuggestions(
      {int isRegistered, int isMDO, int isSPV}) async {
    Map data = {"isRegistered": isRegistered, "isMDO": isMDO, "isSPV": isSPV};
    var body = json.encode(data);

    Response res = await post(Uri.parse(suggestionsUrl),
        headers: Helper.registerPostHeaders(), body: body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      List<dynamic> body = contents['payload']['more'];
      List<VegaHelpItem> suggestions = body
          .map(
            (dynamic item) => VegaHelpItem.fromJson(item),
          )
          .toList();
      VEGA_HELP_ITEMS = suggestions;
      VEGA_BOTTOM_SUGGESTIONS = contents['payload']['bottomBar'];
      return suggestions;
    } else {
      throw 'Can\'t get suggestions.';
    }
  }
}
