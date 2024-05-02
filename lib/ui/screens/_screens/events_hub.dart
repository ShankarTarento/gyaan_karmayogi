import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/index.dart';

class EventsHub extends StatelessWidget {
  const EventsHub({Key key}) : super(key: key);
  static const route = AppUrl.eventsHub;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        duration: Duration(milliseconds: 0),
        child: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: BackButton(color: AppColors.greys60),
                    ),
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsets.fromLTRB(60.0, 0.0, 10.0, 0.0),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SvgPicture.asset(
                              'assets/img/events.svg',
                              width: 24.0,
                              height: 24.0,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12.0, top: 10.0),
                            child: Text(
                              AppLocalizations.of(context).mEvents,
                              style: GoogleFonts.montserrat(
                                color: AppColors.greys87,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Spacer(),
                          KarmaPointAppbarWidget(),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              // TabBar view
              body: EventsPage()),
        ),
      ),
      bottomSheet: BottomBar(),
    );
  }
}
