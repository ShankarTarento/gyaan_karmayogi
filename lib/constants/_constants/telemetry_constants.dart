class TelemetryEvent {
  static const String start = 'START';
  static const String end = 'END';
  static const String impression = 'IMPRESSION';
  static const String audit = 'AUDIT';
  static const String interact = 'INTERACT';
}

class TelemetryEntity {
  static const String start = 'User';
}

class TelemetryType {
  static const String page = 'Page';
  static const String public = 'Public';
  static const String viewer = 'view';
  static const String player = 'Player';
  static const String app = 'app';
}

class TelemetrySubType {
  static const String courseCard = 'card-courseCard';
  static const String contentCard = 'card-contentCard';
  static const String userCard = 'card-userCard';
  static const String discussionCard = 'card-discussionCard';
  static const String tagCard = 'card-tagCard';
  static const String categoryCard = 'card-categoryCard';
  static const String upVoteIcon = 'icon-upVoteIcon';
  static const String downVoteIcon = 'icon-downVoteIcon';
  static const String bookmarkIcon = 'icon-bookmarkIcon';
  static const String nextPageButton = 'button-nextPageButton';
  static const String previousPageButton = 'button-previousPageButton';
  static const String markAsCompletePageButton =
      'button-markAsCompletePageButton';
  static const String lastPageButton = 'button-lastPageButton';
  static const String firstPageButton = 'button-firstPageButton';
  static const String pauseButton = 'button-pauseButton';
  static const String playButton = 'button-playButton';
  static const String learnSearch = 'card-learnSearch';
  static const String sideMenu = 'side-menu';
  static const String courseTab = 'course_tab';
  static const String competencyTab = 'competency-tab';
  static const String profileEditTab = 'profile-edit-tab';
  static const String platformRatingSubmit = 'platform-rating-submit';
  static const String click = 'click';
  static const String submit = 'submit';
  static const String competencyHome = 'yourCompetencies-menu';
  static const String allCompetencies = 'allCompetencies-menu';
  static const String recommendedTab = 'recommended-tab';
  static const String recommendedFromFracTab = 'recommendedFromFrac-tab';
  static const String recommendedFromWatTab = 'recommendedFromWat-tab';
  static const String addedByYouTab = 'addedByYou-tab';
  static const String overviewTab = 'overview-tab';
  static const String contentTab = 'content-tab';
  static const String discussionTab = 'discussion-tab';
  static const String learnersTab = 'learners-tab';
  static const String personalDetailsTab = 'personalDetails-tab';
  static const String mandatoryDetailsTab = 'mandatoryDetails-tab';
  static const String otherDetailsTab = 'otherDetails-tab';
  static const String eHRMSDetailsTab = 'eHRMSDetails-tab';
  static const String academicsTab = 'academics-tab';
  static const String professionalDetailsTab = 'professionalDetails-tab';
  static const String certificationSkillsTab = 'certificationSkills-tab';
  static const String eventsTab = 'events-tab';
  static const String allTab = 'all-tab';
  static const String hostedByMyMDOTab = 'hostedByMyMdo-tab';
  static const String informationTab = 'information-tab';
  static const String issuesTab = 'issues-tab';
  static const String question = 'question';
  static const String category = 'category';
  static const String languageDropdown = 'language-dropdown';
  static const String inProgress = 'In progress';
  static const String completed = 'Completed';
  static const String profile = 'Profile';
  static const String myActivities = 'My activities';
  static const String yourDiscussions = 'Your discussions';
  static const String savedPosts = 'Saved posts';
  static const String weeklyClaps = 'weekly-claps';
  static const String karmaPoints = 'Karma points';
  static const String karmaPointsShowAll = 'show-all-karmpoints';
  static const String scroll = 'scroll';
  static const String welcome = 'welcome';
  static const String tour = 'tour';
  static const String discuss = 'discuss';
  static const String discussion = 'discussion';
  static const String learn = 'learn';
  static const String myProfile = 'my profile';
  static const String search = 'search';
  static const String finish = 'finish';
  static const String video = 'video';
  static const String hubMenu = 'hub-menu';
  static const String certificate = 'certificate';
  static const String suggestedConnections = 'suggested-connections';
  static const String trendingDiscussions = 'trending-discussions';
  static const String myDiscussions = 'my-discussions';
  static const String blendedProgram = 'blended-program';
  static const String certificationsOfTheWeek = 'certifications-of-the-week';
  static const String learningUnder30Minutes = 'learning-under-30-minutes';
  static const String trendingCoursesInYourDepartment =
      'trending-courses-in-your-department';
  static const String trendingProgramsInYourDepartment =
      'trending-programs-in-your-department';
  static const String trendingCoursesAcrossDepartments =
      'trending-courses-across-departments';
  static const String trendingProgramsAcrossDepartments =
      'trending-programs-across-departments';
  static const String recentlyAdded = 'recently-added';
  static const String recentlyAddedPrograms = 'recently-added-programs';
  static const String recentlyAddedCourses = 'recently-added-courses';
  static const String myLearning = 'my-learning';
  static const String myIgot = 'my-igot';
}

class TelemetryMode {
  static const String view = 'View';
  static const String play = 'Play';
}

class TelemetryPageIdentifier {
  // Homepage
  static const String homePageId = '/home';
  static const String homePageUri = 'page/home';
  // Platform rating
  static const String platformRatingPageId = '/home/platformRating';
  static const String platformRatingPageUri = 'home/platformRating';
  // Hall of fame
  static const String hallOfFamePageId = '/home/hallOfFame';
  static const String hallOfFamePageUri = 'home/hallOfFame';

  // Learn hub
  static const String learnPageId = '/learn';
  static const String learnPageUri = 'page/learn';
  static const String allTopicsPageId = '/app/taxonomy/home';
  static const String allTopicsPageUri = 'app/taxonomy/home';
  static const String allCollectionsPageId = '/app/curatedCollections/home';
  static const String allCollectionsPageUri = 'app/curatedCollections/home';
  static const String topicCoursesPageId = '/app/taxonomy/:topic';
  static const String topicCoursesPageUri = 'app/taxonomy/:topic';
  static const String courseDetailsPageId = '/app/toc/:do_ID/overview';
  static const String courseDetailsPageUri = 'app/toc/:do_ID/overview';
  static const String publicCourseDetailsPageId = '/public/toc/:do_ID/overview';
  static const String publicCourseDetailsPageUri = 'public/toc/:do_ID/overview';
  static const String htmlPlayerPageId = '/viewer/html/:resourceId';
  static const String htmlPlayerPageUri = 'viewer/html/:resourceId';
  static const String pdfPlayerPageId = '/viewer/pdf/:resourceId';
  static const String pdfPlayerPageUri =
      'viewer/pdf/:resourceId?primaryCategory=Learning%20Resource&collectionId=:collectionId&collectionType=Course&batchId=:batchId';
  static const String audioPlayerPageId = '/viewer/audio/:resourceId';
  static const String audioPlayerPageUri =
      'viewer/audio/:resourceId?primaryCategory=Learning%20Resource&collectionId=:collectionId&collectionType=Course&batchId=:batchId';
  static const String videoPlayerPageId = '/viewer/video/:resourceId';
  static const String videoPlayerPageUri =
      'viewer/video/:resourceId?primaryCategory=Learning%20Resource&collectionId=:collectionId&collectionType=Course&batchId=:batchId';
  static const String assessmentPlayerPageId = '/viewer/quiz/:resourceId';
  static const String assessmentPlayerPageUri =
      'viewer/quiz/:resourceId?primaryCategory=Learning%20Resource&collectionId=:collectionId&collectionType=Course&batchId=:batchId';
  static const String youtubePlayerPageId = '/viewer/youtube/:resourceId';
  static const String youtubePlayerPageUri =
      'viewer/youtube/:resourceId?primaryCategory=Learning%20Resource&collectionId=:collectionId&collectionType=Course&batchId=:batchId';
  // Discuss hub
  static const String discussionsPageId = '/app/discussion-forum';
  static const String discussionsPageUri = 'app/discussion-forum?page=home';
  static const String addDiscussionPageId = '/app/discussion-forum/add';
  static const String addDiscussionPageUri = 'app/discussion-forum/add';
  static const String discussionDetailsPageId =
      '/app/discussion-forum/topic/:discussionId/:discussionName';
  static const String discussionDetailsPageUri =
      'app/discussion-forum/topic/:discussionId/:discussionName?page=home';
  static const String categoriesPageId = '/app/discussion-forum/categories';
  static const String categoriesPageUri =
      'app/discussion-forum/categories?page=home';
  static const String filterByCategoryPageId =
      '/app/discussion-forum/category/:categoryId';
  static const String filterByCategoryPageUri =
      'app/discussion-forum/category/:categoryId?page=home';
  static const String tagsPageId = '/app/discussion-forum/tags?page=home';
  static const String tagsPageUri = '/app/discussion-forum/tags?page=home';
  static const String filterByTagsPageId =
      '/app/discussion-forum/all-discussions';
  static const String filterByTagsPageUri =
      'app/discussion-forum/all-discussions?page=home&tagname=:tagName';
  static const String myDiscussionsPageId =
      '/app/discussion-forum/my-discussion';
  static const String myDiscussionsPageUri =
      'app/discussion-forum/my-discussion?page=home';
  // Network hub
  static const String networkHomePageId = '/app/network-v2/home';
  static const String networkHomePageUri = 'app/network-v2/home';
  static const String myConnectionsPageId = '/app/network-v2/my-connection';
  static const String myConnectionsPageUri = 'app/network-v2/my-connection';
  static const String connectionRequestsPageId =
      '/app/network-v2/connection-requests';
  static const String connectionRequestsPageUri =
      'app/network-v2/connection-requests';
  static const String myMdoPageId = '/app/network-v2/my-mdo';
  static const String myMdoPageUri = 'app/network-v2/my-mdo';
  // Competency hub
  static const String competencyHomePageId = '/app/competencies/home';
  static const String competencyHomePageUri = 'app/competencies/home';
  static const String allCompetenciesPageId = '/app/competencies/all/list';
  static const String allCompetenciesPageUri = '/app/competencies/all/list';
  static const String browseByAllCompetenciesPageId =
      '/app/learn/browse-by/competency/all-competencies';
  static const String browseByAllCompetenciesPageUri =
      'app/learn/browse-by/competency/all-competencies';
  static const String browseByCompetencyCoursesPageId =
      '/app/learn/browse-by/competency/:competencyName';
  static const String browseByCompetencyCoursesPageUri =
      'app/learn/browse-by/competency/:competencyName';
  static const String browseByAllProviderPageId =
      '/app/learn/browse-by/provider/all-providers';
  static const String browseByAllProviderPageUri =
      'app/learn/browse-by/provider/all-providers';
  static const String browseByProviderCoursesPageId =
      '/app/learn/browse-by/provider/:providerName/all-CBP';
  static const String browseByProviderCoursesPageUri =
      'app/learn/browse-by/provider/:providerName/all-CBP';
  static const String browseByCollectionCoursesPageId =
      '/app/learn/browse-by/collection/:collectionName/all-CBP';
  static const String browseByCollectionCoursesPageUri =
      'app/learn/browse-by/collection/:collectionName/all-CBP';
  // Career hub
  static const String careerHomePageId = '/app/careers/home';
  static const String careerHomePageUri = 'app/careers/home';
  static const String careerDetailsPageId =
      '/app/careers/home/:topicId/:topicName';
  static const String careerDetailsPageUri =
      'app/careers/home/:topicId/:topicName';

  // Event hub
  static const String eventHomePageId = '/app/event-hub/home';
  static const String eventHomePageUri = 'app/event-hub/home';
  static const String eventDetailsPageId = '/app/event-hub/home/:eventId';
  static const String eventDetailsPageUri = '/app/event-hub/home/:eventId';
  // Profile
  static const String userProfilePageId = '/app/person-profile/:userId';
  static const String userProfilePageUri = 'app/person-profile/:userId';
  static const String myProfilePageId = '/app/person-profile/me';
  static const String myProfilePageUri = 'app/person-profile/me';
  static const String profileSettingsPageId = '/app/profile/settings';
  static const String profileSettingsPageUri = 'app/profile/settings';
  static const String userProfileDetailsPageId = '/app/user-profile/details';
  static const String userProfileDetailsPageUri = 'app/user-profile/details';
  // Search
  static const String globalSearchPageId = '/app/globalsearch';
  static const String globalSearchPageUri = 'app/globalsearch?q=network';
  // Interests
  static const String welcomePageId = '/app/profile-v3/welcome';
  static const String welcomePageUri = 'app/setup/welcome';
  static const String rolesPageId = '/app/profile-v3/roles';
  static const String rolesPageUri = 'app/setup/roles';
  static const String topicsPageId = '/app/profile-v3/topics';
  static const String topicsPageUri = 'app/setup/topics';
  static const String currentCompetenciesPageId =
      '/app/profile-v3/current-competencies';
  static const String currentCompetenciesPageUri =
      'app/setup/current-competencies';
  static const String desiredCompetenciesPageId =
      '/app/profile-v3/desired-competencies';
  static const String desiredCompetenciesPageUri =
      'app/setup/desired-competencies';
  static const String platformWalkThroughPageId =
      '/app/profile-v3/platform-walkthrough';
  static const String platformWalkThroughPageUri =
      'app/setup/platform-walkthrough';

  // get started
  static const String getStartedPageId = '/app/GetStarted/home/';
  static const String getStartedPageUri = '/app/GetStarted/home/started';

  static const String getStartedTourPageId = '/app/GetStarted/hometour/';
  static const String getStartedTourPageUri = '/app/GetStarted/hometour/setup';

  static const String getStartedigotPageId = '/app/GetStarted/homeigot/';
  static const String getStartedigotPageUri = '/app/GetStarted/homeigot/setup';

  static const String getStartedbtnPageId = '/app/GetStarted/homebtn/';
  static const String getStartedbtnPageUri = '/app/GetStarted/homebtn/setup';

  static const String tourVideoPageId =
      '/app/GetStarted/player/home/watchVideo';
  static const String tourVideoPageUri =
      '/app/GetStarted/player/home/setup/watchVideo';

  static const String tourVideoNextPageId = '/app/GetStarted/player/home/next';
  static const String tourVideoNextPageUri =
      '/app/GetStarted/player/home/setup/next';

  static const String tourVideoEndPageId =
      '/app/GetStarted/home/tour/started/video_close';
  static const String tourVideoEndPageUri =
      '/app/GetStarted/home/tour/video_close';

  static const String tourLearnNextPageId =
      '/app/GetStarted/tour/home/next_learn';
  static const String tourLearnNextPageUri =
      '/app/GetStarted/home/setup/tour/next_learn';

  static const String tourDiscussNextPageId =
      '/app/GetStarted/tour/home/next_discuss';
  static const String tourDiscussNextPageUri =
      '/app/GetStarted/home/setup/tour/next_discuss';

  static const String tourSearchNextPageId =
      '/app/GetStarted/tour/home/next_search';
  static const String tourSearchNextPageUri =
      '/app/GetStarted/home/setup/tour/next_search';

  static const String tourProfileNextPageId =
      '/app/GetStarted/home/tour/next_profile';
  static const String tourProfileNextPageUri =
      '/app/GetStarted/home/setup/tour/next_profile';

  static const String tourLearnPreviousPageId =
      '/app/GetStarted/home/tour/previous_learn';
  static const String tourLearnPreviousPageUri =
      '/app/getstarted/setup/tour/previous_learn';

  static const String tourDisucssPreviousPageId =
      '/app/GetStarted/home/tour/previous_discuss';
  static const String tourDisucssPreviousPageUri =
      '/app/GetStarted/home/setup/tour/previous_discuss';

  static const String tourSearchPreviousPageId =
      '/app/GetStarted/home/tour/previous_search';
  static const String tourSearchPreviousPageUri =
      '/app/GetStarted/home/setup/tour/previous_search';

  static const String tourProfilePreviousPageId =
      '/app/GetStarted/home/previous_profile';
  static const String tourProfilePreviousPageUri =
      '/app/GetStarted/home/setup/tour/previous_profile';

  static const String tourLearnClosePageId =
      '/app/GetStarted/home/tour/learn_close';
  static const String tourLearnClosePageUri =
      '/app/GetStarted/home/setup/tour/learn_close';

  static const String tourSearchClosePageId =
      '/app/GetStarted/home/tour/search_close';
  static const String tourSearchClosePageUri =
      '/app/GetStarted/home/setup/tour/search_close';

  static const String tourDiscussClosePageId =
      '/app/GetStarted/home/tour/discuss_close';
  static const String tourDiscussClosePageUri =
      '/app/GetStarted/home/setup/tour/discuss_close';

  static const String tourProfileClosePageUri =
      '/app/GetStarted/home/setup/tour/page_close';

  static const String videoSkipPageUri = '/app/GetStarted/home/player/skip';
  static const String getStartedskipPageUri = '/app/GetStarted/home/skip';

  static const String myLearnings = '/myLearnings';

  //Karma point
  static const String karmaPointPageId = '/app/karmapoints';
  static const String karmaPointPageUri = '/app/karmapoints/appbar';

  static const String karmaPointShowAllPageId =
      '/app/person-profile/me_profileInfo';
  static const String karmaPointShowAllPageUri =
      '/app/person-profile/me_profileInfo';

  static const String karmaPointOverviewPageId =
      '/app/person-profile/karma-points';
  static const String karmaPointOverviewPageUri =
      '/app/person-profile/karma-points';

  //gyaan karmayogi
  static const String gyaanKarmayogiPageId = '/app/gyaan-karmayogi/all';

  static const String gyaanKarmayogiUri = '/app/gyaan-karmayogi/all';

  static const String gyaanKarmayogiViewAll = '/app/gyaan-karmayogi/all';

  static const String gyaanKarmayogiViewAllImpressionPageId =
      '/app/gyaan-karmayogi/view-all?key=';
  static const String gyaanKarmayogiViewAllImpressionPageUri =
      '/app/gyaan-karmayogi/view-all?key=';
  static const String gyaanKarmayogiCardId = "card-content";
  static const String gyaanKarmayogiDetailsId =
      "/app/gyaan-karmayogi/player/:resourceid";
  static const String gyaanKarmayogiDetailsUri = "/app/gyaan-karmayogi/player/";

  // "pageid": "/app/gyaan-karmayogi/player/youtube/:resourceid",
  //   "type": "view",
  //   "uri": "/app/gyaan-karmayogi/player/youtube/do_1140208529751162881885?primaryCategory=Learning%20Resource"
}

class TelemetryIdentifier {
  static const String getStartedTab = 'get-started-tab';
  static const String getStarted = 'get-started';
  static const String welcomeSkip = 'welcome-skip';
  static const String videoSkip = 'video-skip';
  static const String welcomeStart = 'welcome-start';
  static const String tourStart = 'tour-start';
  static const String discussPrevious = 'discuss-previous';
  static const String dicussNext = 'discuss-next';
  static const String learnNext = 'learn-next';
  static const String learnPrevious = 'learn-previous';
  static const String profilePrevious = 'my-profile-previous';
  static const String profileNext = 'my-profile-next';
  static const String searchPrevious = 'search-previous';
  static const String searchNext = 'search-next';
  static const String tourFinish = 'tour-finish';
  static const String tourSkip = 'tour-skip';
  static const String profileIcon = 'profile-icon';
  static const String shareCertificate = 'share-certificate';
  static const String downloadCertificate = 'download-certificate';
  static const String showAll = 'show-all';
  static const String home = 'home';
  static const String explore = 'explore';
  static const String search = 'search';
  static const String myLearnings = 'my-learnings';
  static const String cardContent = 'card-content';
  static const String completedTab = 'completed-tab';
  static const String inProgressTab = 'inProgress-tab';
  static const String allTab = 'all-tab';
  static const String upcomingTab = 'upcoming-tab';
  static const String overdueTab = 'overdue-tab';
  static const String aboutTab = 'about-tab';
  static const String contentTab = 'content-tab';
  static const String profileUpdateProgress = 'profile-update-progress';
  static const String weeklyClapsInfo = 'weekly-claps-info';
}

class TelemetryEnv {
  static const String home = 'Home';
  static const String competency = 'Competency';
  static const String discuss = 'Discuss';
  static const String events = 'Events';
  static const String profile = 'Profile';
  static const String learn = 'Learn';
  static const String network = 'Network';
  static const String explore = 'Explore';
  static const String getStarted = 'Get Started';
  static const String platformRating = 'Platform Rating';
}

class TelemetryConstants {
  // Home side menu
  static const String shareApplication = 'share-application';
  static const String viewProfile = 'view-profile';
  static const String rateNow = 'rate-now';
  static const String signout = 'signout';

  // Rate app popup on weekly claps
  static const String mayBeLater = 'may-be-later';
}

class TelemetryObjectType {
  static const String user = 'User';
  static const String certificate = 'Certificate';
}
