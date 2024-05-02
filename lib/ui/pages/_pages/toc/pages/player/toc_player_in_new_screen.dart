import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';

class TocPlayerInNewScreen extends StatelessWidget {
  final Widget player;
  final bool isYoutubeContent, isAssessment, isSurvey;
  final String resourcename;
  TocPlayerInNewScreen(
      {Key key,
      @required this.player,
      @required this.resourcename,
      this.isYoutubeContent = false,
      this.isAssessment = false,
      this.isSurvey = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).mOpenresource(isYoutubeContent
              ? 'Youtube'
              : isAssessment
                  ? 'Assessment'
                  : isSurvey
                      ? 'Survey'
                      : 'Scorm'),
          style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.25),
        ),
        SizedBox(
          height: 16,
        ),
        InkWell(
          onTap: () {
            isYoutubeContent || isAssessment
                ? Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => player),
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              titleSpacing: 0,
                              leading: BackButton(color: AppColors.white70),
                              title: Row(children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      AppLocalizations.of(context).mBack,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        color: AppColors.white70,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ))
                              ]),
                            ),
                            body: Center(child: player), // Your current screen's content
                          ),
                        )
                    ),
                  );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.orangeTourText,
                borderRadius: BorderRadius.circular(63)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isYoutubeContent
                    ? SvgPicture.asset(
                        'assets/img/youtube_icon.svg',
                        height: 24,
                        width: 24,
                        color: AppColors.greys87,
                      )
                    : isAssessment
                        ? SvgPicture.asset(
                            'assets/img/assessment_icon_alternate.svg',
                            height: 24,
                            width: 24,
                            color: AppColors.greys87,
                          )
                        : SvgPicture.asset(
                            'assets/img/resourse_alternate.svg',
                            height: 24,
                            width: 24,
                            color: AppColors.greys87,
                          ),
                SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).mStaticOpen,
                  style: GoogleFonts.lato(
                      color: AppColors.profilebgGrey,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.25),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
