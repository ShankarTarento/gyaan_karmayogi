import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VideoConferenceWidget extends StatelessWidget {
  const VideoConferenceWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(color: AppColors.onpagebgrdColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Text(
                AppLocalizations.of(context).mContactVideoConference,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    color: AppColors.primaryBlue,
                    height: 1.5,
                    letterSpacing: 0.25,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: AppColors.grey16),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context).mContactSupportReqd,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: AppColors.textHeadingColor,
                          height: 1.5,
                          letterSpacing: 0.25,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).mContactWeekDays,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: AppColors.black,
                          height: 1.5,
                          letterSpacing: 0.25,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 1),
                    Text(
                      EnglishLang.timings,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: AppColors.black,
                          height: 1.5,
                          letterSpacing: 0.25,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: _launchURL,
                      child: Container(
                        width: 160,
                        height: 45,
                        decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            border: Border.all(
                                width: 1, color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).mContactBtnJoinNow,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                height: 1.5,
                                letterSpacing: 0.25,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            )
          ],
        ),
      ),
    );
  }

  void _launchURL() async =>
      await canLaunchUrl(Uri.parse(EnglishLang.htmlTeamsUriLink)).then(
          (value) => value
              ? launchUrl(Uri.parse(EnglishLang.htmlTeamsUriLink),
                  mode: LaunchMode.externalApplication)
              : throw 'Please try after sometime');
}
