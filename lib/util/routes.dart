import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/oAuth2_login.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/gyaan_karmayogi.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/career_hub.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_passbook_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_passbook_tabbed_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_theme_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/events_hub.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/interests_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/onboarding_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/welcome_screen.dart';
import '../models/_arguments/index.dart';
import '../models/_models/competency_data_model.dart';
import './../feedback/constants.dart';
import './../feedback/pages/_pages/_microSurvey/survey_details.dart';
// import './../login.dart';
import './../ui/pages/index.dart';
import './../ui/screens/index.dart';
import './../feedback/pages/_pages/_microSurvey/micro_surveys_page.dart';
import './../constants/index.dart';
import './faderoute.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      // final Map<String, dynamic> args = routeSettings.arguments;

      switch (routeSettings.name) {
        // case AppUrl.loginPage:
        //   return MaterialPageRoute(
        //       settings: routeSettings, builder: (_) => Login());
        case AppUrl.loginPage:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => OAuth2Login());

        case AppUrl.onboardingScreen:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => OnboardingScreen());

        case NotificationScreen.route:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => NotificationScreen());

        case ProfileScreen.route:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => ProfileScreen());

        case AssistantScreen.route:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => AssistantScreen());

        case HomePage.route:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => HomePage());

        // case AppUrl.discussionHub:
        //   return MaterialPageRoute(
        //     settings: routeSettings,
        //     builder: (_) => DiscussionHub(),
        //   );

        // case AppUrl.networkHub:
        //   return MaterialPageRoute(
        //     settings: routeSettings,
        //     builder: (_) => NetworkHub(),
        //   );

        // case AppUrl.learningHub:
        //   return MaterialPageRoute(
        //     settings: routeSettings,
        //     builder: (_) => LearningHub(),
        //   );

        case AppUrl.discussionHub:
          return FadeRoute(
              page: DiscussionHub(), routeName: AppUrl.discussionHub);

        case AppUrl.competencyHub:
          return FadeRoute(
              page: CompetencyHub(), routeName: AppUrl.competencyHub);

        case AppUrl.browseByCompetencyPage:
          return FadeRoute(
              page: BrowseByCompetency(),
              routeName: AppUrl.browseByCompetencyPage);

        case AppUrl.browseByProviderPage:
          return FadeRoute(
              page: BrowseByProvider(), routeName: AppUrl.browseByProviderPage);

        case AppUrl.browseByTopicPage:
          return FadeRoute(
              page: BrowseByTopic(), routeName: AppUrl.browseByTopicPage);

        case AppUrl.curatedCollectionsPage:
          return FadeRoute(
              page: BrowseByProvider(
                isCollections: true,
              ),
              routeName: AppUrl.browseByTopicPage);

        case AppUrl.moderatedCoursesPage:
          return FadeRoute(
              page: TrendingCoursesPage(
                  selectedContentType: EnglishLang.moderatedCourse,
                  isModerated: true,
                  title: EnglishLang.moderatedCourse),
              routeName: AppUrl.moderatedCoursesPage);

        // case AppUrl.coursesInCompetency:
        //   return FadeRoute(
        //       page: CoursesInCompetency(),
        //       routeName: AppUrl.coursesInCompetency);

        case AppUrl.learningHub:
          return FadeRoute(page: LearningHub(), routeName: AppUrl.learningHub);

        case AppUrl.networkHub:
          return FadeRoute(page: NetworkHub(), routeName: AppUrl.networkHub);

        case AppUrl.careersHub:
          return FadeRoute(page: CareerHub(), routeName: AppUrl.careersHub);

        case AppUrl.eventsHub:
          return FadeRoute(page: EventsHub(), routeName: AppUrl.eventsHub);

        case AppUrl.knowledgeResourcesPage:
          return FadeRoute(page: GyaanKarmayogi());

        case AppUrl.competencyPassbookPage:
          return FadeRoute(page: CompetencyPassbookScreen());

        case AppUrl.competencyPassbookThemePage:
          return MaterialPageRoute(
              settings: routeSettings,
              builder: (_) => CompetencyThemeScreen(
                    competencyTheme: CompetencyTheme(),
                  ));

        case AppUrl.competencyPassbookTabbedPage:
          return MaterialPageRoute(
              settings: routeSettings,
              builder: (_) => CompetencyPassbookTabbedScreen(competency: {}));

        case DashboardScreen.route:
          return FadeRoute(page: DashboardScreen());

        case SettingsScreen.route:
          return FadeRoute(page: SettingsScreen());

        case MicroSurveysScreen.route:
          return FadeRoute(page: MicroSurveysScreen());

        case InterestsScreen.route:
          return FadeRoute(page: WelcomeScreen());

        case SurveyDetailsPage.route:
          return FadeRoute(
              page: SurveyDetailsPage(MicroSurveyType.microSurveyType1));

        // case AppUrl.careersPage:
        //   return MaterialPageRoute(
        //     settings: routeSettings,
        //     builder: (_) => GenericScreen(
        //       pageContent: CareersPage(),
        //       pageTitle: 'Careers',
        //       pageIcon: Icon(
        //         Icons.business_center_rounded,
        //         color: Color.fromRGBO(0, 116, 182, 1),
        //       ),
        //     ),
        //   );

        case AppUrl.competenciesPage:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => GenericScreen(
              pageContent: CompentenciesPage(),
              pageTitle: 'Competencies',
              pageIcon: Icon(
                Icons.extension_rounded,
                color: Color.fromRGBO(0, 116, 182, 1),
              ),
            ),
          );

        case AppUrl.networkHomePage:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => GenericScreen(
              pageContent: NetworkHomePage(),
              pageTitle: 'Network',
              pageIcon: Icon(
                Icons.supervisor_account,
                color: Color.fromRGBO(0, 116, 182, 1),
              ),
            ),
          );

        case AppUrl.courseTocPage:
          final CourseTocModel arguments =
              routeSettings.arguments as CourseTocModel;

          return FadeRoute(
              page: CourseTocPage(
                arguments: arguments,
              ),
              routeName: AppUrl.courseTocPage);

          case AppUrl.tocPlayer:
          final TocPlayerModel arguments = routeSettings.arguments as TocPlayerModel;
          return FadeRoute(
              page: TocPlayerScreen(arguments: arguments,),
              routeName: AppUrl.courseTocPage);


        default:
          return errorRoute(routeSettings);
      }
    } catch (_) {
      return errorRoute(routeSettings);
    }
  }

  static Route<dynamic> errorRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(
        settings: routeSettings, builder: (_) => ErrorScreen());
  }
}
