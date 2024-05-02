import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import './../../models/index.dart';
import './../../localization/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<BrowseBy> BROWSEBY({@required BuildContext context}) => [
      // BrowseBy(
      //     id: 1,
      //     title: EnglishLang.exploreByTopic,
      //     description: EnglishLang.browseTopics,
      //     comingSoon: false,
      //     svgImage: 'assets/img/browse-by-topic.svg',
      //     url: AppUrl.browseByTopicPage),
      BrowseBy(
          id: 1,
          title: AppLocalizations.of(context).mStaticExploreByCompetency,
          description: AppLocalizations.of(context).mStaticBrowseCompetency,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-competency.svg',
          url: AppUrl.browseByCompetencyPage),
      BrowseBy(
          id: 2,
          title: AppLocalizations.of(context).mStaticExploreByProvider,
          description: AppLocalizations.of(context).mStaticBrowseProvider,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-provider.svg',
          url: AppUrl.browseByProviderPage),
      BrowseBy(
          id: 3,
          title: AppLocalizations.of(context).mStaticCuratedCollections,
          description:
              AppLocalizations.of(context).mStaticBrowseCuratedCollections,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-provider.svg',
          url: AppUrl.curatedCollectionsPage),
      BrowseBy(
          id: 4,
          title: AppLocalizations.of(context).mCommonModeratedCourses,
          description:
              AppLocalizations.of(context).mStaticBrowseModeratedCourses,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-topic.svg',
          url: AppUrl.moderatedCoursesPage),
    ];
