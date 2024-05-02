import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/oAuth2_login.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/services/_services/vega_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/featured_courses.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_one_body.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_three_body.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_two_body.dart';
import 'package:karmayogi_mobile/ui/widgets/chatbotbtn.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/ui/widgets/language_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final bool appFromInitialState;
  const OnboardingScreen({Key key, this.appFromInitialState = false})
      : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _storage = FlutterSecureStorage();
  StreamSubscription _connectivitySubscription;
  bool _isDeviceConnected = false;
  bool _isSetAlert = false;
  GlobalKey _vegaFAQKey = GlobalKey();
  bool _isFromInitialState;
  String _isFirstTimeUser;
  final VegaService vegaService = VegaService();

  @override
  void initState() {
    super.initState();
    _checkForDeepLink();
    _getUserOnboardedStatus();
    _getConnectivity();
    _isFromInitialState = widget.appFromInitialState;
    _getFaqData();
    // Uncomment this line for KB-Digital assistant service
    if (VegaConfiguration.isEnabled) {
      if (widget.appFromInitialState && _isFirstTimeUser == null) {
        Future.delayed(Duration(milliseconds: 500), () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            ShowCaseWidget.of(context).startShowCase([_vegaFAQKey]);
          });
        });
      }
      vegaService.getVegaSuggestions(isRegistered: 0, isMDO: 0, isSPV: 0);
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForDeepLink();
  }

  void _getFaqData() async {
    String isLoggedIn = await _storage.read(key: Storage.hasFetchedFaqData);
    if (isLoggedIn == null) {
      await Provider.of<ChatbotRepository>(context, listen: false).getAlData();
    }
    await Provider.of<ChatbotRepository>(context, listen: false)
        .getFaqData(isLoggedIn: false);
    if (mounted) {
      setState(() {});
    }
  }

  _getUserOnboardedStatus() async {
    _isFirstTimeUser = await _storage.read(key: Storage.isUserOnboarded);
  }

  _getConnectivity() async {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!_isDeviceConnected && !_isSetAlert) {
        _showDialogBox();
        setState(() {
          _isSetAlert = true;
        });
      }
    });
  }

  _showDialogBox() => {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext contxt) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AlertDialog(
                        insetPadding: EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        actionsPadding: EdgeInsets.zero,
                        actions: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.negativeLight),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TitleRegularGrey60(
                                      AppLocalizations.of(context)
                                          .mStaticNoConnectionDescription,
                                      fontSize: 14,
                                      color: AppColors.appBarBackground,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(contxt, EnglishLang.cancel);
                                    setState(() {
                                      _isSetAlert = false;
                                    });
                                    _isDeviceConnected =
                                        await InternetConnectionChecker()
                                            .hasConnection;
                                    if (!_isDeviceConnected) {
                                      _showDialogBox();
                                      setState(() {
                                        _isSetAlert = true;
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0),
                                    child: Icon(
                                      Icons.replay_outlined,
                                      color: AppColors.appBarBackground,
                                      size: 24,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                  ],
                ))
      };

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
    // _getUserSessionId();
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration getPageDecoration(
            {bool contentMargin = true, titlePadding = true}) =>
        PageDecoration(
          safeArea: 0,
          pageColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          bodyTextStyle: TextStyle(fontSize: 20),
          contentMargin: contentMargin ? EdgeInsets.all(16) : EdgeInsets.all(0),
          titlePadding: titlePadding
              ? EdgeInsets.only(top: 16.0, bottom: 24.0)
              : EdgeInsets.all(0),
          // titlePadding: EdgeInsets.only(bottom: 16)
        );
    return Scaffold(
        backgroundColor: AppColors.primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 35,
          actions: [
            LanguageDropdown(
              isHomePage: false,
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        body: Stack(
          children: [
            IntroductionScreen(
              controlsPadding: EdgeInsets.all(2.0),
              bodyPadding: EdgeInsets.only(bottom: 20),
              globalBackgroundColor: Colors.white,
              showNextButton: false,
              pages: [
                PageViewModel(
                    titleWidget: Image(
                      image: AssetImage(
                          'assets/img/Karmayogi_bharat_logo_horizontal.png'),
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.45,
                    ),
                    // SvgPicture.asset(
                    //   'assets/img/KarmayogiBharat_Logo_Horizontal.svg',
                    //   width: MediaQuery.of(context).size.width * 0.45,
                    //   height: MediaQuery.of(context).size.height * 0.08,
                    // ),
                    bodyWidget: IntroOneBody(),
                    decoration: getPageDecoration(contentMargin: false)),
                PageViewModel(
                    // titleWidget: SvgPicture.asset(
                    //   'assets/img/KarmayogiBharat_Logo_Horizontal.svg',
                    //   width: MediaQuery.of(context).size.width * 0.4,
                    // ),
                    titleWidget: Center(),
                    bodyWidget: IntroTwoBody(),
                    decoration: getPageDecoration(titlePadding: false)),
                // PageViewModel(
                //     titleWidget: Center(),
                //     bodyWidget: IntroFourBody(),
                //     decoration: getPageDecoration(titlePadding: false)),
                PageViewModel(
                    // titleWidget: SvgPicture.asset(
                    //   'assets/img/KarmayogiBharat_Logo_Horizontal.svg',
                    //   width: MediaQuery.of(context).size.width * 0.4,
                    // ),
                    titleWidget: Center(),
                    bodyWidget: IntroThreeBody(),
                    decoration: getPageDecoration(titlePadding: false)),
              ],
              // next: Text("Next",
              //     style: TextStyle(
              //         fontWeight: FontWeight.w700,
              //         color: AppColors.greys87,
              //         fontSize: 14)),
              showBackButton: false,
              // back: Text("Back",
              //     style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              showSkipButton: false,
              // skip: Text(EnglishLang.signIn,
              //     style: TextStyle(
              //         fontWeight: FontWeight.w700,
              //         color: AppColors.greys87,
              //         fontSize: 14)),
              // onSkip: () => Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) => OAuth2Login(),
              //   ),
              // ),
              // done: Text(
              //   EnglishLang.register,
              //   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              // ),
              showDoneButton: false,
              // onDone: () => Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => SignUpPage(),
              //   ),
              // ),
              dotsDecorator: DotsDecorator(
                  color: AppColors.grey16,
                  activeColor: AppColors.primaryBlue,
                  activeSize: Size(28, 8),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              globalFooter: SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  height:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? (MediaQuery.of(context).size.height * 0.07)
                          : (MediaQuery.of(context).size.shortestSide * 0.1),
                  color: AppColors.primaryBlue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.44,
                          padding: EdgeInsets.only(left: 16),
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FeaturedCoursesPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .mBtnFeaturedCourses,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.375,
                                    letterSpacing: 0.125),
                              ))),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Opacity(
                          opacity: 0.75,
                          child: VerticalDivider(
                            color: Colors.white,
                            width: 10,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.only(right: 16),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => OAuth2Login(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).mBtnSignIn,
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.375,
                                letterSpacing: 0.125),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // VegaConfiguration.isEnabled
            //     ? Positioned(
            //         bottom: 90,
            //         right: 16,
            //         child: (_isFromInitialState && _isFirstTimeUser == null)
            //             ? Showcase(
            //                 key: _vegaFAQKey,
            //                 targetShapeBorder: CircleBorder(),
            //                 targetPadding: EdgeInsets.all(4),
            //                 description: 'Ask your queries',
            //                 child: OpenContainer(
            //                   openColor: Colors.white,
            //                   transitionDuration: Duration(milliseconds: 750),
            //                   openBuilder: (context, _) => AiAssistantPage(
            //                     searchKeyword: '...',
            //                     index: 2,
            //                     isPublic: true,
            //                   ),
            //                   closedShape: CircleBorder(),
            //                   closedColor: Colors.white,
            //                   closedElevation: 4,
            //                   transitionType:
            //                       ContainerTransitionType.fadeThrough,
            //                   closedBuilder: (context, openContainer) =>
            //                       FloatingActionButton(
            //                     heroTag: 'ai',
            //                     onPressed: () {
            //                       openContainer();
            //                       _storage.write(
            //                           key: Storage.isUserOnboarded,
            //                           value: 'false');
            //                       setState(() {
            //                         _isFromInitialState = false;
            //                       });
            //                     },
            //                     child: Icon(Icons.question_answer),
            //                     backgroundColor: AppColors.primaryBlue,
            //                   ),
            //                 ))
            //             : OpenContainer(
            //                 openColor: Colors.white,
            //                 transitionDuration: Duration(milliseconds: 750),
            //                 openBuilder: (context, _) => AiAssistantPage(
            //                   searchKeyword: '...',
            //                   index: 2,
            //                   isPublic: true,
            //                 ),
            //                 closedShape: CircleBorder(),
            //                 closedColor: Colors.white,
            //                 transitionType: ContainerTransitionType.fadeThrough,
            //                 closedBuilder: (context, openContainer) =>
            //                     FloatingActionButton(
            //                   onPressed: openContainer,
            //                   child: Icon(Icons.question_answer),
            //                   backgroundColor: AppColors.primaryBlue,
            //                 ),
            //               ))
            //     : Center()
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Chatbotbtn(
          loggedInStatus: EnglishLang.NotLoggedIn,
        ));
  }

  void _checkForDeepLink() async {
    final String deepLinkData =
        await _storage.read(key: Storage.deepLinkPayload);
    if (deepLinkData != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OAuth2Login(),
        ),
      );
    }
  }
}
