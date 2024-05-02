import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoEventsWidget extends StatelessWidget {
  const NoEventsWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Text(
        AppLocalizations.of(context).mEventsNoEvent,
        style: GoogleFonts.lato(color: AppColors.greys87),
      ),
    );
  }
}
