import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/configurations/social_media.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FollowUsOnSocialMedia extends StatelessWidget {
  const FollowUsOnSocialMedia({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 70, 16, 70),
        child: Column(
          children: [
            Text(AppLocalizations.of(context).mStaticFollowUs,
                style: GoogleFonts.montserrat(
                    color: AppColors.greys60,
                    fontSize: 16.0,
                    letterSpacing: 0.12,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var socialMediaItems in SocialMedia.items)
                    InkWell(
                      onTap: () async =>
                          await canLaunchUrl(Uri.parse(socialMediaItems.url))
                              .then((value) => value
                                  ? launchUrl(Uri.parse(socialMediaItems.url),
                                      mode: LaunchMode.externalApplication)
                                  : throw 'Please try after sometime'),
                      child: SvgPicture.asset(
                        socialMediaItems.imagePath,
                        width: 32.0,
                        height: 32.0,
                      ),
                    )
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              "App Version" + ' ' + APP_VERSION,
              style: GoogleFonts.lato(
                  color: AppColors.greys60,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 0.25),
            )
          ],
        ),
      ),
    );
  }
}
