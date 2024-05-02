import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';
import 'package:karmayogi_mobile/models/_models/overlay_theme_model.dart';
import 'package:karmayogi_mobile/models/_models/user_nudge_info_model.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';

class LandingPageRepository extends ChangeNotifier {
  UserNudgeInfo _userNudgeInfo;
  UserNudgeInfo get userNudgeInfo => _userNudgeInfo;
  LandingPageInfo getLandingPageInfoData;

  bool _isProfileCardExpanded = true;
  bool get isProfileCardExpanded => _isProfileCardExpanded;

  bool _displayUserNudge = false;
  bool get displayUserNudge => _displayUserNudge;

  bool _displayOverlayTheme = false;
  bool get displayOverlayTheme => _displayOverlayTheme;

  int _profileDelay = 5;
  int get profileDelay => _profileDelay;

  int _nudgeDelay = 10;
  int get nudgeDelay => _nudgeDelay;

  bool _isConfigAPICalled = false;
  var _configInfoData;
  var _configThemeData;
  OverlayThemeModel _overleyTheme = OverlayThemeModel.defaultData();
  OverlayThemeModel get overleyThemeData => _overleyTheme;

  bool _showGetStarted = false;

  Future<void> getUserNudgeAndThemeInfo() async {
    if (!_isConfigAPICalled) {
      var content = await LandingPageService.getUserNudgeInfo();
      _configInfoData = content;
      var themeContent = await LandingPageService.getOverlayThemeData();
      _configThemeData = themeContent;
      _isConfigAPICalled = true;
    } else {
      _configInfoData = _configInfoData;
    }
    _displayUserNudge = _configInfoData['profileTimelyNudges']['enable'];
    _profileDelay = int.parse(
        _configInfoData['profileTimelyNudges']['profileDelayInSec'].toString());
    _nudgeDelay = int.parse(
        _configInfoData['profileTimelyNudges']['nudgeDelayInSec'].toString());
    List<UserNudgeInfo> data = _configInfoData['profileTimelyNudges']['data']
        .map(
          (dynamic item) => UserNudgeInfo.fromJson(item),
        )
        .toList()
        .cast<UserNudgeInfo>();

    if (_configThemeData != null) {
      if (_configThemeData['overrideThemeChanges'] != null) {
        _displayOverlayTheme =
            _configThemeData['overrideThemeChanges']['isEnabled'] ?? false;
        if (_configThemeData['overrideThemeChanges']['mobile'] != null &&
            _displayOverlayTheme) {
          var overlayThemeModel = OverlayThemeModel.fromJson(
              _configThemeData['overrideThemeChanges']['mobile']);
          _overleyTheme = overlayThemeModel;
        }
      }
    }
    DateTime now = DateTime.now();
    for (var element in data) {
      if (now.hour >= element.startSlot && now.hour < element.endSlot) {
        _userNudgeInfo = element;
        break;
      } else if (element.startSlot > element.endSlot) {
        _userNudgeInfo = element;
        break;
      }
    }

    notifyListeners();
  }

  void changeExpansionProfileCard(bool value) {
    _isProfileCardExpanded = value;
    notifyListeners();
  }

  bool get showGetStarted => _showGetStarted;

  void updateShowGetStarted(bool value) {
    _showGetStarted = value;
    notifyListeners();
  }

}
