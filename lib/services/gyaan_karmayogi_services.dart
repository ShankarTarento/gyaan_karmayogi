import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data_models/gyaan_karmayogi_category_model.dart';
import '../data_models/gyaan_karmayogi_resource_details.dart';
import '../data_models/gyaan_karmayogi_resource_model.dart';
import '../utils/helper.dart';

class GyaanKarmayogiServices extends ChangeNotifier {
  List<String> sectorFilters = [];
  List<String> subSectorFilters = [];
  List<FilterModel> resourceCategoryFilters = [];
  List<FilterModel> selectedResourceCategories = [];
  List<FilterModel> sectors = [];
  List<FilterModel> subSectors = [];
  List<FilterModel> resourceCategories = [];
  List<FilterModel> get mySector => sectors;

  Future<List<GyaanKarmayogiResource>> getGyaanKarmaYogiResources(
      {@required String authToken,
      @required String apiUrl,
      @required String wid,
      @required String apiKey,
      @required Map<String, dynamic> requestBody,
      @required String baseUrl,
      @required String deptId}) async {
    List<GyaanKarmayogiResource> gyaanKarmayogiResource = [];

    var body = json.encode(requestBody);
    Response response = await post(Uri.parse(apiUrl),
        headers: Helper.postHeaders(
          apiBaseUrl: baseUrl,
          apiKey: apiKey,
          rootOrgId: deptId,
          token: authToken,
          wid: wid,
        ),
        body: body);

    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      List resources = contents["result"]["content"];

      for (var resource in resources) {
        gyaanKarmayogiResource.add(GyaanKarmayogiResource.fromJson(resource));
      }
    } else {
      print("#######################---error");
    }
    return gyaanKarmayogiResource;
  }

//
//

//
//

//
//

  Future<ResourceDetails> getCourseData(
      {@required String token,
      @required String baseUrl,
      @required String id,
      @required String wid,
      @required String apiKey,
      @required String rootOrgId}) async {
    print(baseUrl);
    ResourceDetails resourceDetails;
    Response res = await get(Uri.parse('${baseUrl}/api/content/v1/read/${id}'),
        headers: Helper.getHeaders(
            token: token, wid: wid, rootOrgId: rootOrgId, apiKey: apiKey));
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);

      resourceDetails =
          ResourceDetails.fromJson(courseDetails['result']['content']);
      return resourceDetails;
    } else {
      return null;
    }
  }

  Future<List<FilterModel>> getAvailableSector(
      {@required String type,
      String sectorName,
      String subSectorName,
      @required String authToken,
      @required String apiUrl,
      @required String wid,
      @required String apiKey,
      @required String baseUrl,
      @required String deptId}) async {
    sectors = [];
    subSectors = [];
    resourceCategories = [];
    Map requestBody = {
      "request": {
        "query": "",
        "filters": {
          "mimeType": [
            "application/pdf",
            "video/mp4",
            'text/x-url',
            'video/x-youtube',
            'audio/mpeg'
          ],
          "status": ["Live"],
          "sectorName": [sectorName],
          "subSectorName": [subSectorName]
          // "resourceCategory": []
        },
        "limit": 0,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["resourceCategory", "sectorName", "subSectorName"]
      }
    };
    var body = jsonEncode(requestBody);
    Response response = await post(Uri.parse(apiUrl),
        headers: Helper.postHeaders(
            apiBaseUrl: baseUrl,
            apiKey: apiKey,
            rootOrgId: deptId,
            token: authToken,
            wid: wid),
        body: body);
    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorName") {
          e["values"].forEach((element) {
            sectors.add(FilterModel(title: element["name"]));
          });
        } else if (e["name"] == "subSectorName") {
          e["values"].forEach((element) {
            subSectors.add(FilterModel(title: element["name"]));
          });
        } else if (e["name"] == "resourceCategory") {
          e["values"].forEach((element) {
            resourceCategories.add(FilterModel(title: element["name"]));
          });
        }
      },
    );

    selectedResourceCategories = resourceCategories;

    notifyListeners();
    if (type == "sector") {
      return sectors;
    } else if (type == "subSector") {
      return subSectors;
    } else {
      return resourceCategories;
    }
  }
}
