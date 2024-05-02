import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:notification_permissions/notification_permissions.dart';

class FirebaseNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _firebaseMessaging = FirebaseMessaging.instance;
  bool get _modeProdRelease =>
      APP_ENVIRONMENT == Environment.prod && kReleaseMode;

  Future<void> initialize() async {
    print('Firebase initializing...');
    // Requesting for permission
    try {
      await requestNotificationPermission();
    } catch (e) {
      log('Permission error: $e');
    }
  }

  Future<List<String>> getTopics() async {
    final storage = FlutterSecureStorage();
    String mdoId = await storage.read(
      key: Storage.deptId,
    );
    String topicAllUsers = 'ALL_USERS';
    String topicMDO = 'MDO_ID_$mdoId';
    String topicEnv = APP_ENVIRONMENT.split('.').last.toUpperCase();
    String topicOS = Platform.isIOS ? DeviceOS.iOS : DeviceOS.android;

    List<String> topics = [topicAllUsers];

    List<String> devTopics = [
      topicAllUsers,
      topicEnv,
      topicOS,
      Helper.getFormattedTopic([topicAllUsers, topicEnv]),
      Helper.getFormattedTopic([topicAllUsers, topicOS]),
      Helper.getFormattedTopic([topicAllUsers, topicOS, topicEnv])
    ];

    if (mdoId != null) {
      topics.add(topicMDO);
      devTopics.add(topicMDO);
    }

    log('topics: ' + (_modeProdRelease ? topics : devTopics).toString());

    return _modeProdRelease ? topics : devTopics;
  }

  // Requesting for notification permisssion
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        carPlay: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // print('User granted provisional permission');
      await _firebaseMessaging.requestPermission(
        provisional: true,
      );
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(
              sound: true, badge: true, alert: true));
    }
  }

  Future<void> foregroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> handleMessage() async {
    FirebaseMessaging.onMessage.listen((message) {
      log('Title: ${message.notification.title}, Body: ${message.notification.body}');
      // RemoteNotification notification = message.notification;
      // AndroidNotification android = message.notification.android;
      // log('Title: ${notification.title}, body: ${notification.body}, data: ${message.notification.android.imageUrl}');

      if (Platform.isIOS) {
        try {
          foregroundMessage();
        } catch (e) {
          log('foregroundMessage: $e');
        }
      }
      if (Platform.isAndroid) {
        initLocalNotifications(message);
        createAndDisplayNotification(message);
      }
    });
  }

  void initLocalNotifications(RemoteMessage message) async {
    // initializationSettings  for Android & iOS
    var androidInitSettings = AndroidInitializationSettings(
        Platform.isIOS ? "@mipmap/ic_launcher" : "@drawable/ic_launcher");
    var iOSInitSettings = IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitSettings, iOS: iOSInitSettings);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String id) async {
        print("onSelectNotification $id");
        if (id.isNotEmpty) {
          // print("Router Value1234 $id");
        }
      },
    );
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // when the app is terminated
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage();
    }

    // When the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage();
    });
  }

  Future<void> createAndDisplayNotification(RemoteMessage message) async {
    log(message.notification.android.channelId.toString());
    //  log(message.notification.android);
    try {
      BigPictureStyleInformation bigPictureStyleInformation;
      if (message.notification.android.imageUrl != null) {
        final String base64Image = await Helper.networkImageToBase64(
            message.notification.android.imageUrl);
        bigPictureStyleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(base64Image),
          largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Image),
        );
      }

      AndroidNotificationChannel androidNotificationChannel =
          AndroidNotificationChannel(
              message.notification.android.channelId.toString(),
              message.notification.android.channelId.toString(),
              importance: Importance.max,
              showBadge: true,
              playSound: true);
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              androidNotificationChannel.id.toString(),
              androidNotificationChannel.name.toString(),
              channelDescription: 'Notification',
              styleInformation: bigPictureStyleInformation,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              ticker: 'ticker',
              sound: androidNotificationChannel.sound),
          iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // attachments: [
            //   IOSNotificationAttachment(message.notification.apple != null
            //       ? message.notification.apple.imageUrl
            //       : ''
            //       )
            // ]
          ));

      Future.delayed(Duration.zero, () async {
        await _localNotificationsPlugin.show(
          id,
          message.notification.title,
          message.notification.body,
          notificationDetails,
          payload: jsonEncode(message.data),
        );
      });
    } on Exception catch (e) {
      print('createAndDisplayNotification: $e');
      throw e;
    }
  }

  void showNotification(BuildContext context, RemoteMessage message) {
    // print('In show notification function');
    if (message.data['type'] == 'text') {
      // redirect to new screen or take different action based on payload thaqt receive
    }
  }

  static getDeviceTokenToSendNotification() async {
    String deviceTokenToSendPushNotification = '';
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = '\n FCM Token:\n' + await _fcm.getToken();
    _fcm.setAutoInitEnabled(true);
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value ${await _fcm.getAPNSToken()}");
    print("Token Value ${await _fcm.getToken()}");
    final storage = FlutterSecureStorage();
    storage.write(
        key: Storage.fcmToken, value: deviceTokenToSendPushNotification);
    return deviceTokenToSendPushNotification;
  }

  subscribeToTopic() async {
    List<String> topics = await getTopics();

    try {
      topics.forEach((topic) {
        FirebaseMessaging.instance.subscribeToTopic(topic);
      });
    } catch (e) {
      print(e);
    }
  }

  unsubscribeFromTopic() async {
    List<String> topics = await getTopics();

    try {
      topics.forEach((topic) {
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      });
    } catch (e) {
      print(e);
    }
  }
}
