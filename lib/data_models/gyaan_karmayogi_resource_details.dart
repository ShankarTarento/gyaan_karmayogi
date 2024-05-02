import 'dart:convert';

class ResourceDetails {
  List<String> ownershipType;
  String instructions;
  String previewUrl;
  List<CreatorContact> creatorContacts;
  String channel;
  List<String> organisation;
  List<String> language;
  String source;
  String mimeType;
  String objectType;
  String appIcon;
  String primaryCategory;
  String contentEncoding;
  String artifactUrl;
  String contentType;
  Trackable trackable;
  String identifier;
  List<String> audience;
  String sectorId;
  bool isExternal;
  String visibility;
  DiscussionForum discussionForum;
  String mediaType;
  String sectorName;
  String osId;
  List<String> languageCode;
  String lastPublishedBy;
  int version;
  String license;
  String prevState;
  int size;
  String lastPublishedOn;
  String name;
  List<String> creatorIDs;
  String reviewStatus;
  String transcoding;
  String status;
  String code;
  Map<String, dynamic> interceptionPoints;
  String purpose;
  Credentials credentials;
  String prevStatus;
  // List<CompetenciesV5> competenciesV5;
  String description;
  String posterImage;
  String idealScreenSize;
  String createdOn;
  String duration;
  String subSectorName;
  String contentDisposition;
  String lastUpdatedOn;
  String subSectorId;
  String dialcodeRequired;
  String lastStatusChangedOn;
  List<String> createdFor;
  String creator;
  List<String> os;
  List<String> seFWIds;
  List<Reviewer> reviewer;
  String resourceCategory;
  int pkgVersion;
  String versionKey;
  List<String> reviewerIDs;
  String idealScreenDensity;
  String accessSetting;
  String framework;
  String lastSubmittedOn;
  String createdBy;
  int compatibilityLevel;
  int maxUserInBatch;

  ResourceDetails({
    this.ownershipType,
    this.instructions,
    this.previewUrl,
    this.creatorContacts,
    this.channel,
    this.organisation,
    this.language,
    this.source,
    this.mimeType,
    this.objectType,
    this.appIcon,
    this.primaryCategory,
    this.contentEncoding,
    this.artifactUrl,
    this.contentType,
    this.trackable,
    this.identifier,
    this.audience,
    this.sectorId,
    this.isExternal,
    this.visibility,
    this.discussionForum,
    this.mediaType,
    this.sectorName,
    this.osId,
    this.languageCode,
    this.lastPublishedBy,
    this.version,
    this.license,
    this.prevState,
    this.size,
    this.lastPublishedOn,
    this.name,
    this.creatorIDs,
    this.reviewStatus,
    this.transcoding,
    this.status,
    this.code,
    this.interceptionPoints,
    this.purpose,
    this.credentials,
    this.prevStatus,
    // this.competenciesV5,
    this.description,
    this.posterImage,
    this.idealScreenSize,
    this.createdOn,
    this.duration,
    this.subSectorName,
    this.contentDisposition,
    this.lastUpdatedOn,
    this.subSectorId,
    this.dialcodeRequired,
    this.lastStatusChangedOn,
    this.createdFor,
    this.creator,
    this.os,
    this.seFWIds,
    this.reviewer,
    this.resourceCategory,
    this.pkgVersion,
    this.versionKey,
    this.reviewerIDs,
    this.idealScreenDensity,
    this.accessSetting,
    this.framework,
    this.lastSubmittedOn,
    this.createdBy,
    this.compatibilityLevel,
    this.maxUserInBatch,
  });

  ResourceDetails.fromJson(Map<String, dynamic> json) {
    ownershipType = json['ownershipType'].cast<String>();
    instructions = json['instructions'];
    previewUrl = json['previewUrl'];
    if (json['creatorContacts'] != null) {
      creatorContacts = List<CreatorContact>();
      jsonDecode(json['creatorContacts']).forEach((v) {
        creatorContacts.add(new CreatorContact.fromJson(v));
      });
    }
    channel = json['channel'];
    organisation = json['organisation'].cast<String>();
    language = json['language'].cast<String>();
    source = json['source'];
    mimeType = json['mimeType'];
    objectType = json['objectType'];
    appIcon = json['appIcon'];
    primaryCategory = json['primaryCategory'];
    contentEncoding = json['contentEncoding'];
    artifactUrl = json['artifactUrl'];
    contentType = json['contentType'];
    trackable = json['trackable'] != null
        ? new Trackable.fromJson(json['trackable'])
        : null;
    identifier = json['identifier'];
    audience = json['audience'].cast<String>();
    sectorId = json['sectorId'];
    isExternal = json['isExternal'];
    visibility = json['visibility'];
    discussionForum = json['discussionForum'] != null
        ? new DiscussionForum.fromJson(json['discussionForum'])
        : null;
    mediaType = json['mediaType'];
    sectorName = json['sectorName'];
    osId = json['osId'];
    languageCode = json['languageCode'].cast<String>();
    lastPublishedBy = json['lastPublishedBy'];
    version = json['version'];
    license = json['license'];
    prevState = json['prevState'];
    size = json['size'];
    lastPublishedOn = json['lastPublishedOn'];
    name = json['name'];
    creatorIDs =
        json['creatorIDs'] != null ? List<String>.from(json['creatorIDs']) : [];
    reviewStatus = json['reviewStatus'];
    transcoding = json['transcoding'];
    status = json['status'];
    code = json['code'];
    interceptionPoints = json['interceptionPoints'];
    purpose = json['purpose'];
    credentials = json['credentials'] != null
        ? new Credentials.fromJson(json['credentials'])
        : null;
    prevStatus = json['prevStatus'];
    // if (json['competencies_v5'] != null) {
    //   competenciesV5 = new List<CompetenciesV5>();
    //   jsonDecode(json['competencies_v5']).forEach((v) {
    //     competenciesV5.add(new CompetenciesV5.fromJson(v));
    //   });
    // }
    description = json['description'];
    posterImage = json['posterImage'];
    idealScreenSize = json['idealScreenSize'];
    createdOn = json['createdOn'];
    duration = json['duration'];
    subSectorName = json['subSectorName'];
    contentDisposition = json['contentDisposition'];
    lastUpdatedOn = json['lastUpdatedOn'];
    subSectorId = json['subSectorId'];
    dialcodeRequired = json['dialcodeRequired'];
    lastStatusChangedOn = json['lastStatusChangedOn'];
    createdFor =
        json['createdFor'] != null ? json['createdFor'].cast<String>() : [];
    creator = json['creator'];
    os = List<String>.from(json['os']);
    seFWIds = List<String>.from(json['se_FWIds']);
    if (json['reviewer'] != null) {
      reviewer = new List<Reviewer>();
      jsonDecode(json['reviewer']).forEach((v) {
        reviewer.add(new Reviewer.fromJson(v));
      });
    }
    resourceCategory = json['resourceCategory'];
    pkgVersion = json['pkgVersion'];
    versionKey = json['versionKey'];
    reviewerIDs = json['reviewerIDs'] != null
        ? List<String>.from(json['reviewerIDs'])
        : [];
    idealScreenDensity = json['idealScreenDensity'];
    accessSetting = json['accessSetting'];
    framework = json['framework'];
    lastSubmittedOn = json['lastSubmittedOn'];
    createdBy = json['createdBy'];
    compatibilityLevel = json['compatibilityLevel'];
    maxUserInBatch = json['maxUserInBatch'];
  }
}

class CreatorContact {
  String id;
  String name;
  String email;

  CreatorContact({this.id, this.name, this.email});

  CreatorContact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }
}

class Trackable {
  String enabled;
  String autoBatch;

  Trackable({this.enabled, this.autoBatch});

  Trackable.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    autoBatch = json['autoBatch'];
  }
}

class DiscussionForum {
  String enabled;

  DiscussionForum({this.enabled});

  DiscussionForum.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
  }
}

class Credentials {
  String enabled;

  Credentials({this.enabled});

  Credentials.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enabled'] = this.enabled;
    return data;
  }
}

class CompetenciesV5 {
  String competencyArea;
  int competencyAreaId;
  String competencyAreaDescription;
  String competencyTheme;
  int competencyThemeId;
  String competecnyThemeDescription;
  String competencyThemeType;
  String competencySubTheme;
  int competencySubThemeId;
  String competecnySubThemeDescription;

  CompetenciesV5(
      {this.competencyArea,
      this.competencyAreaId,
      this.competencyAreaDescription,
      this.competencyTheme,
      this.competencyThemeId,
      this.competecnyThemeDescription,
      this.competencyThemeType,
      this.competencySubTheme,
      this.competencySubThemeId,
      this.competecnySubThemeDescription});

  CompetenciesV5.fromJson(Map<String, dynamic> json) {
    competencyArea = json['competencyArea'];
    competencyAreaId = json['competencyAreaId'];
    competencyAreaDescription = json['competencyAreaDescription'];
    competencyTheme = json['competencyTheme'];
    competencyThemeId = json['competencyThemeId'];
    competecnyThemeDescription = json['competecnyThemeDescription'];
    competencyThemeType = json['competencyThemeType'];
    competencySubTheme = json['competencySubTheme'];
    competencySubThemeId = json['competencySubThemeId'];
    competecnySubThemeDescription = json['competecnySubThemeDescription'];
  }
}

class Reviewer {
  String id;
  String name;
  String email;

  Reviewer({this.id, this.name, this.email});

  Reviewer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }
}
