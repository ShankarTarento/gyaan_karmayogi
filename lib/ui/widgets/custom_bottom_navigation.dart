import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import '../pages/_pages/ai_assistant_page.dart';
import '../pages/index.dart';
import './../../ui/screens/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomBottomNavigation {
  final Widget page;
  final String title;
  final Icon icon;
  final String svgIcon;
  final String unselectedSvgIcon;
  final int index;
  final String telemetryId;

  CustomBottomNavigation({
    this.page,
    this.title,
    this.icon,
    this.svgIcon,
    this.unselectedSvgIcon,
    this.index,
    this.telemetryId,
  });

  static List<CustomBottomNavigation> get items => [
        CustomBottomNavigation(
            page: HomeScreen(),
            title: 'Home',
            icon: Icon(
              Icons.home,
            ),
            svgIcon: 'assets/img/home_blue.svg',
            unselectedSvgIcon: 'assets/img/home.svg',
            index: 0),
        CustomBottomNavigation(
            page: HubScreen(),
            title: 'Explore',
            icon: Icon(
              Icons.apps,
            ),
            svgIcon: 'assets/img/grid_blue.svg',
            unselectedSvgIcon: 'assets/img/grid.svg',
            index: 1),
        CustomBottomNavigation(
            // page: AssistantScreen(),
            page: AiAssistantPage(
              searchKeyword: "...",
            ),
            title: 'Vega',
            icon: Icon(
              Icons.track_changes,
            ),
            svgIcon: 'assets/img/karma_yogi.svg',
            unselectedSvgIcon: 'assets/img/karma_yogi_grey.svg',
            index: 2),
        CustomBottomNavigation(
            page: NotificationScreen(),
            title: 'Notifications',
            icon: Icon(
              Icons.notifications,
            ),
            svgIcon: 'assets/img/notifications_blue.svg',
            unselectedSvgIcon: 'assets/img/notifications.svg',
            index: 3),
        CustomBottomNavigation(
            page: TextSearchPage(),
            title: EnglishLang.search,
            icon: Icon(
              Icons.search,
            ),
            svgIcon: 'assets/img/search_icon.svg',
            unselectedSvgIcon: 'assets/img/grid.svg',
            index: 4),
        CustomBottomNavigation(
            page: ProfileScreen(),
            title: 'Profile',
            icon: Icon(
              Icons.account_circle,
            ),
            svgIcon: 'assets/img/account_box_blue.svg',
            unselectedSvgIcon: 'assets/img/account_box.svg',
            index: 5)
      ];

  static List<CustomBottomNavigation> itemsWithVegaDisabled(
      {@required BuildContext context}) {
    return [
      CustomBottomNavigation(
          page: HomeScreen(),
          title: AppLocalizations.of(context).mStaticHome,
          icon: Icon(
            Icons.home,
          ),
          svgIcon: 'assets/img/kb_home_icon.svg',
          unselectedSvgIcon: 'assets/img/kb_home_icon.svg',
          index: 0,
          telemetryId: TelemetryIdentifier.home),
      CustomBottomNavigation(
          page: HubScreen(),
          title: AppLocalizations.of(context).mStaticExplore,
          icon: Icon(
            Icons.apps,
          ),
          svgIcon: 'assets/img/grid_blue.svg',
          unselectedSvgIcon: 'assets/img/grid.svg',
          index: 1,
          telemetryId: TelemetryIdentifier.explore),
      CustomBottomNavigation(
          page: TextSearchPage(),
          title: AppLocalizations.of(context).mStaticSearch,
          icon: Icon(
            Icons.search,
          ),
          svgIcon: 'assets/img/search_selected.svg',
          unselectedSvgIcon: 'assets/img/search_icon.svg',
          index: 2,
          telemetryId: TelemetryIdentifier.search),
      CustomBottomNavigation(
          page: ProfileScreen(),
          title: AppLocalizations.of(context).mStaticMyLearning,
          icon: Icon(
            Icons.account_circle,
          ),
          svgIcon: 'assets/img/learn_active.svg',
          unselectedSvgIcon: 'assets/img/learn_inactive.svg',
          index: 3,
          telemetryId: TelemetryIdentifier.myLearnings)
    ];
  }
}
