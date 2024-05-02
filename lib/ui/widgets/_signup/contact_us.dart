import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/video_conference.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key key}) : super(key: key);

  void _mailTo(String mailId) async {
    // To create email with params
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: mailId,
    );
    // To launch the link
    await launchUrl(Uri.parse(_emailLaunchUri.toString()));
  }

  _launchCaller(String number) async {
    String url = "tel://$number";
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } else {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.black,
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context).mStaticContactUs,
            style: GoogleFonts.montserrat(
              color: AppColors.greys87,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: Colors.white),
      body: Container(
        margin: EdgeInsets.all(16),
        width: double.infinity,
        // height: MediaQuery.of(context).size.height * 0.30,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).mContactHeaderForAnyTech,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.25,
                        height: 1.5),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).mStaticEmail}: ',
                        style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.12,
                            fontSize: 16),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.1,
                        child: Link(
                            target: LinkTarget.blank,
                            uri: Uri.parse('mission.karmayogi@gov.in'),
                            builder: (context, followLink) => InkWell(
                                  onTap: () =>
                                      _mailTo('mission.karmayogi@gov.in'),
                                  child: Text(
                                    ('mission.karmayogi@gov.in'),
                                    style: GoogleFonts.lato(
                                        color: AppColors.primaryThree,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.25,
                                        height: 1.5),
                                    maxLines: 2,
                                  ),
                                )),
                      ),
                    ],
                  ),
                  VideoConferenceWidget()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
