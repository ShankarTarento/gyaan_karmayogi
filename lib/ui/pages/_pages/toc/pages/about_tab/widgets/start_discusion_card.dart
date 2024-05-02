import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartDiscussionCard extends StatelessWidget {
  const StartDiscussionCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        SvgPicture.asset(
          "assets/img/Discuss.svg",
          alignment: Alignment.center,
          height: 40,
          width: 40,
          color: Color(0xffF3962F),
          fit: BoxFit.cover,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          AppLocalizations.of(context).mStaticDiscussionMessage,
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xff000000).withOpacity(0.85)),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1B4CA1), // background color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(36.0), // button border radius
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppUrl.discussionHub);
            },
            child: Text(
              AppLocalizations.of(context).mDiscussStartDiscuss,
              style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ))
      ]),
    );
  }
}
