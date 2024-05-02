import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssistantTab {
  final String title;
  final int tabNumber;

  AssistantTab({this.title, this.tabNumber});

  static List<AssistantTab> items({@required BuildContext context}) => [
        AssistantTab(
            title: AppLocalizations.of(context).mCommonAll, tabNumber: 1),
        AssistantTab(
            title: AppLocalizations.of(context).mStaticNetwork, tabNumber: 2),
        AssistantTab(
            title: AppLocalizations.of(context).mStaticDiscuss, tabNumber: 3),
        AssistantTab(
            title: AppLocalizations.of(context).mStaticLearn, tabNumber: 4),
        AssistantTab(
            title: AppLocalizations.of(context).mStaticCareers, tabNumber: 5),
      ];
}
