import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ApprovalIndicators extends StatelessWidget {
  const ApprovalIndicators({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _iconIndicatorWidget('assets/img/needs_approval.svg',
                AppLocalizations.of(context).mEditProfileRequiresApproval),
            _iconIndicatorWidget('assets/img/sent_for_approval.svg',
                AppLocalizations.of(context).mEditProfileSentForApproval),
            _iconIndicatorWidget('assets/img/approved.svg',
                AppLocalizations.of(context).mEditProfileApproved),
          ],
        ),
      ),
    );
  }

  _iconIndicatorWidget(String iconPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        height: 40,
        padding: EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          color: AppColors.grey04,
          borderRadius: BorderRadius.all(const Radius.circular(24.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              text,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}
