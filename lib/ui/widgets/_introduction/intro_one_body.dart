import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/video_conference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class IntroOneBody extends StatelessWidget {
  const IntroOneBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/image_bg_blue.png'),
                fit: BoxFit.fill),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)
                      .mCommonKarmayogiBharat
                      .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anton(
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.width * 0.1,
                      height: 1.125,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  color: AppColors.orangeBackground,
                  // height: 52,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                     AppLocalizations.of(context)
                     .mStaticNationalprogram,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        // letterSpacing: -2.5
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Image.asset(
        //   'assets/img/Intro.png',
        //   height: MediaQuery.of(context).size.height * 0.42,
        // ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  AppLocalizations.of(context).mStaticWelcomeintrotext,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      height: 1.5,
                      letterSpacing: 0.25,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400),
                ),
              ),
              VideoConferenceWidget()
            ],
          ),
        )
      ],
    );
  }
}
