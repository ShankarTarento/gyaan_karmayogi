import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import '../constants/_constants/telemetry_constants.dart';
import './../constants/index.dart';
// import 'dart:developer' as developer;

class Telemetry {
  static generateUserSessionId({bool isAppStarted = false}) async {
    final _storage = FlutterSecureStorage();
    String sessionId = await _storage.read(key: Storage.sessionId);
    if (sessionId == null || isAppStarted) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String hash = md5.convert(utf8.encode(timestamp)).toString();
      _storage.write(key: Storage.sessionId, value: hash);
      return hash;
    } else {
      return sessionId;
    }
  }

  static getUserId({bool isPublic = false}) async {
    final _storage = FlutterSecureStorage();
    String userId = !isPublic ? await _storage.read(key: Storage.wid) : null;
    // print('deptId: $deptId');
    return userId;
  }

  static getUserNodeBbUid() async {
    final _storage = FlutterSecureStorage();
    String nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    return nodebbUserId;
  }

  static getUserSessionId() async {
    final _storage = FlutterSecureStorage();
    String sessionId = await _storage.read(key: Storage.sessionId);
    // print('sessionId: $sessionId');
    return sessionId;
  }

  static getUserDeptId({bool isPublic = false}) async {
    final _storage = FlutterSecureStorage();
    String deptId = !isPublic ? await _storage.read(key: Storage.deptId) : null;
    // print('deptId: $deptId');
    return deptId;
  }

  static getDeviceIdentifier() async {
    final _storage = FlutterSecureStorage();
    String deviceIdentifier =
        await _storage.read(key: Storage.deviceIdentifier);
    return deviceIdentifier;
  }

  static generateMessageId() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String hash = md5.convert(utf8.encode(timestamp)).toString();
    return hash;
  }

  static getStartTelemetryEvent(
      String deviceIdentifier,
      String userId,
      String departmentId,
      String pageIdentifier,
      String userSessionId,
      String messageIdentifier,
      String telemetryType,
      String pageUri,
      {String objectId,
      String objectType,
      String env,
      bool isPublic = false,
      String l1}) {
    // String objectId, objectType;
    // if (telemetryType == TelemetryType.player) {
    //   List identifier = pageIdentifier.split('/');
    //   objectId = identifier.last;
    //   objectType = identifier[1] == EDisplayContentTypes.pdf.toLowerCase()
    //       ? EMimeTypes.pdf
    //       : identifier[1] == EDisplayContentTypes.html.toLowerCase()
    //           ? EMimeTypes.html
    //           : identifier[1] == EDisplayContentTypes.video.toLowerCase()
    //               ? EMimeTypes.mp4
    //               : identifier[1] == EDisplayContentTypes.audio.toLowerCase()
    //                   ? EMimeTypes.mp3
    //                   : identifier[1] == EDisplayContentTypes.quiz.toLowerCase()
    //                       ? EMimeTypes.assessment
    //                       : 'Content';
    // } else {
    //   objectId = pageIdentifier;
    //   objectType = 'Content';
    // }

    Map eventData = {
      'eid': TelemetryEvent.start,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.start}:$messageIdentifier',
      'actor': {'id': userId, 'type': isPublic ? 'AnonymousUser' : 'User'},
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
        'cdata': []
      },
      'object': {
        'id': objectId,
        'type': objectType,
        'rollup': l1 != null ? {'l1': l1} : {}
      },
      // 'object': {},
      'tags': [],
      'edata': {
        'type': telemetryType,
        'mode': telemetryType == TelemetryType.player
            ? TelemetryMode.play
            : TelemetryMode.view,
        'pageid': pageIdentifier,
        // 'uri': pageUri,
        // 'duration': ''
      }
    };
    // print('eventData: $eventData');
    return eventData;
  }

  static getEndTelemetryEvent(
      String deviceIdentifier,
      String userId,
      String departmentId,
      String pageIdentifier,
      String userSessionId,
      String messageIdentifier,
      int duration,
      String telemetryType,
      String pageUri,
      Map rollup,
      {String objectId,
      String objectType,
      String env,
      bool isPublic = false,
      String l1}) {
    // String objectId, objectType;
    // if (telemetryType == TelemetryType.player) {
    //   List identifier = pageIdentifier.split('/');
    //   objectId = identifier.last;
    //   objectType = identifier[1] == EDisplayContentTypes.pdf.toLowerCase()
    //       ? EMimeTypes.pdf
    //       : identifier[1] == EDisplayContentTypes.html.toLowerCase()
    //           ? EMimeTypes.html
    //           : identifier[1] == EDisplayContentTypes.video.toLowerCase()
    //               ? EMimeTypes.mp4
    //               : identifier[1] == EDisplayContentTypes.audio.toLowerCase()
    //                   ? EMimeTypes.mp3
    //                   : identifier[1] == EDisplayContentTypes.quiz.toLowerCase()
    //                       ? EMimeTypes.assessment
    //                       : 'Content';
    // } else {
    //   objectId = pageIdentifier;
    //   objectType = 'Content';
    // }

    Map eventData = {
      'eid': TelemetryEvent.end,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.end}:$messageIdentifier',
      'actor': {'id': userId, 'type': isPublic ? 'AnonymousUser' : 'User'},
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
        'cdata': [],
      },
      'object': {
        'id': objectId,
        'type': objectType,
        'rollup': l1 != null ? {'l1': l1} : {}
      },
      // 'object': {},
      'tags': [],
      'edata': {
        'type': telemetryType,
        'mode': telemetryType == TelemetryType.player
            ? TelemetryMode.play
            : TelemetryMode.view,
        'pageid': pageIdentifier,
        // 'uri': pageUri,
        'duration': duration
      }
    };
    // print('eventData: $eventData');
    return eventData;
  }

  static getImpressionTelemetryEvent(
      String deviceIdentifier,
      String userId,
      String departmentId,
      String pageIdentifier,
      String userSessionId,
      String messageIdentifier,
      String telemetryType,
      String pageUri,
      {String env,
      String objectId,
      String objectType,
      bool isPublic = false,
      String subType}) {
    // String objectId, objectType;
    // if (telemetryType == TelemetryType.player) {
    //   List identifier = pageIdentifier.split('/');
    //   objectId = identifier.last;
    //   objectType = identifier[1] == EDisplayContentTypes.pdf.toLowerCase()
    //       ? EMimeTypes.pdf
    //       : identifier[1] == EDisplayContentTypes.html.toLowerCase()
    //           ? EMimeTypes.html
    //           : identifier[1] == EDisplayContentTypes.video.toLowerCase()
    //               ? EMimeTypes.mp4
    //               : identifier[1] == EDisplayContentTypes.audio.toLowerCase()
    //                   ? EMimeTypes.mp3
    //                   : identifier[1] == EDisplayContentTypes.quiz.toLowerCase()
    //                       ? EMimeTypes.assessment
    //                       : '';
    // } else {
    //   objectId = pageIdentifier;
    //   objectType = '';
    // }
    Map eventData = {
      'eid': TelemetryEvent.impression,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.impression}:$messageIdentifier',
      'actor': {'id': userId, 'type': isPublic ? 'AnonymousUser' : 'User'},
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
        'cdata': []
      },
      'object': {'id': objectId, 'type': objectType},
      // 'object': {},
      'tags': [],
      'edata': {
        'type': telemetryType,
        'pageid': pageIdentifier,
        'uri': pageUri,
        'subtype': subType
      }
    };
    // print('eventData: $eventData');
    return eventData;
  }

  static getInteractTelemetryEvent(
      String deviceIdentifier,
      String userId,
      String departmentId,
      String pageIdentifier,
      String userSessionId,
      String messageIdentifier,
      String contentId,
      String subType,
      {String env,
      String objectType,
      bool isPublic = false,
      String clickId = ''}) {
    Map eventData = {
      'eid': TelemetryEvent.interact,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.interact}:$messageIdentifier',
      'actor': {'id': userId, 'type': isPublic ? 'AnonymousUser' : 'User'},
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
        'cdata': []
      },
      'object': (contentId != null && contentId.isNotEmpty) &&
              (objectType != null && objectType.isNotEmpty)
          ? {'id': contentId, 'type': objectType}
          : null,
      'tags': [],
      'edata': {
        'id': clickId != null && clickId.isNotEmpty ? clickId : contentId,
        'type': 'click',
        'subtype': subType,
        'pageid': pageIdentifier
      }
    };
    // print('eventData: $eventData');
    return eventData;
  }

  // static getAuditTelemetryEvent(
  //   String deviceIdentifier,
  //   String userId,
  //   String departmentId,
  //   String userSessionId,
  //   String messageIdentifier,
  // ) {
  //   Map eventData = {
  //     'eid': TelemetryEvent.audit,
  //     'ets': DateTime.now().millisecondsSinceEpoch,
  //     'ver': APP_VERSION,
  //     'mid': '${TelemetryEvent.audit}:$messageIdentifier',
  //     'actor': {'id': userId, 'type': 'User'},
  //     'context': {
  //       'channel': departmentId,
  //       'pdata': {
  //         'id': TELEMETRY_PDATA_ID,
  //         'ver': APP_VERSION,
  //         'pid': TELEMETRY_PDATA_PID
  //       },
  //       'env': TelemetryPageIdentifier.home,
  //       'sid': userSessionId,
  //       'did': deviceIdentifier,
  //       // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
  //       'cdata': [],
  //       'rollup': {}
  //     },
  //     'object': {
  //       'ver': APP_VERSION,
  //       'id': TelemetryPageIdentifier.home // True here
  //     },
  //     'tags': [],
  //     'edata': {
  //       'type': TelemetryType.page,
  //       'pageid': TelemetryPageIdentifier.home,
  //       'uri': TelemetryPageIdentifier.home
  //     }
  //   };
  //   // print('eventData: $eventData');
  //   return eventData;
  // }
}
