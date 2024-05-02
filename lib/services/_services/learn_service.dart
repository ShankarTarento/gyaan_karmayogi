import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
// import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'dart:convert';
import 'dart:async';
import '../../models/_models/blended_program_enroll_response_model.dart';
import '../../models/_models/blended_program_unenroll_response_model.dart';
import './../../constants/index.dart';
import './../../util/helper.dart';
// import 'dart:developer' as developer;

class LearnService {
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  final String coursesUrlV4 = ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4;
  final String continueLearningUrl =
      ApiUrl.baseUrl + ApiUrl.getContinueLearningCourses;
  final String courseDetailsUrl = ApiUrl.baseUrl + ApiUrl.getCourseDetails;
  final String courseDataUrl = ApiUrl.baseUrl + ApiUrl.getCourse;
  final String courseLearnersUrl = ApiUrl.baseUrl + ApiUrl.getCourseLearners;
  final String courseAuthorsUrl = ApiUrl.baseUrl + ApiUrl.getCourseAuthors;
  final String setPdfCookieUrl = ApiUrl.baseUrl + ApiUrl.setPdfCookie;
  final String getAllTopics = ApiUrl.baseUrl + ApiUrl.getAllTopics;
  final String courseProgressUrl = ApiUrl.baseUrl + ApiUrl.getCourseProgress;
  final String updateContentProgressUrl =
      ApiUrl.baseUrl + ApiUrl.updateContentProgress;
  final String readContentProgressUrl =
      ApiUrl.baseUrl + ApiUrl.readContentProgress;
  final String getBatchListUrl = ApiUrl.baseUrl + ApiUrl.getBatchList;
  final String autoEnrollBatchUrl = ApiUrl.baseUrl + ApiUrl.autoEnrollBatch;
  final String enrolProgramBatchUrl =
      ApiUrl.baseUrl + ApiUrl.enrollProgramBatch;
  final String requestBlendedProgramEnrollUrl =
      ApiUrl.baseUrl + ApiUrl.requestBlendedProgramEnrollUrl;
  final String requestBlendedProgramUnenroll =
      ApiUrl.baseUrl + ApiUrl.requestBlendedProgramUnenroll;
  final String getEnrollDetailsUrl = ApiUrl.baseUrl + ApiUrl.getEnrollDetails;
  final String getListOfCompetenciesUrl =
      ApiUrl.fracBaseUrl + ApiUrl.getListOfCompetencies;
  final String getAllCompetenciesUrl =
      ApiUrl.baseUrl + ApiUrl.getAllCompetencies;
  final String getCoursesByCompetenciesURL =
      ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  final String getListOfProvidersUrl =
      ApiUrl.baseUrl + ApiUrl.getListOfProviders;
  final String getAllProvidersUrl = ApiUrl.baseUrl + ApiUrl.getAllProviders;
  final String getAssessmentInfoUrl = ApiUrl.baseUrl + ApiUrl.getAssessmentInfo;
  final String getAssessmentQuestionsUrl =
      ApiUrl.baseUrl + ApiUrl.getAssessmentQuestions;
  final String getRetakeAssessmentUrl =
      ApiUrl.baseUrl + ApiUrl.getRetakeAssessmentInfo;
  final String getTrendingSearchUrl = ApiUrl.baseUrl + ApiUrl.getTrendingSearch;

  final _storage = FlutterSecureStorage();

  Future<dynamic> getListOfCompetencies() async {
    String token = await _storage.read(key: Storage.authToken);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
    };

    Response response =
        await get(Uri.parse(getAllCompetenciesUrl), headers: headers);

    return response;
  }

  Future<dynamic> getListOfProviders() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(getAllProvidersUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId));
    return response;
  }

  Future<dynamic> getCourses(int pageNo, String searchText,
      List primaryCategory, List mimeType, List source,
      {bool isCollection = false,
      bool hasRequestBody = false,
      bool isModerated = false,
      Map requestBody}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String deptId = await _storage.read(key: Storage.deptId);
    String isVerifiedKarmayogi =
        await _storage.read(key: Storage.isVerifiedKarmayogi);

    Map data;
    if (isCollection) {
      final response = await getCuratedHomeConfig();
      data = response['search']['searchReq'];
    } else if (hasRequestBody) {
      data = requestBody;
    } else if (isModerated) {
      data = {
        "request": {
          "query": "",
          "filters": {
            // "primaryCategory": [PrimaryCategory.course],
            "courseCategory": [
              PrimaryCategory.moderatedCourses.toLowerCase(),
              PrimaryCategory.moderatedProgram.toLowerCase(),
              PrimaryCategory.moderatedAssessment.toLowerCase()
            ],
            "contentType": [PrimaryCategory.course],
            "status": ["Live"],
            "secureSettings.isVerifiedKarmayogi":
                jsonDecode(isVerifiedKarmayogi) ? null : 'No',
            "secureSettings.organisation": ["$deptId"]
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": ["mimeType"],
          "limit": 100,
          "offset": 0,
        }
      };
    } else {
      data = {
        "request": {
          "filters": {
            "primaryCategory": primaryCategory,
            "mimeType": [],
            "source": source,
            "mediaType": [],
            "contentType": []
          },
          "status": ["Live"],
          "fields": [],
          "query": searchText,
          "sort_by": {"lastUpdatedOn": "desc"},
          "limit": COURSE_LISTING_PAGE_LIMIT,
          "offset": pageNo,
        }
      };
    }
    var body = json.encode(data);
    Response response = await post(
        Uri.parse(isModerated ? coursesUrlV4 : coursesUrl),
        headers: Helper.postHeaders(token, wid, deptId),
        body: body);

    return response;
  }

  Future<dynamic> getInterestedCourses(selectedTopics) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'request': {
        'filters': {
          'contentType': [],
          'mediaType': [],
          'primaryCategory': ["Course"],
          'mimeType': [],
          'source': [],
          'status': ['Live'],
          'topics': selectedTopics
        },
        'facets': [
          "primaryCategory",
          "mimeType",
          "source",
          "competencies_v3.name",
          "topics"
        ],
        'sort_by': {'lastUpdatedOn': 'desc'},
        'fields': [],
        'limit': 100,
        'offset': 0,
        'query': '',
      },
    };
    var body = json.encode(data);
    Response response = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);

    return response;
  }

  Future<dynamic> getRecommendedCourses(List addedCompetencies) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    List<dynamic> masterCompetencies = await getMasterCompetenciesJson();

    List recommendedCompetencies =
        masterCompetencies.map((e) => e['name']).toList();

    var set1 = Set.from(recommendedCompetencies);
    var set2 = Set.from(addedCompetencies);

    Map data = {
      "request": {
        "filters": {
          "primaryCategory": ["Course"],
          "contentType": ["Course"],
          "competencies_v3.name": List.from(set1.difference(set2))
        },
        "offset": 0,
        "limit": 10,
        "query": "",
        "sort_by": {"lastUpdatedOn": "desc"},
        "fields": [
          "name",
          "appIcon",
          "instructions",
          "description",
          "purpose",
          "mimeType",
          "gradeLevel",
          "identifier",
          "medium",
          "pkgVersion",
          "board",
          "subject",
          "resourceType",
          "primaryCategory",
          "contentType",
          "channel",
          "organisation",
          "trackable",
          "license",
          "posterImage",
          "idealScreenSize",
          "learningMode",
          "creatorLogo",
          "duration",
          "version"
        ]
      },
      "query": ""
    };
    var body = json.encode(data);
    // developer.log(body);
    Response response = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);

    return response;
  }

  Future<dynamic> getCoursesByTopic(String identifier) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "query": "",
        "filters": {
          "status": ["Live"],
          "contentType": ["Collection", "Course", "Learning Path"],
          "topics": identifier
        },
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["primaryCategory", "mimeType"]
      },

      // 'limit': 100
      // 'offset': 0
    };
    var body = json.encode(data);

    Response response = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);

    return response;
  }

  Future<dynamic> getCoursesByCollection(String identifier) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    String coursesByCollectionUrl =
        courseDetailsUrl + identifier + '?mode=minimal';

    Response response = await get(Uri.parse(coursesByCollectionUrl),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    // print(response.body);

    return response;
  }

  Future<dynamic> getCoursesByCompetencies(String competencyName,
      List<String> selectedTypes, List<String> selectedProviders) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "query": "",
        "filters": {
          "primaryCategory": selectedTypes,
          "status": ["Live"],
          "competencies_v3.name": [competencyName],
          "source": selectedProviders,
        },
        "sort_by": {"name": "Asc"},
        // "facets": [],
        // "fields": [
        //   "competencies_v3.name",
        //   "competencies_v3.competencyType",
        //   "taxonomyPaths_v2.name"
        // ]
        "limit": 100,
        // "offset": 0
      }
    };
    var body = json.encode(data);

    Response response = await post(Uri.parse(getCoursesByCompetenciesURL),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // print('Course test in service: ' + response.body.toString());
    // print(getCoursesByCompetenciesURL);
    // print(body);
    return response;
  }

  Future<dynamic> getCoursesByProvider(String providerName) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "filters": {
          "contentType": ["Course"],
          "primaryCategory": [],
          "mimeType": [],
          "source": providerName,
          "mediaType": [],
          "status": ["Live"]
        },
        "query": "",
        "sort_by": {"lastUpdatedOn": ""},
        // "limit": 2,
        "offset": 0,
        "fields": [],
        "facets": ["contentType", "mimeType", "source"]
      }
    };
    var body = json.encode(data);

    Response response = await post(Uri.parse(getCoursesByCompetenciesURL),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // print(res.body);
    return response;
  }

  Future<dynamic> getContinueLearningCourses() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    // Map data = {'pageSize': 12, 'sourceFields': 'creatorLogo'};
    // var body = json.encode(data);

    Response response = await get(
        Uri.parse(continueLearningUrl.replaceAll(':wid', wid)),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    return response;
  }

  Future<int> getTotalCoursePages(List primaryCategory, List source,
      {bool isModerated}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data;

    if (isModerated) {
      data = {
        "request": {
          "secureSettings": true,
          "query": "",
          "filters": {
            "courseCategory": [
              PrimaryCategory.moderatedCourses.toLowerCase(),
              PrimaryCategory.moderatedProgram.toLowerCase(),
              PrimaryCategory.moderatedAssessment.toLowerCase()
            ],
            "contentType": [PrimaryCategory.course],
            "status": ["Live"]
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": ["mimeType"],
        }
      };
    } else {
      data = {
        "request": {
          "filters": {
            "primaryCategory": primaryCategory,
            "mimeType": [],
            "source": source,
            "mediaType": [],
            "contentType": []
          },
          "status": ["Live"],
          "fields": [],
          "query": '',
          "sort_by": {"lastUpdatedOn": "desc"},
        }
      };
    }

    // if (isModerated) {
    //   data = {
    //     'request': {
    //       'filters': {
    //         "courseCategory": [PrimaryCategory.moderatedCourses.toLowerCase(), PrimaryCategory.moderatedProgram.toLowerCase(), PrimaryCategory.moderatedAssessment.toLowerCase()],
    //         "contentType": [PrimaryCategory.course],
    //         "status": ["Live"]
    //       },
    //       'query': '',
    //       'sort_by': {'lastUpdatedOn': 'desc'},
    //       'fields': [
    //         'name',
    //         'appIcon',
    //         'instructions',
    //         'description',
    //         'purpose',
    //         'mimeType',
    //         'gradeLevel',
    //         'identifier',
    //         'medium',
    //         'pkgVersion',
    //         'board',
    //         'subject',
    //         'resourceType',
    //         'primaryCategory',
    //         'contentType',
    //         'channel',
    //         'organisation',
    //         'trackable',
    //         'license',
    //         'posterImage',
    //         'idealScreenSize',
    //         'learningMode',
    //         'creatorLogo',
    //         'duration'
    //       ]
    //     },
    //     'query': ''
    //   };
    // } else {
    //   data = {
    //     'request': {
    //       'filters': {
    //         'primaryCategory': ['Course'],
    //         'contentType': ['Course']
    //       },
    //       'query': '',
    //       'sort_by': {'lastUpdatedOn': 'desc'},
    //       'fields': [
    //         'name',
    //         'appIcon',
    //         'instructions',
    //         'description',
    //         'purpose',
    //         'mimeType',
    //         'gradeLevel',
    //         'identifier',
    //         'medium',
    //         'pkgVersion',
    //         'board',
    //         'subject',
    //         'resourceType',
    //         'primaryCategory',
    //         'contentType',
    //         'channel',
    //         'organisation',
    //         'trackable',
    //         'license',
    //         'posterImage',
    //         'idealScreenSize',
    //         'learningMode',
    //         'creatorLogo',
    //         'duration'
    //       ]
    //     },
    //     'query': ''
    //   };
    // }
    var body = json.encode(data);

    Response res = await post(Uri.parse(coursesUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      int count =
          (contents['result']['count'] / COURSE_LISTING_PAGE_LIMIT).ceil();
      return count;
    } else {
      throw 'Can\'t get courses.';
    }
  }

  Future<dynamic> getCourseDetails(id, {bool isFeatured = false}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = isFeatured
        ? await get(
            Uri.parse(courseDetailsUrl + id + '?hierarchyType=detail'),
          )
        : await get(Uri.parse(courseDetailsUrl + id + '?hierarchyType=detail'),
            headers: Helper.getHeaders(token, wid, rootOrgId));
    // print('URL: ' + courseDetailsUrl + id + '?hierarchyType=detail');
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      // print('Response: ' + courseDetails['result']['content'].toString());
      return courseDetails['result']['content'];
    } else {
      return res.reasonPhrase;
    }
  }

  Future<dynamic> getCourseData(id) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    Response res = await get(Uri.parse(courseDataUrl + id),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      return courseDetails['result']['content'];
    } else {
      return res.reasonPhrase;
    }
  }

  Future<dynamic> getCourseLearners(courseId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(courseLearnersUrl),
        headers: Helper.getCourseHeaders(token, wid, courseId, rootOrgId));
    // developer.log(courseLearnersUrl + ": " + res.body);
    // developer.log(Helper.getCourseHeaders(token, wid, courseId).toString());
    return response;
  }

  Future<dynamic> getCourseAuthors(courseId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(courseAuthorsUrl),
        headers: Helper.getCourseHeaders(token, wid, courseId, rootOrgId));
    // developer.log(courseAuthorsUrl + ": " + res.body);
    // developer.log(Helper.getCourseHeaders(token, wid, courseId).toString());
    return response;
  }

  Future<dynamic> setPdfCookie(identifer) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {'contentId': identifer};
    var body = json.encode(data);
    // print('setPdfCookie: $identifer');
    Response res = await post(Uri.parse(setPdfCookieUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // print(res.body);
    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);
      return response;
    } else {
      throw 'Can\'t set cookie.';
    }
  }

  Future<dynamic> getCourseTopics() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(getAllTopics),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getCourseProgress(courseId, batchId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'request': {
        'batchId': batchId,
        'userId': wid,
        'courseId': courseId,
        'contentIds': [],
        'fields': ['progressdetails']
      }
    };
    var body = json.encode(data);
    Response response = await post(Uri.parse(courseProgressUrl + courseId),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  Future<Map> updateContentProgress(
      String courseId,
      String batchId,
      String contentId,
      int status,
      String contentType,
      List current,
      var maxSize,
      double completionPercentage,
      {bool isAssessment = false}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    List dateTime = DateTime.now().toUtc().toString().split('.');

    Map data;

    if (isAssessment) {
      data = {
        "request": {
          "userId": wid,
          "contents": [
            {
              "contentId": contentId,
              "batchId": batchId,
              "status": status,
              "courseId": courseId,
              "lastAccessTime": '${dateTime[0]}:00+0000',
              // "lastCompletedTime": '${dateTime[0]}:00+0000',
            }
          ]
        }
      };
    } else {
      data = {
        "request": {
          "userId": wid,
          "contents": [
            {
              "contentId": contentId,
              "batchId": batchId,
              "status": status,
              "courseId": courseId,
              "lastAccessTime": '${dateTime[0]}:00+0000',
              // "lastCompletedTime": '${dateTime[0]}:00+0000',
              "progressdetails": {
                "max_size": maxSize,
                "current": current,
                "mimeType": contentType
              },
              "completionPercentage": completionPercentage
            }
          ]
        }
      };
    }

    var body = json.encode(data);
    // log(body.toString());
    Response res = await patch(Uri.parse(updateContentProgressUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // print(res.body);
    if (res.statusCode == 200) {
      // var contents = jsonDecode(res.body);
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t update content progress';
    }
  }

  Future<Map> readContentProgress(
    String courseId,
    String batchId,
  ) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "batchId": batchId,
        "userId": wid,
        "courseId": courseId,
        "contentIds": [],
        "fields": ["progressdetails"]
      }
    };
    var body = jsonEncode(data);
    // print(data.toString());
    Response res = await post(Uri.parse(readContentProgressUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // developer.log('readContentProgress:' + res.body.toString());
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Unable to fetch content progress';
    }
  }

  Future<Map> markAttendance(String courseId, String batchId, String contentId,
      int status, double completionPercentage) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    List dateTime = DateTime.now().toUtc().toString().split('.');

    Map data;

    data = {
      "request": {
        "userId": wid,
        "contents": [
          {
            "batchId": batchId,
            "completionPercentage": completionPercentage,
            "contentId": contentId,
            "courseId": courseId,
            "status": status,
            "lastAccessTime": '${dateTime[0]}:00+0000',
            "progressdetails": {
              "spentTime": 0,
            },
          }
        ]
      }
    };

    var body = json.encode(data);
    // log(body.toString());
    Response res = await patch(Uri.parse(updateContentProgressUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    // print(res.body);
    if (res.statusCode == 200) {
      // var contents = jsonDecode(res.body);
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t update content progress';
    }
  }

  Future<dynamic> getBatchList(
    String courseId,
  ) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'request': {
        'filters': {
          'courseId': courseId,
          "status": ['0', '1', '2']
        },
        'sort_by': {'createdDate': 'desc'}
      }
    };
    var body = jsonEncode(data);
    Response response = await post(Uri.parse(getBatchListUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  Future<dynamic> autoEnrollBatch(
    String courseId,
  ) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(Uri.parse(autoEnrollBatchUrl),
        headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['response']['content'][0];
    } else {
      return 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> enrollProgram({
    @required String courseId,
    @required String programId,
    @required String batchId,
  }) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "userId": "$wid",
        "programId": "$programId",
        "batchId": "$batchId"
      }
    };

    Response res = await post(Uri.parse(enrolProgramBatchUrl),
        headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
        body: jsonEncode(data));
    return res;
  }

  Future<dynamic> enrollToCuratedProgram(
      String courseId, String batchId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "request": {"userId": wid, "programId": courseId, "batchId": batchId}
    };
    var body = jsonEncode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.enrollToCuratedProgram),
        headers: Helper.curatedProgramPostHeaders(token, wid, rootOrgId),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['response'];
    } else {
      return 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> requestToEnroll(
      {String batchId, String courseId, String state, String action}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String deptName = await _storage.read(key: Storage.deptName);
    String firstName = await _storage.read(key: Storage.firstName);

    Map data = {
      "rootOrgId": rootOrgId,
      "userId": wid,
      "state": state,
      "action": action,
      "actorUserId": wid,
      "applicationId": batchId,
      "serviceName": "blendedprogram",
      "courseId": courseId,
      "deptName": deptName,
      "updateFieldValues": [
        {
          "toValue": {"name": firstName}
        }
      ]
    };

    try {
      Response res = await post(Uri.parse(requestBlendedProgramEnrollUrl),
          headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
          body: json.encode(data));
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        BlendedProgramEnrollResponseModel enrolList;
        enrolList =
            BlendedProgramEnrollResponseModel.fromJson(contents['result']);
        return enrolList;
      } else {
        return jsonDecode(res.body)['result']['errmsg'];
      }
    } catch (err) {
      throw 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> requestUnenroll(
      {String batchId,
      String courseId,
      String state,
      String action,
      String wfId}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String deptName = await _storage.read(key: Storage.deptName);
    String firstName = await _storage.read(key: Storage.firstName);

    Map data = {
      "rootOrgId": rootOrgId,
      "userId": wid,
      "state": state,
      "action": action,
      "actorUserId": wid,
      "applicationId": batchId,
      "serviceName": "blendedprogram",
      "courseId": courseId,
      "deptName": deptName,
      "wfId": wfId,
      "updateFieldValues": [
        {
          "toValue": {"name": firstName}
        }
      ]
    };

    try {
      Response res = await post(Uri.parse(requestBlendedProgramUnenroll),
          headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
          body: json.encode(data));
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        BlendedProgramUnenrollResponseModel enrolList;
        enrolList =
            BlendedProgramUnenrollResponseModel.fromJson(contents['result']);
        return enrolList;
      } else {
        throw 'Unable to unenroll batch';
      }
    } catch (err) {
      throw 'Unable to unenroll batch';
    }
  }

  Future<dynamic> userSearch(courseId, batchId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "applicationIds": batchId,
      "serviceName": "blendedprogram",
      "limit": 100,
      "offset": 0
    };

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.workflowBlendedProgramSearch),
        headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['data'];
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> submitSurveyForm(formId, dataObject, courseId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "formId": formId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "version": 1,
      "dataObject": dataObject
    };

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.submitBlendedProgramSurvey),
        headers: Helper.postCourseHeaders(token, wid, courseId, rootOrgId),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['statusInfo']['statusMessage'];
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  // Assessment functions

  Future<dynamic> getAssessmentData(
    String fileUrl,
  ) async {
    Response res =
        await get(Uri.parse(Helper.convertToPortalUrl(fileUrl)), headers: {});
    if (res.statusCode == 200) {
      var data = utf8.decode(res.bodyBytes);
      var contents = jsonDecode(data);
      return contents;
    } else {
      throw 'Unable to assessment data.';
    }
  }

  Future<dynamic> getAssessmentInfo(
    String id,
  ) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(Uri.parse(getAssessmentInfoUrl + id),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      // log(jsonEncode(contents['result']['questionSet']));
      return contents['result']['questionSet'];
    } else {
      throw 'Unable to get assessment info.';
    }
  }

  Future<dynamic> getAssessmentQuestions(
    String assessmentId,
    List<dynamic> questionIds,
  ) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    // print('Ids: ' + questionIds.toString());
    Map data = {
      "assessmentId": "$assessmentId",
      "request": {
        "search": {"identifier": questionIds}
      }
    };

    // print('object: ' + data.toString());

    var body = json.encode(data);

    Response res = await post(Uri.parse(getAssessmentQuestionsUrl),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['questions'];
    } else {
      throw 'Unable to get assessment questions.';
    }
  }

  Future<dynamic> getRetakeAssessmentInfo(String assessmentId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(Uri.parse(getRetakeAssessmentUrl + assessmentId),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result'];
    } else {
      throw 'Unable to get assessment retake info.';
    }
  }

  Future<dynamic> submitAssessment(Map data) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.saveAssessment),
        headers: Helper.postHeaders(token, wid, rootOrgId), body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t submit survey data';
    }
  }

  Future<dynamic> submitAssessmentNew(Map data) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.saveAssessmentNew),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);
    return res;
  }

  Future<dynamic> getAssessmentCompletionStatus(Map data) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAssessmentCompletionStatus),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);
    // print('getAssessmentCompletionStatus -> ' + res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      var contents = jsonDecode(res.body);
      return contents['result'];
    } else {
      return jsonDecode(res.body)['params']['errmsg'];
    }
  }

  Future<dynamic> getCompletionCertificateId(String batchId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "batchList": [
          {
            "batchId": "$batchId",
            "userList": ["$wid"]
          }
        ]
      }
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserProgress),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result'][0]['issuedCertificates'].length > 0
          ? (contents['result'][0]['issuedCertificates'].length > 1
              ? contents['result'][0]['issuedCertificates'][1]['identifier']
              : contents['result'][0]['issuedCertificates'][0]['identifier'])
          : null;
    } else {
      throw 'Can\'t get the issued certificate';
    }
  }

  Future<dynamic> getCourseCompletionCertificate(String id) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCourseCompletionCertificate + id),
        headers: Helper.discussionGetHeaders(token, wid));

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['printUri'];
    } else {
      throw 'Can\'t get certificates';
    }
  }

  Future<dynamic> downloadCompletionCertificate(String printUri,
      {String outputType}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map data = {
      "printUri": printUri,
      "inputFormat": "svg",
      "outputFormat": outputType != null ? outputType : CertificateType.pdf
    };

    var body = json.encode(data);
    Response certRes = await post(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getCourseCompletionCertificateForMobile),
        headers: headers,
        body: body);

    if (certRes.statusCode == 200) {
      final certificateData = certRes.bodyBytes;
      return certificateData;
    }
    throw 'Can\'t get certificates';
  }

  Future<dynamic> getYourReview(String id, String primaryCategory) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "activityId": "$id",
        "activityType": "$primaryCategory",
        "userId": [wid],
      }
    };

    var body = json.encode(data);
    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.getYourRating),
        body: body, headers: Helper.getHeaders(token, wid, rootOrgId));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['content'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> getBlendedProgramBatchCount(String batchId) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "serviceName": "blendedprogram",
      "applicationStatus": "",
      "applicationIds": ["$batchId"],
      "limit": 100,
      "offset": 0
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.requestBlendedProgramBatchCountUrl),
        body: body,
        headers: Helper.getHeaders(token, wid, rootOrgId));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['data'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> postCourseReview(String courseId, String primaryCategory,
      double rating, String comment) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data;
    if (comment.trim().length > 0) {
      data = {
        "activityId": "$courseId",
        "userId": "$wid",
        "activityType": "$primaryCategory",
        "rating": rating.toInt(),
        "review": "$comment"
      };
    } else {
      data = {
        "activityId": "$courseId",
        "userId": "$wid",
        "activityType": "$primaryCategory",
        "rating": rating.toInt(),
      };
    }

    var body = json.encode(data);
    // print(body);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.postReview),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);
    return response;
  }

  Future<dynamic> getCourseReviewSummery(
      String id, String primaryCategory) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.getCourseReviewSummery +
            '$id/$primaryCategory'),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    // developer.log(res.body);
    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['response'];
    } else {
      print(contents['params']['errmsg']);
      return null;
    }
  }

  Future<dynamic> getCourseReview(
      String courseId, String primaryCategory, int limit) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "activityId": "$courseId",
      "activityType": "$primaryCategory",
      "limit": limit,
      "updateOn": ""
    };

    var body = json.encode(data);
    // print(body);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCourseReview),
        headers: Helper.postHeaders(token, wid, rootOrgId),
        body: body);
    // developer.log(res.body);
    var contents = jsonDecode(res.body);
    // developer.log(contents.toString());
    if (res.statusCode == 200) {
      return contents['result']['response'];
    } else {
      return null;
    }
  }

  Future<dynamic> getCourseReviewReply(
      String id, String primaryCategory, List userIds) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "activityId": "$id",
        "activityType": "$primaryCategory",
        "userId": userIds,
      }
    };

    var body = json.encode(data);

    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.getYourRating),
        body: body, headers: Helper.getHeaders(token, wid, rootOrgId));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['content'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> getCuratedHomeConfig() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCuratedHomeConfig),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return jsonDecode(response.body);
  }

  Future<dynamic> getLearnHubConfig() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLearnHubConfig),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return jsonDecode(response.body);
  }

  Future<dynamic> getHomeConfig() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getHomeConfig),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return jsonDecode(response.body);
  }

  Future<dynamic> getMasterCompetenciesJson() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMasterCompetencies),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return jsonDecode(response.body);
  }

  Future<dynamic> getSurveyForm(id) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getSurveyForm + id.toString()),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  Future<dynamic> getTrendingSearch(
      {String category, bool enableAcrossDept}) async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String designation = await _storage.read(key: Storage.designation);
    if (enableAcrossDept == null) {
      enableAcrossDept = false;
    }
    Map data = {
      "request": {
        "filters": {
          "contextType": [category],
          "designation": designation,
          "organisation": enableAcrossDept ? "across" : rootOrgId
        },
        "limit": 50
      }
    };
    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingSearch),
        headers: Helper.getHeaders(token, wid, rootOrgId),
        body: body);

    return response;
  }

  Future<dynamic> getCbplan() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getCbplan),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  // Competency search
  Future<dynamic> getCompetencySearchInfo() async {
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);
    String token = await _storage.read(key: Storage.authToken);
    var body = json.encode({
      "search": {"type": "Competency Area"},
      "filter": {"isDetail": true}
    });
    String url = ApiUrl.baseUrl + ApiUrl.competencySearch;
    final response = await post(Uri.parse(url),
        headers: Helper.getHeaders(token, wid, rootOrgId), body: body);
    return response;
  }

  //Search by provider
  Future<dynamic> getSearchByProvider() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.searchByProvider),
        headers: Helper.getHeaders(token, wid, rootOrgId));

    return response;
  }

  // Competency
  Future<dynamic> getCompetency() async {
    String token = await _storage.read(key: Storage.authToken);
    String wid = await _storage.read(key: Storage.wid);
    String rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(
            (ApiUrl.baseUrl + ApiUrl.getCompetency).replaceAll(':wid', wid)),
        headers: Helper.getHeaders(token, wid, rootOrgId));
    return response;
  }
}
