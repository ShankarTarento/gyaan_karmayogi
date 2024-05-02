import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/widgets/_rating/in_app_review_on_weekly_clap.dart';

class InAppReviewRespository extends ChangeNotifier {
  final _storage = FlutterSecureStorage();

  // Number of days of duration to appear In app review pop up on Android = 14 days
  static const int androidDaysOfDurationToCallInAppReview = 14;

  // Number of days of duration to appear In app review pop up on iOS = 121 days (3 times in a 365-day duration)
  static const int iOSDaysOfDurationToCallInAppReview = 121;

  DateTime _lastTriggeredTime;

  bool _isAppOpened = false;
  bool get isAppOpened => _isAppOpened;

  bool _isOtherPopupVisible = false;
  bool get isOtherPopupVisible => _isOtherPopupVisible;

  Future<void> setAppOpenedStatus() async {
    await _storage.write(key: Storage.isAppOpened, value: EnglishLang.yes);
    await _storage.write(
        key: Storage.isAppReviewPopupTriggered, value: EnglishLang.no);
    await setLastApiTriggerTime();
  }

  Future<bool> canTriggerInAppReviewPopup() async {
    DateTime currentTime = DateTime.now();
    final lastTriggeredTime = await _storage.read(
      key: Storage.lastTriggeredTime,
    );

    final isAppReviewPopupTriggered =
        await _storage.read(key: Storage.isAppReviewPopupTriggered);

    _lastTriggeredTime = DateTime.parse(lastTriggeredTime);
    int durationInDays = currentTime.difference(_lastTriggeredTime).inDays;

    notifyListeners();
    if (isAppReviewPopupTriggered == EnglishLang.no ||
        (durationInDays >
                (Platform.isAndroid
                    ? androidDaysOfDurationToCallInAppReview
                    : iOSDaysOfDurationToCallInAppReview) &&
            !_isOtherPopupVisible)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> triggerInAppReviewPopup() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await canTriggerInAppReviewPopup()) {
      if (await inAppReview.isAvailable()) {
        try {
          // Triggering In app review popup
          await inAppReview.requestReview();
          // To check In app review popup has already been triggered or not
          await setAppReviewPopupTriggeredStatus();
          // Setting last triggered time
          await setLastApiTriggerTime();
        } catch (e) {}
      }
    }
  }

  Future<void> setLastApiTriggerTime() async {
    await _storage.write(
        key: Storage.lastTriggeredTime, value: DateTime.now().toString());
  }

  Future<void> setAppReviewPopupTriggeredStatus() async {
    final isAppReviewPopupTriggered =
        await _storage.read(key: Storage.isAppReviewPopupTriggered);
    // To check In app review popup has already been triggered or not
    if (isAppReviewPopupTriggered.toString() == EnglishLang.no) {
      await _storage.write(
          key: Storage.isAppReviewPopupTriggered, value: EnglishLang.yes);
    }
  }

  Future<void> setOtherPopupVisibleStatus(bool status) async {
    _isOtherPopupVisible = status;
    notifyListeners();
  }

  rateAppOnWeeklyClap(
      {@required BuildContext context, @required String feedId}) async {
    if (!isOtherPopupVisible) {
      // Triggering popup to rate the app
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => InAppReviewPopupOnWeeklyClap(
          parentContext: context,
          feedId: feedId,
        ),
      );
    }
  }
}
