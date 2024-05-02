import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../localization/_langs/english_lang.dart';

class LocalizationText {
  String displayText;
  String value;
  LocalizationText({@required this.displayText, @required this.value});

  static List<LocalizationText> getGenders({@required BuildContext context}) {
    return [
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileMale,
          value: "Male"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileFemale,
          value: "Female"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileOther,
          value: "Others"),
    ];
  }

  static List<LocalizationText> getMaritalStatus(
      {@required BuildContext context}) {
    return [
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileSingle,
          value: "Single"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileMarried,
          value: "Married"),
    ];
  }

  static List<LocalizationText> getCategoryStatus(
      {@required BuildContext context}) {
    return [
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileGeneral,
          value: "General"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileOBC, value: "OBC"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileSC, value: "SC"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mProfileST, value: "ST"),
    ];
  }

  static List<LocalizationText> getOrganisationType(
      {@required BuildContext context}) {
    return [
      LocalizationText(
          displayText: AppLocalizations.of(context).mStaticGovernment,
          value: "Government"),
      LocalizationText(
          displayText: AppLocalizations.of(context).mStaticNonGovernment,
          value: "Non-Government"),
    ];
  }

  static List<LocalizationText> getDiscussHubFilterDropdown(
      {@required BuildContext context}) {
    return [
      LocalizationText(
        displayText: AppLocalizations.of(context).mDiscussRecent,
        value: EnglishLang.recent,
      ),
      LocalizationText(
          displayText:
              AppLocalizations.of(context).mDiscussLabelAllDiscussionPopular,
          value: EnglishLang.popular),
    ];
  }

  static List<LocalizationText> getDiscussHubYourDiscussionFilterDropdown(
      {@required BuildContext context}) {
    return [
      LocalizationText(
        displayText: AppLocalizations.of(context).mStaticRecentPosts,
        value: EnglishLang.recentPosts,
      ),
      LocalizationText(
          displayText: AppLocalizations.of(context).mDiscussBestPosts,
          value: EnglishLang.bestPosts),
      LocalizationText(
        displayText: AppLocalizations.of(context).mDiscussSavedPosts,
        value: EnglishLang.savedPosts,
      ),
      LocalizationText(
          displayText: AppLocalizations.of(context).mDiscussUpVoted,
          value: EnglishLang.upvoted),
      LocalizationText(
          displayText: AppLocalizations.of(context).mDiscussDownVoted,
          value: EnglishLang.downvoted),
    ];
  }

  static List<LocalizationText> getNetworkConnectionRequestFilter(
      {@required BuildContext context}) {
    return [
      LocalizationText(
        displayText: AppLocalizations.of(context).mStaticLastAdded,
        value: EnglishLang.lastAdded,
      ),
      LocalizationText(
          displayText: AppLocalizations.of(context).mStaticSortByName,
          value: EnglishLang.sortByName),
    ];
  }

  static List<LocalizationText> getCareerHubFilterDropdown(
      {@required BuildContext context}) {
    return [
      LocalizationText(
        displayText: AppLocalizations.of(context).mDiscussRecent,
        value: EnglishLang.recent,
      ),
      LocalizationText(
          displayText: AppLocalizations.of(context).mStaticMostViewed,
          value: EnglishLang.mostViewed),
    ];
  }

  static List<LocalizationText> getEventsHubFilterDropdown(
      {@required BuildContext context}) {
    return [
      LocalizationText(
        displayText: AppLocalizations.of(context).mCommonAll,
        value: EnglishLang.all,
      ),
      LocalizationText(
        displayText: AppLocalizations.of(context).mStaticHostedByMyMDO,
        value: EnglishLang.hostedByMyMDO,
      ),
      LocalizationText(
        displayText: AppLocalizations.of(context).mEventsTabCuratedEvents,
        value: EnglishLang.curatedEvents,
      ),
    ];
  }
}
