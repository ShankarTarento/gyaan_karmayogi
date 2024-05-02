import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/assessment_info_model.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart';
import 'package:karmayogi_mobile/models/_models/learn_config_model.dart';
import 'package:karmayogi_mobile/models/_models/course_config_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

import '../../constants/index.dart';
// import 'dart:developer' as developer;

class LearnRepository extends ChangeNotifier {
  final LearnService learnService = LearnService();
  List<BrowseCompetencyCardModel> browseCompetencyCard = [];
  List<ProviderCardModel> providerCardModel = [];
  List<Course> courses = [];
  String _errorMessage = '';
  Response _data;
  AssessmentInfo _assessmentInfo;
  dynamic _trendingProgramList;
  dynamic _trendingCourseList;
  dynamic _shortDurationCourseList;
  dynamic _trendingProgramDeptList;
  dynamic _trendingCourseDeptList;
  dynamic _certificateOfWeekList;
  dynamic _enrolledCourseList;
  dynamic _topProvidersConfig;
  dynamic _cbplanData;
  dynamic _competency;
  dynamic _competencyThemeList;
  dynamic _contentRead;
  dynamic _courseRating;
  dynamic _courseHierarchyInfo;
  dynamic _courseRatingAndReview;

  dynamic get trendingProgramList => _trendingProgramList;
  dynamic get trendingCourseList => _trendingCourseList;
  dynamic get shortDurationCourseList => _shortDurationCourseList;
  dynamic get trendingProgramDeptList => _trendingProgramDeptList;
  dynamic get trendingCourseDeptList => _trendingCourseDeptList;
  dynamic get certificateOfWeekList => _certificateOfWeekList;
  dynamic get enrolledCourseList => _enrolledCourseList;
  dynamic get topProvidersConfig => _topProvidersConfig;
  dynamic get cbplanData => _cbplanData;
  dynamic get competency => _competency;
  dynamic get competencyThemeList => _competencyThemeList;
  dynamic get contentRead => _contentRead;
  dynamic get courseRating => _courseRating;
  dynamic get courseHierarchyInfo => _courseHierarchyInfo;
  dynamic get courseRatingAndReview => _courseRatingAndReview;

  Future<List<BrowseCompetencyCardModel>> getListOfCompetencies(context) async {
    try {
      final response = await learnService.getListOfCompetencies();
      _data = response;
    } catch (_) {
      return _;
    }

    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = contents;
      List<BrowseCompetencyCardModel> browseCompetencyCard = body
          .map(
            (dynamic item) => BrowseCompetencyCardModel.fromJson(item),
          )
          .toList();
      return browseCompetencyCard;
    } else {
      _errorMessage = _data.statusCode.toString();
      // return Helper.showErrorPopup(context, _data.body);
    }
  }

  Future<List<ProviderCardModel>> getListOfProviders() async {
    try {
      final response = await learnService.getListOfProviders();
      _data = response;
    } catch (_) {
      return _;
    }

    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = contents;
      providerCardModel = body
          .map(
            (dynamic item) => ProviderCardModel.fromJson(item),
          )
          .toList();
      return providerCardModel;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCourses(int pageNo, String searchText,
      List primaryCategory, List mimeType, List source,
      {bool isCollection = false,
      bool hasRequestBody = false,
      bool isModerated = false,
      Map requestBody,
      bool checkforCBPEnddate = true}) async {
    try {
      final response = await learnService.getCourses(
          pageNo - 1, searchText, primaryCategory, mimeType, source,
          isCollection: isCollection,
          hasRequestBody: hasRequestBody,
          isModerated: isModerated,
          requestBody: requestBody);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data.bodyBytes));

      List<dynamic> body = contents['result']['content'] != null
          ? contents['result']['content']
          : [];
      if (checkforCBPEnddate) {
        body = await addCBPEnddateToCourse(body);
      }
      courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();

      // Filtering learn under 30 minutes courses (Time is in seconds)
      // if (primaryCategory.isEmpty) {
      //   _shortDurationCourseList = courses
      //       .where((course) =>
      //           (course.duration != null && int.parse(course.duration) < 1800))
      //       .toList();
      //   notifyListeners();
      // }
      return courses;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<dynamic>> addCBPEnddateToCourse(List<dynamic> body) async {
    if (body != null && body.isNotEmpty) {
      if (cbplanData != null) {
        await getCbplan();
      }
      if (cbplanData != null &&
          cbplanData.runtimeType != String &&
          cbplanData.isNotEmpty) {
        body.forEach((course) {
          String courseId;
          if (course['identifier'] != null) {
            courseId = course['identifier'];
          } else if (course['courseId'] != null) {
            courseId = course['courseId'];
          }
          cbplanData['content'].forEach((cbpCourse) {
            cbpCourse['contentList'].forEach((element) {
              if (element['identifier'] == courseId) {
                course['endDate'] = cbpCourse['endDate'];
              }
            });
          });
        });
      }
    }
    return body;
  }

  Future<List<Course>> getInterestedCourses(selectedTopics) async {
    try {
      final response = await learnService.getInterestedCourses(selectedTopics);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);

      List<dynamic> body = contents['result']['content'] != null
          ? contents['result']['content']
          : [];
      courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      return courses;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getRecommendedCourses(competencies) async {
    try {
      final response = await learnService.getRecommendedCourses(competencies);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);

      List<dynamic> body = contents['result']['content'];
      if (contents['result']['content'] != null) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      return courses;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByTopic(String identifier) async {
    try {
      final response = await learnService.getCoursesByTopic(identifier);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body =
          contents['result']['count'] > 0 ? contents['result']['content'] : [];

      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      return courses;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<dynamic> getCourseCollection(String identifier) async {
    try {
      final response = await learnService.getCoursesByCollection(identifier);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      return contents['result']['content'];
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByCollection(String identifier) async {
    try {
      final response = await learnService.getCoursesByCollection(identifier);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = ((contents['result']['content'] != null &&
                  contents['result']['content']['children'] != null) &&
              contents['result']['content']['children'].length > 0)
          ? contents['result']['content']['children']
          : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      return courses;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByCompetencies(
      competencyName, selectedTypes, selectedProviders) async {
    try {
      final response = await learnService.getCoursesByCompetencies(
          competencyName, selectedTypes, selectedProviders);
      _data = response;
    } catch (_) {
      return _;
    }

    if (_data.statusCode == 200) {
      courses = [];
      var contents = jsonDecode(_data.body);
      List<dynamic> body =
          contents['result']['count'] > 0 ? contents['result']['content'] : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      // print('Course test: ' + courses.toString());
      return courses;
    } else {
      // throw 'Can\'t get courses by competencies!';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByProvider(String providerName) async {
    try {
      final response = await learnService.getCoursesByProvider(providerName);
      _data = response;
    } catch (_) {
      return _;
    }

    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body =
          contents['result']['count'] > 0 ? contents['result']['content'] : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      return courses;
    } else {
      // throw 'Can\'t get courses by competencies!';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<Map<dynamic, dynamic>> getEnrollmentList() async {
    try {
      final response = await learnService.getContinueLearningCourses();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = json.decode(utf8.decode(_data.bodyBytes));
      return contents['result'];
    } else {
      _errorMessage = _data.statusCode.toString();
      return {};
    }
  }

  Future<List<Course>> getContinueLearningCourses(
      {bool checkforCBPEnddate = true}) async {
    List<Course> coursesList;
    try {
      final response = await learnService.getContinueLearningCourses();
      _data = response;
    } catch (_) {
      _enrolledCourseList = _;
      notifyListeners();
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = json.decode(utf8.decode(_data.bodyBytes));
      List<dynamic> body = contents['result']['courses'];
      if (checkforCBPEnddate) {
        body = await addCBPEnddateToCourse(body);
      }
      coursesList = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      _enrolledCourseList = coursesList;
      notifyListeners();
      return coursesList;
    } else {
      // throw 'Can\'t get courses.';
      _errorMessage = _data.statusCode.toString();
      _enrolledCourseList = _errorMessage;
      notifyListeners();
      // print('object $_data');
      // throw _errorMessage;
    }
    return coursesList;
  }

  Future<List<CourseLearner>> getCourseLearners(courseId) async {
    try {
      final response = await learnService.getCourseLearners(courseId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      List<dynamic> contents = jsonDecode(_data.body);
      List<CourseLearner> learners = contents
          .map(
            (dynamic item) => CourseLearner.fromJson(item),
          )
          .toList();

      return learners;
    } else {
      // throw 'Can\'t get courses learners.';
      _errorMessage = _data.statusCode.toString();
      // print(_errorMessage);
    }
  }

  Future<List<CourseAuthor>> getCourseAuthors(courseId) async {
    try {
      final response = await learnService.getCourseAuthors(courseId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      List<dynamic> contents = jsonDecode(_data.body);
      List<CourseAuthor> authors = contents
          .map(
            (dynamic item) => CourseAuthor.fromJson(item),
          )
          .toList();
      // print('Authours service ' + contents.toString());
      return authors;
    } else {
      // throw 'Can\'t get courses authors.';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<CourseTopics>> getCourseTopics() async {
    try {
      final response = await learnService.getCourseTopics();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> courseTopic = contents['terms'];
      List<CourseTopics> topics = courseTopic
          .map(
            (dynamic item) => CourseTopics.fromJson(item),
          )
          .toList();
      // print('Learners service ' + learners.toString());

      return topics;
    } else {
      // throw 'Can\'t get courses topics';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<double> getCourseProgress(courseId, batchId) async {
    try {
      final response = await learnService.getCourseProgress(courseId, batchId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      var tempProgress =
          contents['result']['contentList'][0]['completionPercentage'];
      double progress = tempProgress != null ? tempProgress / 100 : 0.0;

      return progress;
    } else {
      // throw 'Can\'t get course progress';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Batch>> getBatchList(courseId) async {
    try {
      final response = await learnService.getBatchList(courseId);

      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);

      List<dynamic> batches = contents['result']['response']['content'];

      List<Batch> courseBatches = batches
          .map(
            (dynamic item) => Batch.fromJson(item),
          )
          .toList();
      return courseBatches;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getMandatoryCourses() async {
    try {
      final response = await learnService.getContinueLearningCourses();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var data = utf8.decode(_data.bodyBytes);
      var contents = jsonDecode(data);
      List<dynamic> body = contents['result']['courses'];
      List<Course> courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      // print(courses.last.raw['content']['primaryCategory'].toString());
      List<Course> mandatoryCourse = courses
          .where(
              (course) => course.contentType == EnglishLang.mandatoryCourseGoal)
          .toList();

      return mandatoryCourse;
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<dynamic> getLearnToolTipInfo() async {
    try {
      final response = await learnService.getLearnHubConfig();
      CourseConfig continueLearningInfo;
      CourseConfig mandatoryCoursesInfo;
      CourseConfig recommendedCoursesInfo;
      CourseConfig newlyAddedCoursesConfig;
      CourseConfig programsConfig;
      CourseConfig basedOnInterestInfo;
      CourseConfig curatedCoursesInfo;
      CourseConfig moderatedCoursesInfo;
      LearnConfig learnToolTipInfo;
      List<dynamic> content = response['pageLayout']['widgetData']['widgets'];
      if (content.length > 0) {
        for (var i = 0; i < content.length; i++) {
          if ((content[i][0]['widget']['widgetData'] != null &&
                  content[i][0]['widget']['widgetData'].runtimeType != List) &&
              content[i][0]['widget']['widgetData']['strips'] != null &&
              (content[i][0]['widget']['widgetData']['strips'][0] != null &&
                  content[i][0]['widget']['widgetData']['strips'][0]['key'] !=
                      null)) {
            switch (content[i][0]['widget']['widgetData']['strips'][0]['key']) {
              case 'continueLearning':
                continueLearningInfo = CourseConfig.fromJson({
                  'title': content[i][0]['widget']['widgetData']['strips'][0]
                      ['title'],
                  'description': content[i][0]['widget']['widgetData']['strips']
                      [0]['titleDescription']
                });
                break;
              case 'mandatoryCourses':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  mandatoryCoursesInfo = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html']
                  });
                }
                break;
              case 'moderatedCourses':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  moderatedCoursesInfo = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html'],
                    'request': content[i][0]['widget']['widgetData']['strips']
                        [0]['request']['moderatedCourses']['queryParams']
                  });
                }
                break;
              case 'recommendedCourses':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  recommendedCoursesInfo = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html']
                  });
                }
                break;
              case 'basedOnInterest':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  basedOnInterestInfo = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html']
                  });
                }
                break;
              case 'latest':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  CourseConfig data = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html'],
                    'request': content[i][0]['widget']['widgetData']['strips']
                        [0]['request']['searchV6']
                  });
                  if (content[i][0]['widget']['widgetData']['strips'][0]
                          ['title'] ==
                      EnglishLang.programs.toString()) {
                    programsConfig = data;
                  } else {
                    newlyAddedCoursesConfig = data;
                  }
                }
                break;

              default:
                break;
            }
          }
        }
        learnToolTipInfo = LearnConfig.fromJson({
          'continueLearning': continueLearningInfo,
          'mandatoryCourse': mandatoryCoursesInfo,
          'recommendedCourse': recommendedCoursesInfo,
          'basedOnInterest': basedOnInterestInfo,
          'latestCourses': newlyAddedCoursesConfig,
          'programs': programsConfig,
          'moderatedCourses': moderatedCoursesInfo
        });
        return learnToolTipInfo;
      }
    } catch (_) {
      return _;
    }
  }

  Future<dynamic> getHomeCoursesConfig() async {
    try {
      final response = await learnService.getHomeConfig();
      dynamic newlyAddedCoursesConfig;
      dynamic curatedCollectionConfig;
      dynamic featuredCoursesConfig;
      LearnConfig learnToolTipInfo;
      _topProvidersConfig = response['clientList'];
      notifyListeners();
      List<dynamic> content = response['pageLayout']['widgetData']['widgets'];
      if (content.length > 0) {
        for (var i = 0; i < content.length; i++) {
          if ((content[i][0]['widget']['widgetData'] != null &&
                  content[i][0]['widget']['widgetData'].runtimeType != List) &&
              content[i][0]['widget']['widgetData']['strips'] != null &&
              (content[i][0]['widget']['widgetData']['strips'][0] != null &&
                  content[i][0]['widget']['widgetData']['strips'][0]['key'] !=
                      null)) {
            switch (content[i][0]['widget']['widgetData']['strips'][0]['key']) {
              case 'latest':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  newlyAddedCoursesConfig = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html'],
                    'request': content[i][0]['widget']['widgetData']['strips']
                        [0]['request']['searchV6']
                  });
                }
                break;

              case 'curatedCollections':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  curatedCollectionConfig = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html'],
                    'request': content[i][0]['widget']['widgetData']['strips']
                        [0]['request']['curatedCollections']
                  });
                }
                break;

              case 'featuredCourses':
                if (content[i][0]['widget']['widgetData']['strips'][0]
                        ['info'] !=
                    null) {
                  featuredCoursesConfig = CourseConfig.fromJson({
                    'title': content[i][0]['widget']['widgetData']['strips'][0]
                        ['title'],
                    'description': content[i][0]['widget']['widgetData']
                        ['strips'][0]['info']['widget']['widgetData']['html'],
                    'request': content[i][0]['widget']['widgetData']['strips']
                        [0]['request']['searchV6']
                  });
                }
                break;

              default:
                break;
            }
          }
        }
        learnToolTipInfo = LearnConfig.fromJson({
          'latestCourses': newlyAddedCoursesConfig,
          'curatedCollections': curatedCollectionConfig,
          'featuredCourses': featuredCoursesConfig
        });
        return learnToolTipInfo;
      }
    } catch (_) {
      return _;
    }
  }

  Future<AssessmentInfo> getAssessmentInfo(String id) async {
    try {
      final info = await learnService.getAssessmentInfo(id);
      _assessmentInfo = AssessmentInfo.fromJson(info);
    } catch (_) {
      return _;
    }
    return _assessmentInfo;
  }

  Future<dynamic> getAssessmentQuestions(
      String id, List<dynamic> questionIds) async {
    try {
      final response =
          await learnService.getAssessmentQuestions(id, questionIds);
      return response;
      // assessmentInfo = AssessmentInfo.fromJson(info);
    } catch (_) {
      return _;
    }

    // return assessmentInfo;
  }

  Future<dynamic> getUpcomingSchedules() async {
    try {
      final response = await learnService.getContinueLearningCourses();
      _data = response;

      if (_data.statusCode == 200) {
        var data = utf8.decode(_data.bodyBytes);
        return jsonDecode(data);
      } else {
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    }
  }

  Future<Map> getSurveyForm(id) async {
    try {
      final response = await learnService.getSurveyForm(id);
      _data = response;

      if (_data.statusCode == 200) {
        var data = jsonDecode(_data.body);
        return data['responseData'];
      } else {
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    }
  }

  Future<void> getTrendingSearch(
      {String category,
      bool enableAcrossDept,
      bool checkforCBPEnddate = true}) async {
    try {
      final response = await learnService.getTrendingSearch(
          category: category, enableAcrossDept: enableAcrossDept);
      _data = response;

      if (_data.statusCode == 200) {
        var data = jsonDecode(_data.body);
        List<dynamic> body = data['response'][category] != null
            ? data['response'][category]
            : [];
        body.removeWhere((element) => element == null);
        if (checkforCBPEnddate) {
          body = await addCBPEnddateToCourse(body);
        }
        List<Course> courseList = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();

        if (category == CourseCategory.programs.name) {
          if (enableAcrossDept) {
            _trendingProgramList = courseList;
          } else {
            _trendingProgramDeptList = courseList;
          }
        } else if (category == CourseCategory.courses.name) {
          if (enableAcrossDept) {
            _trendingCourseList = courseList;
          } else {
            _trendingCourseDeptList = courseList;
          }
        } else if (category == CourseCategory.certifications.name) {
          _certificateOfWeekList = courseList;
        } else if (category == CourseCategory.under_30_mins.name) {
          _shortDurationCourseList = courseList
              .where((course) =>
                  course.contentType.toLowerCase() ==
                  PrimaryCategory.course.toLowerCase())
              .toList();
        } else {
          _errorMessage = _data.statusCode.toString();
          getErrorMessage(category, enableAcrossDept);
        }
      } else {
        getErrorMessage(category, enableAcrossDept);
      }
    } catch (error) {
      print('Error fetching data: $error');
      getErrorMessage(category, enableAcrossDept);
    } finally {
      notifyListeners();
    }
  }

  getErrorMessage(category, isAcross) {
    if (category == CourseCategory.programs.name) {
      if (isAcross) {
        _trendingProgramList = 'error, page not found';
      } else {
        _trendingProgramDeptList = 'error, page not found';
      }
    } else if (category == CourseCategory.courses.name) {
      if (isAcross) {
        _trendingCourseList = 'error, page not found';
      } else {
        _trendingCourseDeptList = 'error, page not found';
      }
    } else if (category == CourseCategory.certifications.name) {
      _certificateOfWeekList = 'error, page not found';
    }
  }

  Future<Map> getCbplan() async {
    try {
      final response = await learnService.getCbplan();
      _data = response;

      if (_data.statusCode == 200) {
        var data = jsonDecode(_data.body);
        Map<dynamic, dynamic> cbpInfo =
            data['result'] != null ? data['result'] : [];
        _cbplanData = cbpInfo;
        return cbpInfo;
      } else {
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    } finally {
      notifyListeners();
    }
  }

  // Competency search
  Future<dynamic> getCompetencySearchInfo() async {
    var response;
    try {
      response = await learnService.getCompetencySearchInfo();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result'];
      } else {
        return response.statusCode.toString();
      }
    } catch (_) {
      return response.statusCode.toString();
    }
  }

  // Competency search
  Future<dynamic> getSearchByProvider() async {
    var response;
    try {
      response = await learnService.getSearchByProvider();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents;
      } else {
        return response.statusCode.toString();
      }
    } catch (_) {
      return response.statusCode.toString();
    }
  }

  // Competency
  Future<void> getCompetency() async {
    try {
      final response = await learnService.getCompetency();
      _data = response;
      if (_data.statusCode == 200) {
        var body = json.decode(utf8.decode(_data.bodyBytes));
        var contents = body['result'];
        var competencyList = [];
        List data = contents['courses'];
        data.forEach((course) {
          var courseId;
          if (course['status'] == 2) {
            final String certificateId = course['issuedCertificates'].length > 0
                ? (course['issuedCertificates'].length > 1
                    ? course['issuedCertificates'].last['identifier']
                    : course['issuedCertificates'].first['identifier'])
                : null;
            if (course['content'] != null &&
                course['content']['competencies_v5'] != null &&
                course['content']['competencies_v5'].isNotEmpty) {
              courseId = course['content']['identifier'];
              course['content']['competencies_v5'].forEach((competency) {
                // Check in list competency area already exist or not
                var isCompetencyAreaExist = competencyList.firstWhere(
                  (element) => (element.competencyArea.id ==
                      competency['competencyAreaId']),
                  orElse: () => -1,
                );
                if (isCompetencyAreaExist == -1) {
                  if (competency['competencyArea'].toString().toLowerCase() !=
                      'behavioral') {
                    competencyList.add(CompetencyDataModel.fromJson({
                      'competencyArea': {
                        'id': competency['competencyAreaId'],
                        'name': competency['competencyArea']
                      },
                      'competencyThemes': [
                        {
                          'competencyArea': {
                            'id': competency['competencyAreaId'],
                            'name': competency['competencyArea']
                          },
                          'theme': {
                            'id': competency['competencyThemeId'],
                            'name': competency['competencyTheme']
                          },
                          'courses': [
                            {
                              'courseId': courseId,
                              'courseName': course['courseName'],
                              'completedOn':
                                  course['issuedCertificates'].isNotEmpty
                                      ? course['issuedCertificates']
                                          .last['lastIssuedOn']
                                      : null,
                              'certificateId': certificateId,
                              'primaryCategory':
                                  course['primaryCategory'] != null
                                      ? course['primaryCategory']
                                      : course['content']['primaryCategory'],
                              'courseSubthemes': [
                                {
                                  'id': competency['competencySubThemeId'],
                                  'name': competency['competencySubTheme']
                                }
                              ]
                            }
                          ],
                          'competencySubthemes': [
                            {
                              'id': competency['competencySubThemeId'],
                              'name': competency['competencySubTheme']
                            }
                          ]
                        }
                      ]
                    }));
                  }
                } else {
                  // Check if competency theme already exist or not
                  for (int index = 0; index < competencyList.length; index++) {
                    if (competencyList[index].competencyArea.id ==
                        competency['competencyAreaId']) {
                      var competencyItem =
                          competencyList[index].competencyThemes;
                      var competencyTheme = competencyItem.firstWhere(
                        (element) => (element.theme.id ==
                            competency['competencyThemeId']),
                        orElse: () => CompetencyTheme(),
                      );
                      if (competencyTheme.theme == null) {
                        competencyItem.add(CompetencyTheme.fromJson({
                          'competencyArea': {
                            'id': competency['competencyAreaId'],
                            'name': competency['competencyArea']
                          },
                          'theme': {
                            'id': competency['competencyThemeId'],
                            'name': competency['competencyTheme']
                          },
                          'courses': [
                            {
                              'courseId': courseId,
                              'courseName': course['courseName'],
                              'completedOn':
                                  course['issuedCertificates'].isNotEmpty
                                      ? course['issuedCertificates']
                                          .last['lastIssuedOn']
                                      : null,
                              'certificateId': certificateId,
                              'primaryCategory':
                                  course['primaryCategory'] != null
                                      ? course['primaryCategory']
                                      : course['content']['primaryCategory'],
                              'courseSubthemes': [
                                {
                                  'id': competency['competencySubThemeId'],
                                  'name': competency['competencySubTheme']
                                }
                              ]
                            }
                          ],
                          'competencySubthemes': [
                            {
                              'id': competency['competencySubThemeId'],
                              'name': competency['competencySubTheme']
                            }
                          ]
                        }));
                      } else {
                        // check competency subtheme already exist
                        var comptencySubTheme =
                            competencyTheme.competencySubthemes.firstWhere(
                                (element) => (element.id ==
                                    competency['competencySubThemeId']),
                                orElse: () => null);
                        if (comptencySubTheme == null) {
                          competencyTheme.competencySubthemes
                              .add(Theme.fromJson({
                            'id': competency['competencySubThemeId'],
                            'name': competency['competencySubTheme']
                          }));
                          var course = competencyTheme.courses.firstWhere(
                              (course) => course.courseId == courseId,
                              orElse: () => null);
                          if (course != null) {
                            course.courseSubthemes.add(Theme.fromJson({
                              'id': competency['competencySubThemeId'],
                              'name': competency['competencySubTheme']
                            }));
                          }
                        }
                        //check course already added
                        var courses = competencyTheme.courses.firstWhere(
                            (element) => (element.courseId == courseId),
                            orElse: () => null);
                        if (courses == null) {
                          competencyTheme.courses.add(CourseData.fromJson({
                            'courseId': courseId,
                            'courseName': course['courseName'],
                            'completedOn':
                                course['issuedCertificates'].isNotEmpty
                                    ? course['issuedCertificates']
                                        .last['lastIssuedOn']
                                    : null,
                            'certificateId': certificateId,
                            'primaryCategory': course['primaryCategory'] != null
                                ? course['primaryCategory']
                                : course['content']['primaryCategory'],
                            'courseSubthemes': [
                              {
                                'id': competency['competencySubThemeId'],
                                'name': competency['competencySubTheme']
                              }
                            ]
                          }));
                        }
                      }
                    }
                  }
                }
              });
            }
          }
        });
        // Sort area wise competency list
        competencyList.sort(((a, b) =>
            (a.competencyArea.name).compareTo(b.competencyArea.name)));
        //Creating theme wise list
        List<dynamic> competencyThemeList = [];
        competencyList.forEach((element) {
          element.competencyThemes.forEach((item) {
            competencyThemeList.add(item);
          });
        });
        //Sort courseList inside competencytheme based on completion date
        competencyThemeList.forEach((element) {
          element.courses.sort((a, b) {
            if (a.completedOn != null && b.completedOn != null) {
              return DateTime.parse(b.completedOn)
                  .compareTo(DateTime.parse(a.completedOn));
            } else {
              return -1;
            }
          });
        });

        // Sort competency theme based on recently associated
        competencyThemeList.sort((a, b) {
          if (b.courses.first.completedOn != null &&
              a.courses.first.completedOn != null) {
            return DateTime.parse(b.courses.first.completedOn)
                .compareTo(DateTime.parse(a.courses.first.completedOn));
          } else {
            return -1;
          }
        });
        _competency = competencyList;
        _competencyThemeList = competencyThemeList;
      } else {
        _competency = _data.statusCode.toString();
        _competencyThemeList = _data.statusCode.toString();
        return {};
      }
    } catch (_) {
      _competency = _;
      _competencyThemeList = _;
    } finally {
      notifyListeners();
    }
  }

  // Content read
  Future<dynamic> getCourseData(id) async {
    var response;
    try {
      response = await learnService.getCourseData(id);
      _contentRead = response;
      return response;
    } catch (e) {
      _contentRead = response;
      return response;
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> getCourseReviewSummery(
      String courseId, String primaryCategory) async {
    _courseRating =
        await learnService.getCourseReviewSummery(courseId, primaryCategory);
    notifyListeners();
  }

  Future<dynamic> getCourseDetails(id, {bool isFeatured = false}) async {
    _courseHierarchyInfo =
        await learnService.getCourseDetails(id, isFeatured: isFeatured);
    notifyListeners();
    return _courseHierarchyInfo;
  }

  Future<dynamic> getYourReview(String id, String primaryCategory) async {
    _courseRatingAndReview =
        await learnService.getYourReview(id, primaryCategory);
    notifyListeners();
    return _courseRatingAndReview;
  }

  void clearReview() {
    _courseRatingAndReview = null;
    _courseRating = null;
    notifyListeners();
  }

  void clearContentRead() {
    _contentRead = null;
    notifyListeners();
  }

  void clearCourseHierarchyInfo() {
    _courseHierarchyInfo = null;
    notifyListeners();
  }
}
