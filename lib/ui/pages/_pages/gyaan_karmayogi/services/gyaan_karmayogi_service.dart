import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_sector_model.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../../constants/_constants/storage_constants.dart';

class GyaanKarmayogiServices extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  List<String> sectorFilters = [];
  List<String> subSectorFilters = [];
  List<String> selectedSector = [];
  List<String> availableSectors = [];

  List<String> selectedResourceCategories = [];

  Future<List<String>> getAvailableSector(
      {@required String type,
      List<String> sectorName,
      @required bool showAllSectors,
      String subSectorName,
      String query}) async {
    debugPrint("available sectors===>$availableSectors");
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    List<String> sectors = [];
    List<String> subSectors = [];
    List<String> resourceCategories = [];

    Map requestBody = {
      "request": {
        "query": query,
        "fields": ["sectorName", "subsectorName", "resourceCategory"],
        "filters": {
          "mimeType": [
            "application/pdf",
            "video/mp4",
            'text/x-url',
            'video/x-youtube',
            'audio/mpeg'
          ],
          "status": ["Live"],
          "sectorName": sectorName != null && sectorName.isNotEmpty
              ? sectorName
              : availableSectors,
          "subSectorName": [subSectorName]
        },
        "limit": 0,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["resourceCategory", "sectorName", "subSectorName"]
      }
    };
    var body = jsonEncode(requestBody);
    Response response = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorName") {
          e["values"].forEach((element) {
            sectors.add(element["name"]);
          });
        } else if (e["name"] == "subSectorName") {
          e["values"].forEach((element) {
            subSectors.add(element["name"]);
          });
        } else if (e["name"] == "resourceCategory") {
          e["values"].forEach((element) {
            resourceCategories.add(element["name"]);
          });
        }
      },
    );

    selectedResourceCategories = resourceCategories;
    sectorFilters = sectors;
    subSectorFilters = subSectors;
    selectedSector = sectorName;
    if (showAllSectors) {
      subSectorFilters = [];
      selectedSector = [];
    }
    debugPrint("resource categories-------->>${resourceCategories}");
    debugPrint("sectors =========$sectorFilters");
    debugPrint("subSectors=====$subSectorFilters");
    notifyListeners();
    if (type == "sector") {
      return sectors;
    } else if (type == "subSector") {
      return subSectors;
    } else {
      return resourceCategories;
    }
  }

//
//

  setResourceCategories({String resourceCategory}) {
    selectedResourceCategories = [resourceCategory];
    notifyListeners();
  }
//
//

  Future<List<GyaanKarmayogiSector>> getAllSectors() async {
    List<GyaanKarmayogiSector> gyaanKarmayogiSectors = [];
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response =
        await get(Uri.parse("${ApiUrl.baseUrl}/api/catalog/v1/sector"),
            headers: Helper.getHeaders(
              token,
              wid,
              rootOrgId,
            ));
    var result = jsonDecode(response.body);
    List sector = result["result"]["sectors"];
    sector.forEach(
      (element) {
        gyaanKarmayogiSectors.add(GyaanKarmayogiSector.fromJson(element));
      },
    );

    return gyaanKarmayogiSectors;
  }

  Future<List<GyaanKarmayogiSector>> getAvailableSectorWithIcon() async {
    availableSectors = [];
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    List<GyaanKarmayogiSector> gyaanKarmayogiSectors = await getAllSectors();
    List<GyaanKarmayogiSector> updatedList = [];
    final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;

    Map requestBody = {
      "request": {
        "query": "",
        "filters": {
          "status": ["Live"],
          // "sector": [],
          // "resourceCategory": []
        },
        "limit": 0,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["resourceCategory", "sectorName"]
      }
    };
    var body = jsonEncode(requestBody);
    Response response = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(
          token,
          wid,
          rootOrgId,
        ),
        body: body);
    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorName") {
          e["values"].forEach((element) {
            availableSectors.add(element["name"]);
          });
        }
      },
    );

    gyaanKarmayogiSectors.forEach((sector) {
      if (availableSectors.contains(sector.name.toLowerCase())) {
        // List<SubSector> matchingSubSectors = [];

        // sector.subSectors.forEach((subSector) {
        //   if (subSectors.contains(subSector.identifier)) {
        //     matchingSubSectors.add(subSector);
        //   }
        // });

        updatedList.add(sector);
      }
    });

    return updatedList;
  }
}
