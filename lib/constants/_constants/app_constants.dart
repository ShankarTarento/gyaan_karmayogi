import 'dart:io';

import 'package:karmayogi_mobile/env/env.dart';

const String APP_VERSION = '3.7.7';
const String APP_NAME = 'iGOT Karmayogi';
const String APP_ENVIRONMENT = Environment.bm;
const String TELEMETRY_ID = 'api.sunbird.telemetry';
const String DEFAULT_CHANNEL = 'igot';
// ignore: non_constant_identifier_names
String TELEMETRY_PDATA_ID = Platform.isIOS
    ? Env.telemetryPdataId.replaceAll("android", "ios")
    : Env.telemetryPdataId;
// ignore: non_constant_identifier_names
String TELEMETRY_PDATA_PID =
    Platform.isIOS ? 'karmayogi-mobile-ios' : 'karmayogi-mobile-android';
const String TELEMETRY_EVENT_VERSION = '3.0';
const String APP_DOWNLOAD_FOLDER = '/storage/emulated/0/Download';
const String PAGE_LOADER = 'assets/animations/karma_loader_latest.riv';
const String ASSESSMENT_FITB_QUESTION_INPUT =
    '<input style=\"border-style:none none solid none\" />';
const String APP_STORE_ID = '6443949491';

// ignore: non_constant_identifier_names
String PARICHAY_CODE_VERIFIER = Env.parichayCodeVerifier;
// ignore: non_constant_identifier_names
String PARICHAY_CLIENT_ID = Env.parichayClientId;
// ignore: non_constant_identifier_names
String PARICHAY_CLIENT_SECRET = Env.parichayClientSecret;

// ignore: non_constant_identifier_names
String PARICHAY_KEYCLOAK_CLIENT_SECRET = Env.parichayKeycloakSecret;

// ignore: non_constant_identifier_names
String X_CHANNEL_ID = Env.xChannelId;

// ignore: non_constant_identifier_names
String SOURCE_NAME = Env.sourceName;

String SPV_ADMIN_ROOT_ORG_ID = Env.spvAdminRootOrgId;

String mdoID;
String mdo;
bool isSPVAdmin = false;
bool isMDOAdmin = false;
bool enableCuratedProgram = true;
const int RATING_LIMIT = 5;
const int CLAP_DURATION = 60;
const int CACHE_EXPIRY_DURATION = 60;

// New home
const double COURSE_CARD_HEIGHT = 310.0;
const double COURSE_CARD_WIDTH = 245.0;
const double DISCUSS_CARD_HEIGHT = 148.0;
const int DISCUSS_CARD_DISPLAY_LIMIT = 5;
const BUTTON_ANIMATION_DURATION = Duration(milliseconds: 200);
const int CLAPS_WEEK_COUNT = 4;
const int SHOW_ALL_CHECK_COUNT = 10;
const int SHOW_ALL_DISPLAY_COUNT = 1;
const int CERTIFICATE_COUNT = 4;

//CBP plan
const int CBP_COURSE_ON_TIMELINE_LIST_LIMIT = 2;
const int CBP_UPCOMING_SHOW_DATE_DIFF = 30;
const List<String> CBP_STATS_FILTER = [
  CBPFilterTimeDuration.last3month,
  CBPFilterTimeDuration.last6month,
  CBPFilterTimeDuration.lastYear
];

class AppLocale {
  static const hindi = "hi";
  static const english = "en";
  static const tamil = "ta";
  static const assamese = "as";
  static const bengali = "bn";
  static const telugu = "te";
  static const kannada = "kn";
  static const malaylam = "ml";
  static const gujarati = "gu";
  static const oriya = "or";
  static const punjabi = 'pa';
  static const marathi = "mr";
}

//Karma point
const int KARMAPOINT_DISPLAY_LIMIT = 3;
const int KARMAPOINT_READ_LIMIT = 6;
const int COURSE_RATING_POINT = 2;
const int COURSE_COMPLETION_POINT = 5;
const int ACBP_COURSE_COMPLETION_POINT = 15;
const int FIRST_ENROLMENT_POINT = 5;
const int KARMPOINT_AWARD_LIMIT_TO_COURSE = 4;

//Competency
const int SUBTHEME_VIEW_COUNT = 2;

// App default design size
const double DEFAULT_DESIGN_WIDTH = 412;
const double DEFAULT_DESIGN_HEIGHT = 869;

//Trending courses
const int COURSE_LISTING_PAGE_LIMIT = 100;

class RegistrationRequests {
  static const String STATE = 'INITIATE';
  static const String ACTION = 'INITIATE';
  static const String POSITION_SERVICE_NAME = 'position';
  static const String ORGANISATION_SERVICE_NAME = 'organisation';
  static const String DOMAIN_SERVICE_NAME = 'domain';
  static const String IGOT_DEPT_NAME = 'iGOT';
}

class VegaConfiguration {
  static bool isEnabled = false;
}

class Client {
  static const String androidClientId = 'android';
  static const String parichayClientId = 'parichay-oAuth-mobile';
}

class Roles {
  static const String spv = 'SPV_ADMIN';
  static const String mdo = 'MDO_ADMIN';
}

class Environment {
  static const String eagle = 'eagle';
  static const String sunbird = 'sunbird';
  static const String dev = '.env.dev';
  static const String stage = '.env.stage';
  static const String preProd = '.env.preprod';
  static const String bm = '.env.bm';
  static const String prod = '.env.prod';
  static const String qa = '.env.qa';
}

class ChartType {
  static const String profileViews = 'profileViews';
  static const String platformUsage = 'platformUsage';
}

class AppDatabase {
  static const String name = 'igot_karmayogi';
  static const String deletedNotificationsTable = 'deleted_notifications';
  static const String telemetryEventsTable = 'telemetry_events';
  static const String feedbackTable = 'user_feedback';
}

class AILanguageModel {
  static String hindi = Env.vegaHindiServiceId;
  static String english = Env.vegaEnglishServiceId;
  static String hindiToEnglish = Env.vegaHindiToEnglishServiceId;
}

class ChatBotLocale {
  static const hindi = "hi";
  static const english = "en";
}

class EventType {
  static const karmayogiTalks = "Karmayogi Talks";
  static const webinar = "Webinar";
}

class FaqConfigType {
  static const info = 'IN';
  static const issue = 'IS';
}

class AcademicDegree {
  static const String graduation = 'graduation';
  static const String postGraduation = 'postGraduation';
}

class DegreeType {
  static const String xStandard = 'X_STANDARD';
  static const String xiiStandard = 'XII_STANDARD';
  static const String graduate = 'GRADUATE';
  static const String postGraduate = 'POSTGRADUATE';
}

class NotificationType {
  static const String error = 'error';
  static const String success = 'success';
}

class EMimeTypes {
  static const String collection = 'application/vnd.ekstep.content-collection';
  static const String html = 'application/vnd.ekstep.html-archive';
  static const String ilp_fp = 'application/ilpfp';
  static const String iap = 'application/iap-assessment';
  static const String m4a = 'audio/m4a';
  static const String mp3 = 'audio/mpeg';
  static const String mp4 = 'video/mp4';
  static const String m3u8 = 'application/x-mpegURL';
  static const String interaction = 'video/interactive';
  static const String pdf = 'application/pdf';
  static const String png = 'image/png';
  static const String quiz = 'application/quiz';
  static const String dragDrop = 'application/drag-drop';
  static const String htmlPicker = 'application/htmlpicker';
  static const String webModule = 'application/web-module';
  static const String webModuleExercise = 'application/web-module-exercise';
  static const String youtube = 'video/x-youtube';
  static const String handsOn = 'application/integrated-hands-on';
  static const String rdbmsHandsOn = 'application/rdbms';
  static const String classDiagram = 'application/class-diagram';
  static const String channel = 'application/channel';
  static const String collectionResource = 'resource/collection';
  // Added on UI Onl;
  static const String certification = 'application/certification';
  static const String playlist = 'application/playlist';
  static const String unknown = 'application/unknown';
  static const String externalLink = 'text/x-url';
  static const String youtubeLink = 'video/x-youtube';
  static const String assessment = 'application/json';
  static const String newAssessment = 'application/vnd.sunbird.questionset';
  static const String survey = 'application/survey';
  static const String offlineSession = 'application/offline';
  static const String offline = 'application/offline';
}

class EDisplayContentTypes {
  static const String assessment = 'ASSESSMENT';
  static const String audio = 'AUDIO';
  static const String certification = 'CERTIFICATION';
  static const String channel = 'Channel';
  static const String classDiagram = 'CLASS_DIAGRAM';
  static const String course = 'COURSE';
  static const String dDefault = 'DEFAULT';
  static const String dragDrop = 'DRAG_DROP';
  static const String externalCertification = 'EXTERNAL_CERTIFICATION';
  static const String externalCourse = 'EXTERNAL_COURSE';
  static const String goals = 'GOALS';
  static const String handsOn = 'HANDS_ON';
  static const String iap = 'IAP';
  static const String instructorLed = 'INSTRUCTOR_LED';
  static const String interactiveVideo = 'INTERACTIVE_VIDEO';
  static const String knowledgeArtifact = 'KNOWLEDGE_ARTIFACT';
  static const String module = 'MODULE';
  static const String pdf = 'PDF';
  static const String html = 'HTML';
  static const String playlist = 'PLAYLIST';
  static const String program = 'PROGRAM';
  static const String quiz = 'QUIZ';
  static const String resource = 'RESOURCE';
  static const String rdbmsHands_on = 'RDBMS_HANDS_ON';
  static const String video = 'VIDEO';
  static const String webModule = 'WEB_MODULE';
  static const String webPage = 'WEB_PAGE';
  static const String youtube = 'YOUTUBE';
  static const String knowledgeBoard = 'Knowledge Board';
  static const String learningJourney = 'Learning Journeys';
}

class Azure {
  static const String host = 'https://karmayogi.nic.in/';
  static const String bucket = 'content-store';
}

// class SunbirdDev {
//   static const String host = 'https://igot.blob.core.windows.net/';
//   static const String bucket = 'content';
// }

// class SunbirdStage {
//   static const String host = 'https://igot-stage.in/assets/public/';
//   static const String bucket = 'content';
// }

// class SunbirdPreProd {
//   static const String host = 'https://static.karmayogiprod.nic.in/igot/';
//   static const String bucket = 'content';
// }

class QuestionTypes {
  static const String singleAnswer = 'singleAnswer';
  static const String multipleAnswer = 'multipleAnswer';
}

class AssessmentQuestionType {
  static const String radioType = 'mcq-sca';
  static const String checkBoxType = 'mcq-mca';
  static const String matchCase = 'mtf';
  static const String fitb = 'fitb';
  static const String ftb = 'ftb';
}

class Vega {
  static const String userEmail = 'mahuli@varsha.com';
  static const String endpoint = 'Vega';
  static const String faqEndpoint = 'Vega-faq';
}

class IntentType {
  static const String direct = 'direct';
  static const String discussions = 'discussions';
  static const String competencyList = 'competencylist';
  static const String contact = 'contact';
  static const String course = 'course';
  static const String tags = 'tags';
  static const String learners = 'learners';
  static const String visualisation = 'visualisations';
  static const String coursesCompetency = 'courses_with_competency';
  static const String competencyCourses = 'competency_courses';
  static const String images = 'images';
  static const String links = 'links';
  static const String youtubeVideo = 'youtubeVideo';
  static const String dateFormat = 'dd-MM-yyyy';
  static const String dateFormat2 = 'd MMM, y';
  static const String dateFormatYearOnly = 'y';
}

class PrimaryCategory {
  static const String practiceAssessment = "Practice Question Set";
  static const String finalAssessment = "Course Assessment";
  static const String program = 'program';
  static const String course = 'course';
  static const String learningResource = 'Learning resource';
  static const String standaloneAssessment = 'standalone assessment';
  static const String blendedProgram = 'Blended Program';
  static const String curatedProgram = 'Curated Program';
  static const String moderatedCourses = 'Moderated Course';
  static const String moderatedProgram = 'Moderated Program';
  static const String moderatedAssessment = 'Moderated Assessment';
  static const String inviteOnlyProgram = 'Invite-Only Program';
  static const String offlineSession = 'Offline Session';
}

enum CourseCategory { programs, courses, certifications, under_30_mins }

enum EnrolmentStatus { enrolled, withdrawn, waiting, removed, rejected }

class DeviceOS {
  static const String android = 'Android';
  static const String iOS = 'iOS';
}

class AttendenceMarking {
  static const int bufferHour = 1;
}

enum WFBlendedProgramStatus {
  INITIATE,
  SEND_FOR_MDO_APPROVAL,
  SEND_FOR_PC_APPROVAL,
  APPROVED,
  REJECTED,
  WITHDRAWN,
  WITHDRAW,
  REMOVED
}

class GetStarted {
  static const int autoCloseDuration = 3000;
  static const String finished = 'true';
  static const String reset = 'false';
}

enum WFBlendedWithdrawCheck {
  SEND_FOR_MDO_APPROVAL,
  SEND_FOR_PC_APPROVAL,
  REMOVED,
  REJECTED
}

enum FieldTypes { radio, textarea, rating, checkbox, text }

enum WFBlendedProgramAprovalTypes {
  oneStepPCApproval,
  oneStepMDOApproval,
  twoStepMDOAndPCApproval,
  twoStepPCAndMDOApproval
}

enum EnvironmentValues { igot, igotqa, igotbm, igotprod }

class CBPFilterCategory {
  static const String contentType = "Content Type";
  static const String status = "Status";
  static const String timeDuration = 'Time Duration';
  static const String competencyArea = 'Competency Area';
  static const String provider = 'Provider';
  static const String competencyTheme = "Competency Theme";
  static const String competencySubtheme = 'Competency Sub-Theme';
}

class CBPCourseStatus {
  static const String inProgress = "In Progress";
  static const String notStarted = "Not started";
  static const String completed = 'Completed';
}

class CBPFilterTimeDuration {
  static const String upcoming7days = "Upcoming 7 days";
  static const String upcoming30days = "Upcoming 30 days";
  static const String upcoming3months = "Upcoming 3 months";
  static const String upcoming6months = "Upcoming 6 months";
  static const String lastWeek = "Last week";
  static const String lastMonth = "Last month";
  static const String last3month = "Last 3 months";
  static const String last6month = "Last 6 months";
  static const String lastYear = "Last year";
}

class OperationTypes {
  static const String couseCompletion = 'COURSE_COMPLETION';
  static const String firstEnrolment = 'FIRST_ENROLMENT';
  static const String rating = 'RATING';
  static const String firstLogin = 'FIRST_LOGIN';
}

class CompetencyAreas {
  static const String behavioural = 'behavioural';
  static const String functional = 'functional';
  static const String domain = 'domain';
}

class CompetencyFilterCategory {
  static const String competencyArea = "Competency Area";
  static const String competencyTheme = "Competency Theme";
  static const String competencySubtheme = 'Competency Sub-Theme';
}

class CertificateType {
  static const String png = "png";
  static const String pdf = "pdf";
}

class DeepLinkCategory {
  static const String survey = 'Survey';
}

class FeedCategory {
  static const String nps = 'NPS';
  static const String inAppReview = 'InAppReview';
}

class TocButtonStatus {
  static const String enroll = "enroll";
  static const String start = "start";
  static const String resume = "resume";
  static const String startAgain = "start again";
  static const String takeTest = "take test";
}
