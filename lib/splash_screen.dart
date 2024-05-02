import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import 'localization/_langs/english_lang.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    vallidateUserSession();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/img/Login_background.svg',
          // alignment: Alignment.center,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Center(
            child: Container(
          child: Image(
            image: AssetImage('assets/img/Karmayogi_bharat_Logo.png'),
            height: MediaQuery.of(context).size.width * 0.45,
          ),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          alignment: Alignment.bottomCenter,
          child: Text(
            EnglishLang.publicCopyRightText,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void vallidateUserSession() async {
    final _storage = FlutterSecureStorage();
    String token = await _storage.read(key: Storage.authToken);

    if (token == null) {
      return;
    }
    final ramainingTime = JwtDecoder.getRemainingTime(token);
    final bufferHours = 4;
    if (Helper.isTokenExpired(token) || (ramainingTime.inHours < bufferHours)) {
      await updateToken(_storage);
    }
  }

  Future<void> updateToken(FlutterSecureStorage _storage) async {
    var response = await Helper.getNewToken();
    if (response.statusCode == 200) {
      Map convertedResponse = json.decode(response.body);
      if (convertedResponse['access_token'] != null) {
        await _storage.write(
            key: Storage.authToken, value: convertedResponse['access_token']);
      }
      if (convertedResponse['refresh_token'] != null) {
        await _storage.write(
            key: Storage.refreshToken,
            value: convertedResponse['refresh_token']);
      }
    }
  }
}
