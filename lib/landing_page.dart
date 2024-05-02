import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/deeplink_model.dart';
import 'package:karmayogi_mobile/oAuth2_login.dart';
import 'package:karmayogi_mobile/respositories/_respositories/badge_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/category_repoistory.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/competency_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/discuss_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/in_app_review_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/knowledge_resource_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/landing_page_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/network_respository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/notification_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/nps_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/local_notification_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/services/gyaan_karmayogi_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/onboarding_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/error_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/cbp/cbp_filters.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/competency/competency_filter.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/update_password.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/routes.dart';
import 'package:karmayogi_mobile/util/survey.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:upgrader/upgrader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LandingPage extends StatefulWidget {
  final bool isFromUpdateScreen;
  const LandingPage({Key key, this.isFromUpdateScreen = false})
      : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
  Future<void> setLocale(BuildContext context, Locale newLocale) async {
    _LandingPageState state =
        context.findAncestorStateOfType<_LandingPageState>();
    state?.setLocale(newLocale);
  }
}

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorPage();
  };
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final client = HttpClient();
  final _storage = FlutterSecureStorage();
  bool get notProdRelease => !Helper.itsProdRelease;
  String _code;
  String _parichayCode;
  String _parichayToken;
  String _token;
  StreamSubscription<Uri> _linkSubscription;
  Locale _locale;
  String _deeplinkingUrl;

  @override
  void initState() {
    super.initState();
    _getSessionId();
    _getLocale();
    _handleFirebaseLocalNotification();
    if (!widget.isFromUpdateScreen) {
      _initAppLinks();
    }
    //Setting the reminder option for profile update nudge to be functional
    _storage.write(key: Storage.showReminder, value: EnglishLang.no);
    //checking token to access the app
    _checkCode();
    //To get the Unique Identifier of the app
    _initUniqueIdentifierState();
  }

  _handleFirebaseLocalNotification() async {
    if (Platform.isIOS) {
      FirebaseNotificationService().foregroundMessage();
    }
    await FirebaseNotificationService().handleMessage();
  }

  _getLocale() async {
    final String deviceLocale = Platform.localeName.split('_').first.toString();
    String selectedAppLanguage =
        await _storage.read(key: Storage.selectedAppLanguage);

    if (selectedAppLanguage == null) {
      switch (deviceLocale) {
        case AppLocale.hindi:
          _locale = Locale(AppLocale.hindi);
          break;

        case AppLocale.marathi:
          _locale = Locale(AppLocale.marathi);
          break;

        case AppLocale.tamil:
          _locale = Locale(AppLocale.tamil);
          break;

        case AppLocale.assamese:
          _locale = Locale(AppLocale.assamese);
          break;

        case AppLocale.bengali:
          _locale = Locale(AppLocale.bengali);
          break;

        case AppLocale.telugu:
          _locale = Locale(AppLocale.telugu);
          break;

        case AppLocale.kannada:
          _locale = Locale(AppLocale.kannada);
          break;

        case AppLocale.malaylam:
          _locale = Locale(AppLocale.malaylam);
          break;

        case AppLocale.gujarati:
          _locale = Locale(AppLocale.gujarati);
          break;

        case AppLocale.oriya:
          _locale = Locale(AppLocale.oriya);
          break;

        case AppLocale.punjabi:
          _locale = Locale(AppLocale.punjabi);
          break;

        default:
          _locale = Locale(AppLocale.english);
      }
    } else {
      _locale = Locale(jsonDecode(selectedAppLanguage)['value']);
    }
  }

  Future<void> _initAppLinks() async {
    // print('Calling init link');
    AppLinks _appLinks = AppLinks();
    String baseUrl = Env.portalBaseUrl;

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getLatestAppLink();
    // print('Connecting to app link');
    if (appLink != null) {
      // print('getInitialAppLink: $appLink');
      // openAppLink(appLink);
      if (appLink.toString().startsWith(
          "$baseUrl/auth/realms/sunbird/login-actions/action-token")) {
        // print('Navigating');
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UpdatePassword(
              initialUrl: appLink.toString(),
            ),
          ),
        );
      }
      if (appLink.toString().startsWith("$baseUrl/mligot/mlsurvey")) {
        // print('Navigating');
        _deeplinkingUrl = appLink.toString();
        DeepLink deepLinkPayLoad =
            DeepLink(url: _deeplinkingUrl, category: DeepLinkCategory.survey);
        _storage.write(
            key: Storage.deepLinkPayload,
            value: jsonEncode(DeepLink.toJson(deepLinkPayLoad)));
      }
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      // print('onAppLink: $uri');
      if (uri.toString().startsWith(
          "${Env.portalBaseUrl}/auth/realms/sunbird/login-actions/action-token")) {
        // print('Navigating');
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UpdatePassword(
              initialUrl: uri.toString(),
            ),
          ),
        );
      }
      if (uri.toString().startsWith("$baseUrl/mligot/mlsurvey")) {
        _deeplinkingUrl = uri.toString();
        await _storage.write(
            key: Storage.deepLinkPayload,
            value: jsonEncode(DeepLink.toJson(DeepLink(
                url: _deeplinkingUrl, category: DeepLinkCategory.survey))));
        String token = await _storage.read(key: Storage.authToken);
        if (token != null && !JwtDecoder.isExpired(token)) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => Survey(
              surveyUrl: _deeplinkingUrl.toString(),
              parentContext: context,
            ),
          ));
        } else {
          setState(() {});
        }
      }
      // openAppLink(uri);
    });
  }

  Future<void> _checkCode() async {
    String code = await _storage.read(key: Storage.code);
    String parichayCode = await _storage.read(key: Storage.parichayCode);
    String parichayToken = await _storage.read(key: Storage.parichayAuthToken);
    String token = await _storage.read(key: Storage.authToken);
    setState(() {
      _code = code;
      _parichayCode = parichayCode;
      _parichayToken = parichayToken;
      _token = token;
    });
  }

  Future<void> _initUniqueIdentifierState() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial;
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    identifier = sha256.convert(utf8.encode(identifier)).toString();
    _storage.write(key: Storage.deviceIdentifier, value: identifier);
    // print('identifier: $identifier');
  }

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
    // _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    setErrorBuilder();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LoginRespository()),
        ChangeNotifierProvider.value(value: DiscussRepository()),
        ChangeNotifierProvider.value(value: CategoryRepository()),
        ChangeNotifierProvider.value(value: NetworkRespository()),
        ChangeNotifierProvider.value(value: NotificationRespository()),
        ChangeNotifierProvider.value(value: KnowledgeResourceRespository()),
        ChangeNotifierProvider.value(value: LearnRepository()),
        ChangeNotifierProvider.value(value: CompetencyRepository()),
        ChangeNotifierProvider.value(value: ProfileRepository()),
        ChangeNotifierProvider.value(value: EventRepository()),
        ChangeNotifierProvider.value(value: BadgeRepository()),
        ChangeNotifierProvider.value(value: ChatbotRepository()),
        ChangeNotifierProvider.value(value: NpsRepository()),
        ChangeNotifierProvider.value(value: LandingPageRepository()),
        ChangeNotifierProvider.value(value: InAppReviewRespository()),
        ChangeNotifierProvider.value(value: CBPFilter()),
        ChangeNotifierProvider.value(value: CompetencyFilter()),
        ChangeNotifierProvider.value(value: LandingPageRepository()),
        ChangeNotifierProvider.value(value: GyaanKarmayogiServices()),
        ChangeNotifierProvider.value(value: TocServices())

        // ChangeNotifierProvider(
        //     create: (_) => NetworkRespository(NetworkService(client))),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ChatbotRepository(),
        builder: (context, child) {
          return MaterialApp(
            title: APP_NAME,
            theme: ThemeData(
                scaffoldBackgroundColor: AppColors.scaffoldBackground,
                primaryColor: Colors.white,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor:
                      AppColors.darkBlue, // Set your desired cursor color
                ),
                appBarTheme: AppBarTheme(
                    color: Colors.white, foregroundColor: Colors.black),
                dividerColor: Colors.transparent),
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            onGenerateRoute: Routes.generateRoute,
            onUnknownRoute: Routes.errorRoute,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _locale,
            home: ((_code != null && _token != null) ||
                    (_parichayCode != null &&
                        (_parichayToken != null && _token != null)))
                ? CustomTabs(customIndex: 0)
                : (_deeplinkingUrl != null && _deeplinkingUrl.isNotEmpty
                    ? OAuth2Login()
                    : UpgradeAlert(
                        upgrader: Upgrader(
                            showIgnore: notProdRelease,
                            showLater: notProdRelease,
                            shouldPopScope: () => notProdRelease,
                            canDismissDialog: false,
                            durationUntilAlertAgain: const Duration(minutes: 5),
                            dialogStyle: Platform.isIOS
                                ? UpgradeDialogStyle.cupertino
                                : UpgradeDialogStyle.material),
                        child: ShowCaseWidget(
                          builder: Builder(
                              builder: (context) => OnboardingScreen(
                                    appFromInitialState: true,
                                  )),
                        ),
                      )),
          );
        },
      ),
    );
  }

  void _getSessionId() async {
    await Telemetry.generateUserSessionId(isAppStarted: true);
  }
}
