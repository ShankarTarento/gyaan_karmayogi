import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/services/_services/local_notification_service.dart';
import 'firebase_options.dart';
import 'igot_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only call clearSavedSettings() during testing to reset internal values.
  // await Upgrader.clearSavedSettings();
  // REMOVE the above line for release builds

  ///Screen size adaptability
  await ScreenUtil.ensureScreenSize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await initFirebase();
  reportAppLaunch();
  reportAppCrashAnalytics();
  await initFirebaseNotificationService();
  runApp(IGotApp());
}

bool get _modeProdRelease =>
    APP_ENVIRONMENT == Environment.prod && kReleaseMode;

Future<void> initFirebase() async {
  await Firebase.initializeApp(
      name: 'iGotApp', options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initFirebaseNotificationService() async {
  await FirebaseNotificationService().initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseNotificationService.getDeviceTokenToSendNotification();
}

void reportAppCrashAnalytics() {
  //To report only production app crashlytics in firebase
  if (_modeProdRelease) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
}

void reportAppLaunch() {
  //To report only production app analytics in firebase
  if (_modeProdRelease) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver(analytics: analytics);
    analytics.logAppOpen();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseNotificationService().createAndDisplayNotification(message);
  // FirebaseNotificationService().handleMessage();
  // print(message.data.toString());
  // log(message.notification.android.imageUrl.toString());
  // print(message.notification.title);
}
