import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_landingPage/hub_info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class IntroThreeBody extends StatelessWidget {
  const IntroThreeBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).mSolutioningSpace,
          style: GoogleFonts.montserrat(
              color: AppColors.primaryBlue,
              height: 1.5,
              fontSize: 24.0,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 32,
        ),
        Column(
          children: [
            HubInfoCard(
              title: AppLocalizations.of(context).mLearningHub,
              description: AppLocalizations.of(context).mLearnhubPara,
              icon: 'assets/img/Learn.svg',
            ),
            Divider(
              height: 35,
              thickness: 1,
              color: AppColors.grey08,
            ),
            HubInfoCard(
              title: AppLocalizations.of(context).mDiscussionHub,
              description:
                  AppLocalizations.of(context).mDiscussionHubSubHeading,
              icon: 'assets/img/Discuss.svg',
            ),
            Divider(
              height: 35,
              thickness: 1,
              color: AppColors.grey08,
            ),
            HubInfoCard(
              title: AppLocalizations.of(context).mNetworkHub,
              description: AppLocalizations.of(context).mNetworkHubParagraph,
              icon: 'assets/img/Network.svg',
            ),
            Divider(
              height: 35,
              thickness: 1,
              color: AppColors.grey08,
            ),
            HubInfoCard(
              title: AppLocalizations.of(context).mCompetencyHub,
              description: AppLocalizations.of(context).mCompetencyHubPara,
              icon: 'assets/img/competencies.svg',
            ),
            Divider(
              height: 35,
              thickness: 1,
              color: AppColors.grey08,
            ),
            HubInfoCard(
              title: AppLocalizations.of(context).mCareerHub,
              description: AppLocalizations.of(context).mCareerHubPara,
              icon: 'assets/img/Careers.svg',
            ),
            Divider(
              height: 35,
              thickness: 1,
              color: AppColors.grey08,
            ),
            HubInfoCard(
              title: AppLocalizations.of(context).mEventHub,
              description: AppLocalizations.of(context).mEventHubPara,
              icon: 'assets/img/events.svg',
            ),
          ],
        )
      ],
    );
  }
}
