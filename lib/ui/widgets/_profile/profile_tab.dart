import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './../../../localization/index.dart';

class ProfileTab {
  final String title;

  ProfileTab({
    this.title,
  });

  static List<ProfileTab> items({BuildContext context}) => [
        ProfileTab(
          title: AppLocalizations.of(context).mStaticProfile,
        ),
        ProfileTab(
          title: AppLocalizations.of(context).mStaticMyActivities,
        ),
        ProfileTab(
          title: AppLocalizations.of(context).mStaticMyDiscussions,
        ),
        ProfileTab(
          title: AppLocalizations.of(context).mStaticSavedPosts,
        ),
      ];
}
