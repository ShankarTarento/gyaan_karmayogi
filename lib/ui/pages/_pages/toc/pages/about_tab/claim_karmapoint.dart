import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../localization/index.dart';
import '../../../../../../respositories/_respositories/profile_repository.dart';

class ClaimKarmaPoints extends StatelessWidget {
  final String courseId;
  final ValueChanged<bool> claimedKarmaPoint;
  ClaimKarmaPoints(
      {Key key, @required this.courseId, @required this.claimedKarmaPoint})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ElevatedButton(
          onPressed: () async {
            var response = await claimKarmaPoints();
            if (response.toString() == EnglishLang.success) {
              claimedKarmaPoint(true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.verifiedBadgeIconColor,
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63),
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                textWidget(AppLocalizations.of(context).mStaticClaim + ' ',
                    FontWeight.w700,
                    color: AppColors.appBarBackground, fontSize: 14),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset(
                    'assets/img/kp_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                textWidget(
                    ' +10 ' +
                        AppLocalizations.of(context).mStaticKarmaPoints +
                        '.',
                    FontWeight.w700,
                    color: AppColors.appBarBackground,
                    fontSize: 14),
              ],
            ),
          )),
    );
  }

  TextSpan textWidget(String message, FontWeight font,
      {Color color = AppColors.greys87, double fontSize = 12}) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }

  Future<String> claimKarmaPoints() async {
    return await ProfileRepository().claimKarmaPoints(courseId);
  }
}
