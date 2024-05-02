import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './../../../localization/index.dart';

class DiscussionTab {
  final String title;

  DiscussionTab({
    this.title,
  });

  static List<DiscussionTab> items({@required BuildContext context}) => [
        DiscussionTab(
          title: AppLocalizations.of(context).mDiscussSubTabAllDiscussions,
        ),
        DiscussionTab(
          title: AppLocalizations.of(context).mStaticCategories,
        ),
        DiscussionTab(
          title: AppLocalizations.of(context).mDiscussSubTabTags,
        ),
        DiscussionTab(
            title: AppLocalizations.of(context).mDiscussSubTabYourDiscussions),
      ];
}
