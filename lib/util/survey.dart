import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart'
    as storage_const;
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/localization/index.dart';

class Survey extends StatefulWidget {
  final String surveyUrl;
  final BuildContext parentContext;
  const Survey({Key key, this.surveyUrl, this.parentContext}) : super(key: key);

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  InAppWebViewController _controller;
  String _authToken;
  bool cookiesSet = false;

  @override
  void initState() {
    super.initState();
    _getUserToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EnglishLang.karmayogiSurvey,
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: true,
        foregroundColor: AppColors.greys87,
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () => Navigator.of(widget.parentContext).pop(),
            child: BackButton(color: AppColors.greys60)),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse(widget.surveyUrl),
            headers: _getHeadersToLoadSurvey()),
        onWebViewCreated: (InAppWebViewController webViewController) async {
          _controller = webViewController;
          await _controller.evaluateJavascript(source: '''
              window.addEventListener('message', handleMessage);
              function handleMessage(res) {
                let responseData = JSON.parse(res.data);
                console.log('We got the response from the browser', JSON.stringify(responseData));
              }
            ''');
        },
        onLoadStop: (controller, url) async {
          if (!cookiesSet) {
            await _setCookies();
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          print('Console message: ${consoleMessage.message}');
        },
      ),
    );
  }

  Future<void> _setCookies() async {
    await _controller.evaluateJavascript(source: '''
     localStorage.setItem('API-KEY','${ApiUrl.apiKey}');
     localStorage.setItem('USER-TOKEN','$_authToken');
   ''');
    cookiesSet = true;
  }

  Future<String> _getUserToken() async {
    final storage = FlutterSecureStorage();
    _authToken = await storage.read(key: storage_const.Storage.authToken);
    // log('token: $_authToken, userId: $_userId');
    if (_authToken == null || JwtDecoder.isExpired(_authToken)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingPage(),
        ),
      );
    } else {
      storage.delete(key: storage_const.Storage.deepLinkPayload);
    }
    return _authToken;
  }

  _getHeadersToLoadSurvey() {
    Map<String, String> headers = {
      "Cookie": "API-KEY=${ApiUrl.apiKey};USER-TOKEN=$_authToken"
    };
    return headers;
  }

  // _closeWindow() {
  //   Future.delayed(Duration(seconds: 1), () async {
  //     Navigator.of(context).pop();
  //   });
  // }
}
