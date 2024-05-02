import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyLearnMainTab {
  final String title;

  MyLearnMainTab({
    this.title,
  });

  static List<MyLearnMainTab> items({@required BuildContext context}) => [
        MyLearnMainTab(title: AppLocalizations.of(context).mStaticInprogress
            // 'In Progress',
            ),
        MyLearnMainTab(
          title: AppLocalizations.of(context).mStaticCompleted,
        )
      ];
}
