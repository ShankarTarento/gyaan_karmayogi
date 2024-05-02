import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearnTab {
  final String title;
  static String overview = 'Overview';
  static String discussion = 'Discussion';
  static String content = 'Content';
  static String session = 'Session';
  static String about = 'About';
  LearnTab({
    this.title,
  });

  static List<LearnTab> items({@required BuildContext context}) => [
        LearnTab(
          title: AppLocalizations.of(context).mLearnTabOverview,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseContent,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseDiscussion,
        ),
      ];

  static List<LearnTab> majorItems({@required BuildContext context}) => [
        LearnTab(
          title: AppLocalizations.of(context).mLearnTabOverview,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseContent,
        ),
      ];
  static List<LearnTab> standaloneAssessmentItems(
          {@required BuildContext context}) =>
      [
        LearnTab(
          title: AppLocalizations.of(context).mLearnTabOverview,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseContent,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseDiscussion,
        ),
      ];
  static List<LearnTab> blendedProgramItems({@required BuildContext context}) =>
      [
        LearnTab(
          title: AppLocalizations.of(context).mLearnTabOverview,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseContent,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseSessions,
        ),
        LearnTab(
          title: AppLocalizations.of(context).mLearnCourseDiscussion,
        ),
      ];
  static List<LearnTab> tocTabs(BuildContext context) => [
        LearnTab(title: AppLocalizations.of(context).mStaticAbout),
        LearnTab(title: AppLocalizations.of(context).mLearnCourseContent)
      ];
}
