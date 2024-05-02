import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/language_dropdown.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../models/index.dart';
import '../index.dart';

class HomeAppBarNew extends StatelessWidget implements PreferredSizeWidget {
  final Profile profileInfo;
  final int index;
  final AppBar appBar;
  final SliverAppBar silverAppBar;
  final profileParentAction;
  final bool isSearch;
  const HomeAppBarNew(
      {Key key,
      this.profileInfo,
      this.appBar,
      this.silverAppBar,
      this.index = 0,
      this.profileParentAction,
      this.isSearch = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [
            isSearch
                ? GestureDetector(
                    onTap: () async {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => CustomTabs(
                              customIndex: 0,
                            ),
                          ),
                        );
                      }
                    },
                    child: Icon(Icons.arrow_back))
                : ProfilePicture(profileInfo,
                    profileParentAction: profileParentAction),
            SizedBox(width: 8),
            SizedBox(
              width: index == 0 ? 0 : 110,
              child: Text(
                index == 1
                    ? AppLocalizations.of(context).mStaticExplore
                    : index == 2
                        ? AppLocalizations.of(context).mCommonSearch
                        : index == 3
                            ? AppLocalizations.of(context).mTabMyLearnings
                            : '',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.12,
                    color: AppColors.greys87,
                    height: 1.5),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
          SizedBox(
            width: 4,
          ),
          Spacer(),
          KarmaPointAppbarWidget(),
          SizedBox(
            width: 15,
          ),
          index == 0
              ? LanguageDropdown(
                  isHomePage: true,
                )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                FadeRoute(page: ContactUs()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: SvgPicture.asset(
                'assets/img/help_icon.svg',
                fit: BoxFit.fill,
                color: AppColors.profilebgGrey,
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        ],
      ),
      floating: true,
      automaticallyImplyLeading: false,
      // pinned: true,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
