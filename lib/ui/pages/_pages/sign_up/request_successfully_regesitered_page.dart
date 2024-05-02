import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestSuccessfullyRegisteredPage extends StatefulWidget {
  @override
  State<RequestSuccessfullyRegisteredPage> createState() =>
      _RequestSuccessfullyRegisteredPageState();
}

class _RequestSuccessfullyRegisteredPageState
    extends State<RequestSuccessfullyRegisteredPage> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      child: Image.asset(
                        'assets/img/Karmayogi_bharat_logo_horizontal.png',
                        width: 277,
                        fit: BoxFit.fitWidth,
                        height: 82,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 130),
                            child: SvgPicture.asset(
                              'assets/img/approved.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Text(
                            AppLocalizations.of(context).mStaticThankYou,
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.12,
                                height: 1.5),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Text(
                            AppLocalizations.of(context).mStaticRequestLogged,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.12,
                                height: 1.5),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12, left: 46, right: 46),
                          child: Text(
                            AppLocalizations.of(context)
                                .mStaticRequestSentConfirmation,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.25,
                                height: 1.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      width: 182,
                      height: 48,
                      child: ButtonTheme(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            // primary: Colors.white,
                            side: BorderSide(
                                width: 1, color: AppColors.primaryThree),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            // onSurface: Colors.grey,
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .mStaticOk
                                .toUpperCase(),
                            style: GoogleFonts.lato(
                                color: AppColors.primaryThree,
                                fontSize: 14,
                                letterSpacing: 0.5,
                                height: 1.5,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
