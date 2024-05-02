import 'package:karmayogi_mobile/env/env.dart';

class ApiUrl {
  // Mocky
  // static const tempBaseUrl = 'https://run.mocky.io/v3/';

  static String baseUrl = Env.portalBaseUrl;
  static String fracBaseUrl = Env.fracBaseUrl;
  static String apiKey = Env.apiKey;

  // Login
  static String loginRedirectUrl = '$baseUrl/oauth2callback';
  // static const loginRedirectUrl = 'https://igot-stage.in/oauth2callback';

  static String parichayBaseUrl = Env.parichayBaseUrl;
  static String preProdBaseUrl = 'https://karmayogi.nic.in';
  static String revokeToken = '/pnv1/salt/api/oauth2/revoke';

  static String parichayAuthLoginUrl = '$parichayBaseUrl/pnv1/oauth2/authorize';
  static String parichayLoginRedirectUrl =
      '$baseUrl/apis/public/v8/parichay/callback';

  static String loginWebUrl = '$baseUrl/auth';
  static String signUpWebUrl = '$baseUrl/public/signup';
  static String loginShortUrl =
      '/auth/realms/sunbird/protocol/openid-connect/auth';
  static String loginUrl =
      '/auth/realms/sunbird/protocol/openid-connect/auth?redirect_uri=$loginRedirectUrl&response_type=code&scope=offline_access&client_id=android';
  static const keyCloakLogin =
      '/auth/realms/sunbird/protocol/openid-connect/token';
  static const keyCloakLogout =
      '/auth/realms/sunbird/protocol/openid-connect/logout';
  static const getParichayToken = '/pnv1/salt/api/oauth2/token';
  // pnv1/salt/api/oauth2/token'
  static const refreshToken = '/api/auth/v1/refresh/token';
  static const createNodeBBSession = '/api/discussion/user/v1/create';
  // static const basicUserInfo = '/api/user/v2/read/';
  static const basicUserInfo = '/api/user/v5/read/';
  static const getUserDetails = '/api/private/user/v1/search';
  static const getParichayUserInfo = '/pnv1/salt/api/oauth2/userdetails';
  static const updateLogin = '/api/user/v1/updateLogin';
  static const signUp = '/api/user/v1/ext/signup';
  static const privacyPolicy = '/public/privacy-policy?mode=mobile';

  // Not in use
  static const wToken = '/apis/proxies/v8/api/user/v2/read';

  // Nps rating APIs
  static const getFormId = '/api/forms/getFormById?id=';
  static const getFormFeed = '/api/user/v1/feed/';
  static const submitForm = '/api/forms/v1/saveFormSubmit';
  static const deleteFeed = '/api/user/feed/v1/delete';

  // Discussion hub new
  static const trendingDiscussion = '/api/discussion/popular?page=';
  static const recentDiscussion = '/api/discussion/recent';
  static const trendingTags = '/api/discussion/tags';
  static const discussionDetail = '/api/discussion/topic/';
  static const categoryList = '/api/discussion/categories';
  static const myDiscussions = '/api/discussion/user/';
  static const filterDiscussionsByTag = '/api/discussion/tags/';
  static const courseDiscussions = '/api/discussion/forum/v2/read';
  static const courseDiscussionList = '/api/discussion/category/list';

  // Post APIs currently not working
  static const replyDiscussion = '/api/discussion/v2/topics/';
  static const saveDiscussion = '/api/discussion/v2/topics';
  static const deleteDiscussion = '/api/discussion/v2/topics/';
  static const vote = '/api/discussion/v2/posts/';
  static const savedPosts = '/api/discussion/user/';
  static const bookmark = '/api/discussion/v2/posts/';
  static const updatePost = '/api/discussion/v2/posts/';
  static const filterDiscussionsByCategory = '/api/discussion/category/';

  // APIs not provided yet
  static const getCareerOpenings = '/api/discussion/category/1';
  static const getCareers = '/api/nodebb/api/category/1';

  /// Network hub new
  static const getSuggestions = '/api/connections/profile/find/recommended';

  // Network hub

  static const getProfileDetails =
      '/apis/protected/v8/user/profileRegistry/getUserRegistryById';
  static const getProfileMandatoryFields =
      '/api/data/v1/system/settings/get/mandatoryProfileFields';
  static const getProfileDetailsByUserId = '/api/user/v1/read/';
  static const updateProfileDetailsWithoutPatch = '/api/user/private/v1/update';
  static const updateProfileDetails = '/api/user/v1/extPatch';
  static const updateProfileDetailsV2 = '/api/user/otp/v2/extPatch';
  static const generateOTP = '/api/otp/v1/generate';
  static const generateOTPv3 = '/api/otp/v3/generate';
  static const verifyOTP = '/api/otp/v1/verify';
  static const verifyOTPv3 = '/api/otp/v3/verify';
  static const getInReviewFields = '/api/workflow/getUserWFApplicationFields';
  // static const updateUserProfileDetails =
  //     '/apis/protected/v8/user/profileDetails/updateUser';
  static const getCurrentCourse =
      '/apis/protected/v8/content/lex_auth_013125450758234112286?hierarchyType=detail';
  static const getBadges = '/apis/protected/v8/user/badge';
  static const getNationalities = '/assets/static-data/nationality.json';
  static const getCuratedHomeConfig =
      '/assets/configurations/feature/curated-home.json';
  static const getLearnHubConfig = '/assets/configurations/page/learn.json';
  static const getHomeConfig = '/assets/configurations/page/home.json';
  static const getMasterCompetencies =
      '/assets/common/master-competencies.json';
  static const getSurveyForm = '/api/forms/getFormById?id=';
  static const getProfileEditConfig =
      '/assets/configurations/feature/edit-profile.json';
  static const getLanguages = '/api/masterData/v1/languages';
  static const getProfilePageMeta = '/api/masterData/v1/profilePageMetaData';
  static const getDepartments = '/api/portal/v1/listDeptNames';
  static const getDegrees = '/assets/static-data/degrees.json';
  static const getIndustries = '/assets/static-data/industries.json';
  static const getDesignationsAndGradePay = '/api/user/v1/positions';
  static const getEhrmsDetails = '/api/ehrms/details';
  static const getServicesAndCadre = '/assets/static-data/govtOrg.json';
  static const getCadre = '/api/masterData/v1/profilePageMetaData';
  static const autoEnrollBatch = '/api/v1/autoenrollment';
  static const enrollProgramBatch = '/api/openprogram/v1/enrol';
  static const requestBlendedProgramBatchCountUrl =
      '/api/workflow/blendedprogram/enrol/status/count';
  static const requestBlendedProgramEnrollUrl =
      '/api/workflow/blendedprogram/enrol';
  static const requestBlendedProgramUnenroll =
      '/api/workflow/blendedprogram/unenrol';
  static const workflowBlendedProgramSearch =
      '/api/workflow/blendedprogram/user/search';
  static const getEnrollDetails = '/api/user/autoenrollment/';
  static const submitBlendedProgramSurvey = '/api/forms/v1/saveFormSubmit';
  static const enrollToCuratedProgram = '/api/curatedprogram/v1/enrol';
  static const getInsights = '/api/insights';

  /// learner leaderboard
  static const getLeaderboardData = '/api/halloffame/learnerleaderboard';

  // Network hub
  static const peopleYouMayKnow = '/api/connections/profile/find/suggests';
  static const connectionRequest =
      '/api/connections/profile/fetch/requests/received';

  static const postConnectionReq = '/api/connections/add';
  static const getMyConnections = '/api/connections/profile/fetch/established';
  static const connectionRejectAccept = '/api/connections/update';
  static const fromMyMDO = '/api/connections/profile/find/recommended';
  static const getUsersByEndpoint = '/api/user/v1/search';
  static const getUsersByText = '/api/user/v1/autocomplete/';
  static const getRequestedConnections =
      '/api/connections/profile/fetch/requested';

  // Notifications
  static const notifications =
      '/apis/protected/v8/user/notifications?classification=Information&size=10';
  static const notificationsCount =
      '/apis/protected/v8/user/iconBadge/unseenNotificationCount';
  static const markReadNotifications = '/apis/protected/v8/user/notifications';
  static const notificationPreferenceSettings =
      '/api/data/v1/system/settings/get/notificationPreference';
  static const userNotificationPreference =
      '/api/user/v1/notificationPreference';
  static const markReadNotification = '/apis/protected/v8/user/notifications/';

  // Knowledge Resources
  static const getKnowledgeResources =
      '/fracapis/frac/getAllNodes?type=KNOWLEDGERESOURCE&bookmarks=true';
  static const bookmarkKnowledgeResource = '/fracapis/frac/bookmarkDataNode';
  static const getKnowledgeResourcesPositions =
      '/fracapis/frac/getAllNodes?type=POSITION';
  static const knowledgeResourcesFilterByPosition =
      '/fracapis/frac/filterByMappings';

  // Learn
  static const getListOfCompetencies = '/fracapis/frac/searchNodes';
  static const getAllCompetencies = '/api/searchBy/competency';
  static const getCoursesByCompetencies = '/api/content/v1/search';
  static const getTrendingCourses = '/api/composite/v1/search';
  static const getTrendingCoursesV4 = '/api/composite/v4/search';
  static const getCoursesByCollection = 'api/v8/action/content/v3/hierarchy/';
  static const getContinueLearningCourses =
      '/api/course/v2/user/enrollment/list/:wid?orgdetails=orgName,email&licenseDetails=name,description,url&fields=contentType,name,channel,mimeType,appIcon,resourceType,identifier,trackable,objectType,organisation,pkgVersion,version,trackable,primaryCategory,posterImage,duration,creatorLogo,license,programDuration,avgRating,additionalTags,competencies_v5&batchDetails=name,endDate,startDate,status,enrollmentType,createdBy,certificates,batchAttributes';
  static const getCourseDetails = '/api/course/v1/hierarchy/';
  static const getCourseLearners = '/api/v2/resources/user/cohorts/activeusers';
  static const getCourseAuthors = '/api/v2/resources/user/cohorts/authors';
  static const getCourseProgress = '/apis/proxies/v8/read/content-progres/';
  static const setPdfCookie = '/apis/protected/v8/content/setCookie';
  static const getAllTopics = '/api/v1/catalog/';
  static const updateContentProgress = '/api/course/v1/content/state/update';
  static const readContentProgress = '/api/course/v1/content/state/read';
  static const getCourseCompletionCertificate =
      '/api/certreg/v2/certs/download/';
  static const getCourseCompletionCertificateForMobile =
      '/apis/public/v8/course/batch/cert/download/mobile';
  static const getUserProgress = '/api/v1/batch/getUserProgress';
  static const getYourRating = '/api/ratings/v2/read';
  static const getCourseReviewSummery = '/api/ratings/v1/summary/';
  static const postReview = '/api/ratings/v1/upsert';
  static const getCourseReview = '/api/ratings/v1/ratingLookUp';
  static const getAssessmentInfo = '/api/player/questionset/v4/hierarchy/';
  static const getAssessmentQuestions = '/api/player/question/v4/list';
  static const getRetakeAssessmentInfo = '/api/user/assessment/retake/';
  static const getCourse = '/api/content/v1/read/';
  static const getBatchList = '/api/course/v1/batch/list';
  static const getTrendingSearch = '/api/trending/search';

  // Providers
  static const getListOfProviders = '/api/org/v1/search';
  static const getCoursesByProvider = '/api/composite/v1/search';
  static const getAllProviders = '/api/searchBy/provider';

  // telemetry
  static const getTelemetryUrl = '/api/data/v1/telemetry';
  static const getPublicTelemetryUrl = '/api/data/v1/public/telemetry';
  static const saveAssessment = '/api/v2/user/assessment/submit';
  static const saveAssessmentNew = '/api/v4/user/assessment/submit';
  static const getAssessmentCompletionStatus = '/api/user/assessment/v4/result';

  // Socket connection
  static const socketUrl = 'http://40.113.200.227:4005/user';
  // static const vegaSocketUrl = 'https://vega-console.igot-dev.in/router';
  static String vegaSocketUrl = Env.vegaSocketUrl;
  static const vegaSuggestionUrl = '/getRoleBasedSugeestions';
  // static const vegaSocketUrl = 'https://thor-console.tarento.com/router';
  static const asrApiUrl =
      'https://dhruva-api.bhashini.gov.in/services/inference/pipeline';
  static const fetchModels =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline';

  // Competencies
  static const recommendedFromFrac = '/fracapis/frac/filterByMappings';
  static const recommendedFromWat = '/api/v2/workallocation/user/competencies/';
  static const allCompetencies = '/fracapis/frac/searchNodes';
  static const getLevelsForCompetency = '/fracapis/frac/getNodeById';
  static const getCompetencies = '/fracapis/frac/searchNodes';

  //Events
  static const getAllEvents = '/api/composite/v1/search';
  static const readEvent = '/api/event/v4/read/';

  //Registration
  static const getAllPosition = '/assets/configurations/site.config.json';
  static const getAllMinistries = '/api/org/v1/list/ministry';
  static const getAllStates = '/api/org/v1/list/state';
  static const register = '/api/user/registration/v1/register';
  static const registerParichayAccount = '/api/user/basicProfileUpdate';
  static const getAllOrganisation = '/api/org/ext/v2/signup/search';
  static const requestForPosition = '/api/workflow/position/create';
  static const requestForOrganisation = '/api/workflow/org/create';
  static const requestForDomain = '/api/workflow/domain/create';
  static const getGroups = '/api/user/v1/groups';

  //contact
  static const contact = 'https://igot-stage.in/public/contact';

  //Landing page
  static const getLandingPageInfo =
      'https://igotkarmayogi.gov.in/configurations.json';
  static const getFeaturedCourses = '//api/course/v1/explore';
  static const getListOfMdo = '/api/halloffame/read';

  //content flagging
  static const createFlag = '/api/user/offensive/data/flag';
  static const getFlaggedData = '/api/user/offensive/data/flag/getFlaggedData';
  static const updateFlaggedData = '/api/user/offensive/data/flag';

  //FAQ Chatbot
  static const getFaqAvailableLangUrl =
      '/api/faq/v1/assistant/available/language';
  static const getFaqDataUrl = '/api/faq/v1/assistant/configs/language';

  static const uploadProfilePhoto =
      '/api/storage/profilePhotoUpload/profileImage';
  static const getCbplan = '/api/user/v1/cbplan';
  static const competencySearch = '/api/competency/v4/search';
  static const searchByProvider = '/api/searchBy/provider';

  //Karma points
  static const karmaPointRead = '/api/karmapoints/read';
  static const totalKarmaPoint = '/api/user/totalkarmapoints';
  static const karmapointCourseRead = '/api/karmapoints/user/course/read';
  static const claimKarmaPoints = '/api/claimkarmapoints';

  //Competency passbook
  static const getCompetency =
      '/api/course/v2/user/enrollment/list/:wid?orgdetails=orgName,email&licenseDetails=name,description,url&fields=contentType,organisation,primaryCategory,topic,name,channel,mimeType,appIcon,gradeLevel,resourceType,identifier,medium,pkgVersion,board,subject,trackable,posterImage,duration,creatorLogo,license,version,versionKey,competencies_v5&batchDetails=name,endDate,startDate,status,enrollmentType,createdBy,certificates,batchAttributes';

  // config urls
  static const getUserNudgeConfig = '/assets/configurations/profile-nudge.json';
  static const getOverlayThemeData =
      '/assets/configurations/theme-override-config.json';

  // App urls
  static const androidUrl =
      'https://play.google.com/store/apps/details?id=com.igot.karmayogibharat';
  static const iOSUrl =
      'https://apps.apple.com/in/app/igot-karmayogi/id6443949491';
  static const iOSAppRatingUrl =
      'https://apps.apple.com/app/id6443949491?action=write-review';

  //Course sharing
  static const shareCourse = '/api/user/v1/content/recommend';
  // Linkedln link to share course certificate image
  static String linkedlnUrlToShareCertificate =
      'https://www.linkedin.com/sharing/share-offsite/?url=$baseUrl/apis/public/v8/cert/download/#certId';
}
