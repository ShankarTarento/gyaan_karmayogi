import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/models/_models/browse_competency_card_model.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'dart:convert';
import 'dart:async';
import './../../constants/index.dart';
import './../../util/helper.dart';
// import 'dart:developer' as developer;

class CompetencyService {
  final _storage = FlutterSecureStorage();
  List<BrowseCompetencyCardModel> browseCompetencyCardModel = [];
  final ProfileService profileService = ProfileService();

  Future<dynamic> recommendedFromFrac() async {
    String token = await _storage.read(key: Storage.authToken);
    // String wid = await _storage.read(key: 'wid');
    String designation = await _storage.read(key: Storage.designation);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'type': 'COMPETENCY',
      'mappings': [
        {
          'type': 'POSITION',
          'name': '$designation',
          // 'name': 'Director( Admin and GA)',
          'relation': 'parent'
        }
      ]
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.fracBaseUrl + ApiUrl.recommendedFromFrac),
        headers: Helper.knowledgeResourcePostHeaders(token, rootOrgId),
        body: body);
    // print(response.body);
    return response;
  }

  Future<dynamic> getLevelsForCompetency(id, competency) async {
    String token = await _storage.read(key: Storage.authToken);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
      Uri.parse(ApiUrl.fracBaseUrl +
          ApiUrl.getLevelsForCompetency +
          '?id=$id&type=$competency&isDetail=true'),
      headers: Helper.knowledgeResourcePostHeaders(token, rootOrgId),
    );
    // print('Levels: ' + response.body);
    return response;
  }

  Future<dynamic> getCompetencies() async {
    String token = await _storage.read(key: Storage.authToken);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "searches": [
        {"type": "COMPETENCY", "field": "name", "keyword": ""},
        {"type": "COMPETENCY", "field": "status", "keyword": "VERIFIED"}
      ],
      "childNodes": true
    };

    var body = jsonEncode(data);

    Response response = await post(
        Uri.parse(ApiUrl.fracBaseUrl + ApiUrl.getCompetencies),
        headers: Helper.knowledgeResourcePostHeaders(token, rootOrgId),
        body: body);
    // print('Competencies: ' + response.body);
    return response;
  }

  Future<dynamic> recommendedFromWat() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.recommendedFromWat + wid),
      headers: Helper.postHeaders(token, wid, rootOrgId),
    );

    return response;
  }

  Future<dynamic> allCompetencies() async {
    String token = await _storage.read(key: Storage.authToken);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    // String wid = await _storage.read(key: 'wid');

    Map data = {
      'searches': [
        {'type': 'COMPETENCY', 'field': 'name', 'keyword': ''},
        {'type': 'COMPETENCY', 'field': 'status', 'keyword': 'VERIFIED'}
      ]
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.fracBaseUrl + ApiUrl.allCompetencies),
        headers: Helper.knowledgeResourcePostHeaders(token, rootOrgId),
        body: body);
    // print(res.body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t get all competencies.';
    }
  }

  Future<dynamic> selfAttestCompetency(
      Map attestedCompetency, List<Profile> profileDetails,
      {bool isOnlyCBPlevel = false}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    var userTagged = profileDetails[0]
        .competencies
        .where((competency) => competency['id'] == attestedCompetency['id']);

    Map data = {
      "request": {
        "userId": "$wid",
        "profileDetails": {
          "competencies": profileDetails[0].competencies,
        }
      }
    };

    if (userTagged.length == 0) {
      profileDetails[0].competencies.add(attestedCompetency);
      data['request']['profileDetails']['competencies'] =
          profileDetails[0].competencies;

      var body = jsonEncode(data);

      Response res = await post(
          Uri.parse(ApiUrl.baseUrl + ApiUrl.updateProfileDetails),
          headers: Helper.profilePostHeaders(token, wid, rootOrgId),
          body: body);
      return jsonDecode(res.body);
    } else if (userTagged.length == 1 && isOnlyCBPlevel) {
      int index = profileDetails[0]
          .competencies
          .indexWhere((element) => element['id'] == attestedCompetency['id']);

      profileDetails[0].competencies[index] = attestedCompetency;
      data['request']['profileDetails']['competencies'] =
          profileDetails[0].competencies;

      var body = jsonEncode(data);

      Response res = await post(
          Uri.parse(ApiUrl.baseUrl + ApiUrl.updateProfileDetails),
          headers: Helper.profilePostHeaders(token, wid, rootOrgId),
          body: body);
      return jsonDecode(res.body);
    } else {
      throw 'Already exist';
    }
  }

  Future<dynamic> removeFromYourCompetency(
      String id, List<Profile> profileDetails) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    List<dynamic> acquiredCompetencies = profileDetails[0].competencies;

    profileDetails[0].competencies.sublist(0).forEach((element) {
      if (element['id'] == id) {
        int index = profileDetails[0].competencies.sublist(0).indexOf(element);
        if (element['competencyCBPCompletionLevel'] != null) {
          acquiredCompetencies[index].remove('competencySelfAttestedLevel');
          acquiredCompetencies[index].remove('competencySelfAttestedLevelName');
          acquiredCompetencies[index]
              .remove('competencySelfAttestedLevelValue');
        } else {
          acquiredCompetencies.removeAt(index);
        }
      }
    });

    Map data = {
      "request": {
        "userId": "$wid",
        "profileDetails": {"competencies": acquiredCompetencies}
      }
    };

    var body = json.encode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateProfileDetails),
        headers: Helper.profilePostHeaders(token, wid, rootOrgId),
        body: body);

    return jsonDecode(res.body);
  }
}
