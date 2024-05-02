import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../localization/_langs/english_lang.dart';

class ShowMarkedAttendenceWidget extends StatelessWidget {
  final String dateAndTime;
  final String message;

  ShowMarkedAttendenceWidget(
      {Key key, @required this.dateAndTime, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/img/approved.svg',
              fit: BoxFit.fill,
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.black87,
                    fontSize: 16,
                    letterSpacing: 0.25,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(dateAndTime),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).mCommonClose),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        ),
      ),
    );
  }
}
