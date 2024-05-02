import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/splash_screen.dart';
import 'package:flutter/material.dart';

import 'constants/_constants/app_constants.dart';

class IGotApp extends StatelessWidget {
  const IGotApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(DEFAULT_DESIGN_WIDTH, DEFAULT_DESIGN_HEIGHT),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            return MediaQuery(
              ///Setting font does not change with system font size
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget,
            );
          },
          home: AnimatedSplashScreen(
              duration: 2000,
              splashIconSize: double.infinity,
              splashTransition: SplashTransition.fadeTransition,
              splash: SplashScreen(),
              nextScreen: LandingPage()),
          routes: <String, WidgetBuilder>{
            AppUrl.landingPage: (BuildContext context) => LandingPage(
              isFromUpdateScreen: false,
            )
          },
        );
      },
    );
  }
}
