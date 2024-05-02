import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
// import 'package:karmayogi_mobile/env/env.dart';
// import '../../feedback/constants.dart';
// import './../../constants/_constants/app_routes.dart';
import '../../models/index.dart';
import './../../localization/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<Hub> HUBS({@required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context).mStaticLearn,
          description: AppLocalizations.of(context).mStaticLearnSubtitle,
          icon: Icons.school_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.learningHub,
          svgIcon: 'assets/img/learn_active.svg',
          svg: true,
          telemetryId: 'learn'),
      Hub(
          id: 2,
          title: AppLocalizations.of(context).mStaticDiscuss,
          description: AppLocalizations.of(context).mStaticDiscussSubtitle,
          icon: Icons.forum,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.discussionHub,
          svgIcon: 'assets/img/discuss_icon.svg',
          svg: true,
          telemetryId: 'discuss'),
      Hub(
          id: 3,
          title: AppLocalizations.of(context).mCommonGyannKarmayogi,
          description:
              AppLocalizations.of(context).mStaticKnowledgeResourcesSubtitle,
          icon: Icons.menu_book,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.knowledgeResourcesPage,
          svgIcon: '',
          svg: false,
          telemetryId: 'gyan-karmayogi'),
      Hub(
          id: 4,
          title: AppLocalizations.of(context).mStaticNetwork,
          description: AppLocalizations.of(context).mStaticNetworkSubtitle,
          icon: Icons.supervisor_account,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.networkHub,
          svgIcon: 'assets/img/network_icon.svg',
          svg: true,
          telemetryId: 'network'
          // url: AppUrl.comingSoonPage,
          ),
      Hub(
          id: 6,
          title: AppLocalizations.of(context).mStaticEvents,
          description: AppLocalizations.of(context).mStaticEventsSubtitle,
          icon: Icons.extension_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          // url: AppUrl.competenciesPage,
          url: AppUrl.eventsHub,
          svgIcon: 'assets/img/events_icon.svg',
          svg: true,
          telemetryId: 'events'),
      // Hub(
      //   id: 6,
      //   title: 'My Profile',
      //   description: 'Discuss',
      //   icon: Icons.face,
      //   iconColor: Color.fromRGBO(0, 116, 182, 1),
      //   url: '/profilePage',
      // ),
    ];

List<Hub> DO_MORE({@required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context).mStaticlearningHistory,
          description: AppLocalizations.of(context).mStaticCheckPassbook,
          icon: Icons.menu_book_rounded,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: AppUrl.competencyPassbookPage,
          svgIcon: 'assets/img/competency_passbook.svg',
          svgColor: Color.fromRGBO(0, 0, 0, 0.6),
          svg: true,
          telemetryId: 'learning-history'),
      Hub(
          id: 2,
          title: AppLocalizations.of(context).mStaticSettings,
          description: AppLocalizations.of(context).mStaticSettingsSubtitle,
          icon: Icons.settings,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: AppUrl.settingsPage,
          svgIcon: 'assets/img/Discuss.svg',
          svg: false,
          telemetryId: 'settings'),
      // Hub(
      //     id: 1,
      //     title: EnglishLang.gyanKarmayogi,
      //     description: EnglishLang.knowledgeResourcesSubtitle,
      //     icon: Icons.menu_book,
      //     iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      //     comingSoon: false,
      //     url: AppUrl.knowledgeResourcesPage,
      //     svgIcon: 'assets/img/Discuss.svg',
      //     svg: false),
      // Hub(
      //     id: 2,
      //     title: EnglishLang.dashboard,
      //     description: EnglishLang.dashboardSubtitle,
      //     icon: Icons.bar_chart_outlined,
      //     iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      //     comingSoon: false,
      //     url: AppUrl.dashboardPage,
      //     svgIcon: 'assets/img/Discuss.svg',
      //     svg: false),
      // Hub(
      //     id: 3,
      //     title: EnglishLang.microSurveys,
      //     description: EnglishLang.microSurveysSubtitle,
      //     icon: Icons.book,
      //     iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      //     comingSoon: false,
      //     url: FeedbackPageRoute.surveyDetails,
      //     svgIcon: 'assets/img/Discuss.svg',
      //     svg: false
      //     // url: FeedbackPageRoute.surveyDetails,
      //     ),
      // Hub(
      //     id: 2,
      //     title: EnglishLang.interests,
      //     description: EnglishLang.interestsSubtitle,
      //     icon: Icons.thumb_up,
      //     iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      //     comingSoon: false,
      //     url: AppUrl.interestsPage,
      //     svgIcon: 'assets/img/Discuss.svg',
      //     svg: false),
    ];

List<Hub> COMING_SOON({@required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context).mStaticCareers,
          description: AppLocalizations.of(context).mStaticCareersSubtitle,
          icon: Icons.business_center_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: true,
          url: AppUrl.careersHub,
          // url: AppUrl.comingSoonPage,
          svgIcon: 'assets/img/career_icon.svg',
          svg: true,
          telemetryId: 'career'),
      Hub(
          id: 2,
          title: AppLocalizations.of(context).mLearnCourseCompetency,
          description: AppLocalizations.of(context).mStaticCompetenciesSubtitle,
          icon: Icons.extension_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: true,
          // url: AppUrl.competenciesPage,
          url: AppUrl.competencyHub,
          svgIcon: 'assets/img/competency_icon.svg',
          svg: true,
          telemetryId: 'competency'),
    ];

// ignore: non_constant_identifier_names
final EXTERNAL_LINKS = [
  // Hub(
  //   id: 1,
  //   title: EnglishLang.fracDictionary,
  //   description: EnglishLang.fracDictionarySubtitle,
  //   icon: 'assets/img/igot_icon.png',
  //   iconColor: Color.fromRGBO(246, 153, 83, 1),
  //   url: Env.fracDictionaryUrl,
  // ),
  Hub(
      id: 1,
      title: EnglishLang.karmayogiWebPortal,
      description: EnglishLang.karmayogiWebPortalSubtitle,
      icon: 'assets/img/Karmayogi_bharat_logo_horizontal.png',
      iconColor: Color.fromRGBO(246, 153, 83, 1),
      url: AppUrl.webAppUrl),
  // Hub(
  //   id: 1,
  //   title: 'Give feedback',
  //   description: 'Responsive web version of Karmayogi Bharat.',
  //   icon: 'assets/img/round_feedback.png',
  //   iconColor: Color.fromRGBO(246, 153, 83, 1),
  //   url: '',
  // ),
];

const DASHBOARD_HUBS = const [
  Hub(
    id: 1,
    title: EnglishLang.discussions,
    description: '',
    icon: Icons.forum,
    iconColor: Color.fromRGBO(0, 0, 0, 0.6),
  ),
  Hub(
    id: 2,
    title: EnglishLang.connections,
    description: '',
    icon: Icons.supervisor_account,
    iconColor: Color.fromRGBO(0, 0, 0, 0.6),
  ),
  Hub(
    id: 2,
    title: EnglishLang.karmaPoints,
    description: '',
    icon: Icons.history_rounded,
    iconColor: Color.fromRGBO(0, 0, 0, 0.6),
  ),
];

const AT_A_GLANCE = const [
  Hub(
      id: 1,
      title: EnglishLang.courses,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 14,
      svgIcon: 'assets/img/video.svg'),
  Hub(
      id: 2,
      title: EnglishLang.discussions,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 111,
      svgIcon: 'assets/img/Discuss.svg'),
  Hub(
      id: 3,
      title: EnglishLang.competencies,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 25,
      svgIcon: 'assets/img/competencies.svg'),
  Hub(
      id: 4,
      title: EnglishLang.connections,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 23,
      svgIcon: 'assets/img/Network.svg'),
  Hub(
      id: 5,
      title: EnglishLang.coinsSpent,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 540,
      svgIcon: 'assets/img/Coin.svg'),
  Hub(
      id: 6,
      title: EnglishLang.karmaEarned,
      description: '',
      icon: null,
      iconColor: Color.fromRGBO(0, 0, 0, 0.6),
      points: 48,
      svgIcon: 'assets/img/Karma.svg'),
];
