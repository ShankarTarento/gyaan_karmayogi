import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/models/_models/language_model.dart';
import 'package:karmayogi_mobile/models/_models/nationality_model.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/models/user/ehrms_details_model.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';

import '../../localization/index.dart';

class ProfileRepository with ChangeNotifier {
  final ProfileService profileService = ProfileService();
  String _errorMessage = '';
  Response _data;
  Profile _profileDetails;
  Profile get profileDetails => _profileDetails;
  List<dynamic> _designationsList = [];
  List<dynamic> get designationsList => _designationsList;
  List<dynamic> _groupList = [];
  List<dynamic> get groupList => _groupList;
  Map _inReview;
  Map get inReview => _inReview;
  EhrmsDetails _ehrmsDetails;
  EhrmsDetails get ehrmsDetails => _ehrmsDetails;
  List<Nationality> _nationalities = [];
  List<Nationality> get nationalities => _nationalities;
  List<Language> _languages = [];
  List<Language> get languages => _languages;
  List<dynamic> _organisations = [];
  List<dynamic> get organisation => _organisations;
  List<dynamic> _industries = [];
  List<dynamic> get industries => _industries;
  List<dynamic> _gradePay = [];
  List<dynamic> get gradePay => _gradePay;
  List<dynamic> _services = [];
  List<dynamic> get services => _services;
  List<dynamic> _cadre = [];
  List<dynamic> get cadre => _cadre;
  List<dynamic> _graduations = [];
  List<dynamic> get graduations => _graduations;
  List<dynamic> _postGraduations = [];
  List<dynamic> get postGraduations => _postGraduations;

  Future<List<Profile>> getProfileDetails() async {
    try {
      final response = await profileService.getProfileDetails();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      List<dynamic> body = contents['result']['UserProfile'];
      List<Profile> profileDetails = body
          .map(
            (dynamic item) => Profile.fromJson(item),
          )
          .toList();
      return profileDetails;
    } else {
      // throw 'Can\'t get profile details.';
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Profile>> getProfileDetailsById(id) async {
    try {
      final response = await profileService.getProfileDetailsById(id);
      _data = response;
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        Map body = contents['result']['response'];
        List<Profile> profileDetailsById = [];
        profileDetailsById.add(Profile.fromJson(body));
        if (id == '') {
          _profileDetails = profileDetailsById.first;
        }
        notifyListeners();
        return profileDetailsById;
      } else {
        // throw 'Can\'t get profile details by ID.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    }
  }

  Future<List<Nationality>> getNationalities() async {
    if (nationalities.isEmpty) {
      try {
        final response = await profileService.getNationalities();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        List<dynamic> body = contents['nationalities'];
        _nationalities = body
            .map(
              (dynamic item) => Nationality.fromJson(item),
            )
            .toList();
        notifyListeners();
      } else {
        // throw 'Can\'t get nationalities.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _nationalities;
  }

  Future<List<Language>> getLanguages() async {
    if (languages.isEmpty) {
      try {
        final response = await profileService.getLanguages();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        List<dynamic> body = contents['languages'];
        _languages = body
            .map(
              (dynamic item) => Language.fromJson(item['name']),
            )
            .toList();
        notifyListeners();
      } else {
        // throw 'Can\'t get languages.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _languages;
  }

  Future<List<dynamic>> getDegrees(type) async {
    if (type == 'graduation' ? graduations.isEmpty : postGraduations.isEmpty) {
      try {
        final response = await profileService.getDegrees(type);
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        if (type == 'graduation') {
          _graduations = contents['graduations'];
        } else {
          _postGraduations = contents['postGraduations'];
        }
        notifyListeners();
        // List<Degree> degrees = body
        //     .map(
        //       (dynamic item) => Degree.fromJson(item),
        //     )
        //     .toList();
      } else {
        // throw 'Can\'t get degrees.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return type == 'graduation' ? _graduations : _postGraduations;
  }

  Future<List<dynamic>> getOrganisations() async {
    if (organisation.isEmpty) {
      try {
        final response = await profileService.getOrganisations();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        _organisations = jsonDecode(_data.body);
        notifyListeners();
      } else {
        // throw 'Can\'t get Organisations.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _organisations;
  }

  Future<List<dynamic>> getIndustries() async {
    if (industries.isEmpty) {
      try {
        final response = await profileService.getIndustries();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        _industries = contents['industries'];
        notifyListeners();
      } else {
        // throw 'Can\'t get Industries.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return industries;
  }

  Future<List<dynamic>> getDesignations() async {
    if (designationsList.isEmpty) {
      try {
        final response = await profileService.getDesignations();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        List<dynamic> body = [];
        for (int index = 0; index < contents['responseData'].length; index++) {
          body.add(contents['responseData'][index]['name']);
        }
        _designationsList = body;
        notifyListeners();
      } else {
        // throw 'Can\'t get Industries.';
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _designationsList;
  }

  Future<EhrmsDetails> getEhrmsDetails() async {
    if (ehrmsDetails == null) {
      try {
        final response = await profileService.getEhrmsDetails();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body)['result']['message'][0];
        _ehrmsDetails = EhrmsDetails.fromJson(contents);
        notifyListeners();
      } else {
        _errorMessage = jsonDecode(_data.body)['params']['errmsg'];
      }
    }
    return _ehrmsDetails;
  }

  Future<List<dynamic>> getGroups() async {
    if (groupList.isEmpty) {
      try {
        final response = await RegistrationService().getGroup();
        _groupList = response;
        notifyListeners();
      } catch (_) {
        return _;
      }
    }
    return _groupList;
  }

  Future<Map> getInReviewFields() async {
    try {
      final response = await ProfileService().getInReviewFields();
      _inReview = response['result']['data'];
      notifyListeners();
    } catch (_) {
      return _;
    }
    return _inReview;
  }

  Future<List<dynamic>> getGradePay() async {
    if (gradePay.isEmpty) {
      try {
        final response = await profileService.getGradePay();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        List<dynamic> body = contents['designations']['gradePay'];

        _gradePay = [];
        for (int index = 0; index < body.length; index++) {
          _gradePay.insert(index, body[index]['name']);
        }
        notifyListeners();
      } else {
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _gradePay;
  }

  Future<List<dynamic>> getServices() async {
    if (services.isEmpty) {
      try {
        final response = await profileService.getServices();
        _data = response;
      } catch (_) {
        return _;
      }
      if (_data.statusCode == 200) {
        var contents = jsonDecode(_data.body);
        _services = contents['services'];
        notifyListeners();
      } else {
        _errorMessage = _data.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _services;
  }

  Future<List<dynamic>> getCadre() async {
    if (cadre.isEmpty) {
      try {
        final response = await profileService.getCadre();

        if (response.statusCode == 200) {
          var contents = jsonDecode(response.body);
          List<dynamic> body = contents['govtOrg']['cadre'];
          _cadre = [];
          for (int index = 0; index < body.length; index++) {
            _cadre.insert(index, body[index]['name']);
          }
          notifyListeners();
        } else {
          _errorMessage = _data.statusCode.toString();
          throw _errorMessage;
        }
      } catch (_) {
        return _;
      }
    }
    return _cadre;
  }

  Future<dynamic> getUserName(wid) async {
    try {
      final response = await profileService.getUserName(wid);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      Map wTokenResponse;
      wTokenResponse = json.decode(_data.body);

      return wTokenResponse['result']['response']['userName'];
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<dynamic> getInsights(BuildContext context) async {
    try {
      final response = await profileService.getUserInsights();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);

      // // To display the popup to rate the app on weekly claps
      // Future.delayed(Duration(seconds: 2), () async {
      //   await Provider.of<InAppReviewRespository>(context, listen: false)
      //       .rateAppOnWeeklyClap(contents['result']['response'],
      //           context: context);
      // });

      return contents['result']['response'];
    } else {
      _errorMessage = _data.statusCode.toString();
      return _errorMessage;
    }
  }

  // Upload profile photo
  Future<dynamic> profilePhotoUpdate(image) async {
    var response;
    try {
      response = await profileService.uploadProfilePhoto(image);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var contents = jsonDecode(responseBody);

      return contents['result']['url'];
    } else {
      _errorMessage = _data.statusCode.toString();
      return response.statusCode;
    }
  }

  // Read karma points(or get history of karma points)
  Future<dynamic> getKarmaPointHistory({limit, offset}) async {
    var response;
    try {
      response = await profileService.getKarmaPointHistory(
          limit: limit, offset: offset);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // Get Total karma point info
  Future<dynamic> getTotalKarmaPoint() async {
    var response;
    try {
      response = await profileService.getTotalKarmaPoint();
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // read karma point for course
  Future<dynamic> getKarmaPointCourseRead(String courseId) async {
    var response;
    try {
      response = await profileService.getKarmaPointCourseRead(courseId);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents['kpList'];
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // Claim karma points
  Future<dynamic> claimKarmaPoints(String courseId) async {
    var response;
    try {
      response = await profileService.claimKarmaPoints(courseId);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      return EnglishLang.success;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  ///Share course
  Future<List> getRecipientList(String query, int limit) async {
    List _usersList;
    try {
      var temp = await profileService.getRecipientList(query, limit);
      _usersList = temp['result']['response']['content'];
    } catch (_) {
      return _;
    }

    return _usersList;
  }

  /// Learner leaderboard
  Future<dynamic> getLeaderboardData() async {
    try {
      final response = await profileService.getLeaderboardData();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data.statusCode == 200) {
      var contents = jsonDecode(_data.body);
      return contents['result']['result'];
    } else {
      _errorMessage = _data.statusCode.toString();
      throw _errorMessage;
    }
  }
}
