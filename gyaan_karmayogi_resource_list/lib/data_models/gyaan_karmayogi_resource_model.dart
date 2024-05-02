class GyaanKarmayogiResource {
  List<String> ownershipType;
  String previewUrl;
  List<CreatorContact> creatorContacts;
  String channel;
  List<String> organisation;
  List<String> language;
  String source;
  String mimeType;
  String objectType;
  String primaryCategory;
  String contentEncoding;
  String artifactUrl;
  String contentType;
  Trackable trackable;
  String identifier;
  List<String> audience;
  bool isExternal;
  String visibility;
  String consumerId;
  DiscussionForum discussionForum;
  String mediaType;
  String osId;
  String graphId;
  String nodeType;
  String lastPublishedBy;
  int version;
  String license;
  String prevState;
  String lastPublishedOn;
  String iLFuncObjectType;
  String name;
  String status;
  String code;

  Credentials credentials;
  String prevStatus;
  String description;
  String streamingUrl;
  String posterImage;
  String idealScreenSize;
  String createdOn;
  String duration;
  String contentDisposition;
  String lastUpdatedOn;
  String dialcodeRequired;
  List<String> os;
  String iLSysNodeType;
  List<String> seFWIds;
  String resourceCategory;
  int pkgVersion;
  String versionKey;
  String idealScreenDensity;
  String framework;
  String createdBy;
  int compatibilityLevel;
  String contentUrl;
  String iLUniqueId;
  int maxUserInBatch;
  int nodeId;
  String sector;
  String subSector;

  GyaanKarmayogiResource({
    this.ownershipType,
    this.previewUrl,
    this.creatorContacts,
    this.channel,
    this.organisation,
    this.language,
    this.source,
    this.mimeType,
    this.objectType,
    this.primaryCategory,
    this.contentEncoding,
    this.artifactUrl,
    this.contentType,
    this.trackable,
    this.identifier,
    this.audience,
    this.isExternal,
    this.visibility,
    this.consumerId,
    this.discussionForum,
    this.mediaType,
    this.osId,
    this.graphId,
    this.nodeType,
    this.lastPublishedBy,
    this.version,
    this.license,
    this.prevState,
    this.lastPublishedOn,
    this.iLFuncObjectType,
    this.name,
    this.status,
    this.code,
    this.credentials,
    this.prevStatus,
    this.description,
    this.streamingUrl,
    this.posterImage,
    this.idealScreenSize,
    this.createdOn,
    this.duration,
    this.contentDisposition,
    this.lastUpdatedOn,
    this.dialcodeRequired,
    this.os,
    this.iLSysNodeType,
    this.seFWIds,
    this.resourceCategory,
    this.pkgVersion,
    this.versionKey,
    this.idealScreenDensity,
    this.framework,
    this.createdBy,
    this.compatibilityLevel,
    this.contentUrl,
    this.iLUniqueId,
    this.maxUserInBatch,
    this.nodeId,
    this.sector,
    this.subSector,
  });

  GyaanKarmayogiResource.fromJson(Map<String, dynamic> json) {
    ownershipType = List<String>.from(json['ownershipType']);

    previewUrl = json['previewUrl'];
    // if (json['creatorContacts'] != null) {
    //   creatorContacts =
    //       List<CreatorContact>.from(json['creatorContacts'].forEach((v) {
    //     creatorContacts.add(new CreatorContact.fromJson(v));
    //   }));
    // }
    channel = json['channel'];
    organisation = List<String>.from(json['organisation']);
    language = List<String>.from(json['language']);
    source = json['source'];
    mimeType = json['mimeType'];
    objectType = json['objectType'];
    primaryCategory = json['primaryCategory'];
    contentEncoding = json['contentEncoding'];
    artifactUrl = json['artifactUrl'];
    contentType = json['contentType'];
    trackable = json['trackable'] != null
        ? Trackable.fromJson(json['trackable'])
        : null;
    identifier = json['identifier'];
    audience = List<String>.from(json['audience']);
    isExternal = json['isExternal'];
    visibility = json['visibility'];
    consumerId = json['consumerId'];
    discussionForum = json['discussionForum'] != null
        ? DiscussionForum.fromJson(json['discussionForum'])
        : null;
    mediaType = json['mediaType'];
    osId = json['osId'];
    graphId = json['graph_id'];
    nodeType = json['nodeType'];
    lastPublishedBy = json['lastPublishedBy'];
    version = json['version'];
    license = json['license'];
    prevState = json['prevState'];
    lastPublishedOn = json['lastPublishedOn'];
    iLFuncObjectType = json['IL_FUNC_OBJECT_TYPE'];
    name = json['name'];
    status = json['status'];
    code = json['code'];
    credentials = json['credentials'] != null
        ? Credentials.fromJson(json['credentials'])
        : null;
    prevStatus = json['prevStatus'];
    description = json['description'];
    streamingUrl = json['streamingUrl'];
    posterImage = json['posterImage'];
    idealScreenSize = json['idealScreenSize'];
    createdOn = json['createdOn'];
    duration = json['duration'];
    contentDisposition = json['contentDisposition'];
    lastUpdatedOn = json['lastUpdatedOn'];
    dialcodeRequired = json['dialcodeRequired'];
    os = json['0s'] != null ? List<String>.from(json['0s']) : null;
    iLSysNodeType = json['IL_SYS_NODE_TYPE'];
    seFWIds =
        json['se_FWIds'] != null ? List<String>.from(json['se_FWIds']) : null;
    resourceCategory = json['resourceCategory'];
    pkgVersion = json['pkgVersion'];
    versionKey = json['versionKey'];
    idealScreenDensity = json['idealScreenDensity'];
    framework = json['framework'];
    createdBy = json['createdBy'];
    compatibilityLevel = json['compatibilityLevel'];
    contentUrl = json['content_url'];
    iLUniqueId = json['IL_UNIQUE_ID'];
    maxUserInBatch = json['maxUserInBatch'];
    nodeId = json['node_id'];
    sector = json['sectorName'];
    subSector = json['subSectorName'];
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
}





// class CreatorContact {
//   String id;
//   String name;
//   String email;

//   CreatorContact({this.id, this.name, this.email});

//   CreatorContact fromJson(Map<String, dynamic> json) {
//     return CreatorContact(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//     );
//   }
// }

// class Trackable {
//   String enabled;
//   String autoBatch;

//   Trackable({this.enabled, this.autoBatch});

//   Trackable fromJson(Map<String, dynamic> json) {
//     return Trackable(
//       enabled: json['enabled'],
//       autoBatch: json['autoBatch'],
//     );
//   }
// }

// class DiscussionForum {
//   String enabled;

//   DiscussionForum({this.enabled});

//   DiscussionForum fromJson(Map<String, dynamic> json) {
//     return DiscussionForum(
//       enabled: json['enabled'],
//     );
//   }
// }

// class Competency {
//   String competencyTheme;
//   int competencySubThemeId;
//   String competencyArea;
//   String competencyThemeType;
//   String competecnySubThemeDescription;
//   int competencyAreaId;
//   String competecnyThemeDescription;
//   String competencySubTheme;
//   int competencyThemeId;
//   String competencyAreaDescription;

//   Competency({
//     this.competencyTheme,
//     this.competencySubThemeId,
//     this.competencyArea,
//     this.competencyThemeType,
//     this.competecnySubThemeDescription,
//     this.competencyAreaId,
//     this.competecnyThemeDescription,
//     this.competencySubTheme,
//     this.competencyThemeId,
//     this.competencyAreaDescription,
//   });

//   Competency fromJson(Map<String, dynamic> json) {
//     return Competency(
//       competencyTheme: json['competencyTheme'],
//       competencySubThemeId: json['competencySubThemeId'],
//       competencyArea: json['competencyArea'],
//       competencyThemeType: json['competencyThemeType'],
//       competecnySubThemeDescription: json['competecnySubThemeDescription'],
//       competencyAreaId: json['competencyAreaId'],
//       competecnyThemeDescription: json['competecnyThemeDescription'],
//       competencySubTheme: json['competencySubTheme'],
//       competencyThemeId: json['competencyThemeId'],
//       competencyAreaDescription: json['competencyAreaDescription'],
//     );
//   }
// }

// class Credentials {
//   String enabled;

//   Credentials({this.enabled});

//   Credentials fromJson(Map<String, dynamic> json) {
//     return Credentials(
//       enabled: json['enabled'],
//     );
//   }
// }

// class Reviewer {
//   String id;
//   String name;
//   String email;

//   Reviewer({this.id, this.name, this.email});

//   Reviewer fromJson(Map<String, dynamic> json) {
//     return Reviewer(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//     );
//   }
// }

// class GyaanKarmayogiResource {
//   List<String> ownershipType;
//   String instructions;
//   String previewUrl;
//   List<CreatorContact> creatorContacts;
//   String channel;
//   List<String> organisation;
//   List<String> language;
//   String source;
//   String mimeType;
//   String objectType;
//   String appIcon;
//   String primaryCategory;
//   String contentEncoding;
//   String artifactUrl;
//   String contentType;
//   Trackable trackable;
//   String identifier;
//   List<String> audience;
//   String sectorId;
//   bool isExternal;
//   String visibility;
//   DiscussionForum discussionForum;
//   String mediaType;
//   String sectorName;
//   String osId;
//   String graphId;
//   String nodeType;
//   String lastPublishedBy;
//   int version;
//   String license;
//   String prevState;
//   int size;
//   String lastPublishedOn;
//   String IL_FUNC_OBJECT_TYPE;
//   String name;
//   List<String> creatorIDs;
//   String reviewStatus;
//   String transcoding;
//   String status;
//   String code;
//   Map<String, dynamic> interceptionPoints;
//   String purpose;
//   Credentials credentials;
//   String prevStatus;
//   List<Competency> competenciesV5;
//   String description;
//   String posterImage;
//   String idealScreenSize;
//   String createdOn;
//   String duration;
//   String subSectorName;
//   String contentDisposition;
//   String lastUpdatedOn;
//   String subSectorId;
//   String dialcodeRequired;
//   List<String> createdFor;
//   String creator;
//   List<String> os;
//   String IL_SYS_NODE_TYPE;
//   List<String> seFWIds;
//   List<Reviewer> reviewer;
//   String resourceCategory;
//   int pkgVersion;
//   String versionKey;
//   List<String> reviewerIDs;
//   String idealScreenDensity;
//   String framework;
//   String lastSubmittedOn;
//   String createdBy;
//   int compatibilityLevel;
//   String IL_UNIQUE_ID;
//   int maxUserInBatch;
//   int nodeId;

//   GyaanKarmayogiResource({
//     this.ownershipType,
//     this.instructions,
//     this.previewUrl,
//     this.creatorContacts,
//     this.channel,
//     this.organisation,
//     this.language,
//     this.source,
//     this.mimeType,
//     this.objectType,
//     this.appIcon,
//     this.primaryCategory,
//     this.contentEncoding,
//     this.artifactUrl,
//     this.contentType,
//     this.trackable,
//     this.identifier,
//     this.audience,
//     this.sectorId,
//     this.isExternal,
//     this.visibility,
//     this.discussionForum,
//     this.mediaType,
//     this.sectorName,
//     this.osId,
//     this.graphId,
//     this.nodeType,
//     this.lastPublishedBy,
//     this.version,
//     this.license,
//     this.prevState,
//     this.size,
//     this.lastPublishedOn,
//     this.IL_FUNC_OBJECT_TYPE,
//     this.name,
//     this.creatorIDs,
//     this.reviewStatus,
//     this.transcoding,
//     this.status,
//     this.code,
//     this.interceptionPoints,
//     this.purpose,
//     this.credentials,
//     this.prevStatus,
//     this.competenciesV5,
//     this.description,
//     this.posterImage,
//     this.idealScreenSize,
//     this.createdOn,
//     this.duration,
//     this.subSectorName,
//     this.contentDisposition,
//     this.lastUpdatedOn,
//     this.subSectorId,
//     this.dialcodeRequired,
//     this.createdFor,
//     this.creator,
//     this.os,
//     this.IL_SYS_NODE_TYPE,
//     this.seFWIds,
//     this.reviewer,
//     this.resourceCategory,
//     this.pkgVersion,
//     this.versionKey,
//     this.reviewerIDs,
//     this.idealScreenDensity,
//     this.framework,
//     this.lastSubmittedOn,
//     this.createdBy,
//     this.compatibilityLevel,
//     this.IL_UNIQUE_ID,
//     this.maxUserInBatch,
//     this.nodeId,
//   });

//   GyaanKarmayogiResource.fromJson(Map<String, dynamic> json) {
//       ownershipType: json['ownershipType'].cast<String>();
//       instructions: json['instructions'];
//       previewUrl: json['previewUrl'];
//       creatorContacts: List<CreatorContact>.from(
//           json['creatorContacts'].map((x) => CreatorContact().fromJson(x)));
//       channel: json['channel'];
//       organisation: json['organisation'].cast<String>();
//       language: json['language'].cast<String>();
//       source: json['source'];
//       mimeType: json['mimeType'];
//       objectType: json['objectType'];
//       appIcon: json['appIcon'];
//       primaryCategory: json['primaryCategory'],
//       contentEncoding: json['contentEncoding'],
//       artifactUrl: json['artifactUrl'],
//       contentType: json['contentType'],
//       trackable: Trackable().fromJson(json['trackable']),
//       identifier: json['identifier'],
//       audience: json['audience'].cast<String>(),
//       sectorId: json['sectorId'],
//       isExternal: json['isExternal'],
//       visibility: json['visibility'],
//       discussionForum: DiscussionForum().fromJson(json['discussionForum']),
//       mediaType: json['mediaType'],
//       sectorName: json['sectorName'],
//       osId: json['osId'],
//       graphId: json['graph_id'],
//       nodeType: json['nodeType'],
//       lastPublishedBy: json['lastPublishedBy'],
//       version: json['version'],
//       license: json['license'],
//       prevState: json['prevState'],
//       size: json['size'],
//       lastPublishedOn: json['lastPublishedOn'],
//       IL_FUNC_OBJECT_TYPE: json['IL_FUNC_OBJECT_TYPE'],
//       name: json['name'],
//       creatorIDs: json['creatorIDs'].cast<String>(),
//       reviewStatus: json['reviewStatus'],
//       transcoding: json['transcoding'],
//       status: json['status'],
//       code: json['code'],
//       interceptionPoints: json['interceptionPoints'],
//       purpose: json['purpose'],
//       credentials: Credentials().fromJson(json['credentials']),
//       prevStatus: json['prevStatus'],
//       competenciesV5: List<Competency>.from(
//           json['competencies_v5'].map((x) => Competency().fromJson(x))),
//       description: json['description'],
//       posterImage: json['posterImage'],
//       idealScreenSize: json['idealScreenSize'],
//       createdOn: json['createdOn'],
//       duration: json['duration'],
//       subSectorName: json['subSectorName'],
//       contentDisposition: json['contentDisposition'],
//       lastUpdatedOn: json['lastUpdatedOn'],
//       subSectorId: json['subSectorId'],
//       dialcodeRequired: json['dialcodeRequired'],
//       createdFor: json['createdFor'].cast<String>(),
//       creator: json['creator'],
//       os: json['os'].cast<String>(),
//       IL_SYS_NODE_TYPE: json['IL_SYS_NODE_TYPE'],
//       seFWIds: json['se_FWIds'].cast<String>(),
//       reviewer: List<Reviewer>.from(
//           json['reviewer'].map((x) => Reviewer().fromJson(x))),
//       resourceCategory: json['resourceCategory'],
//       pkgVersion: json['pkgVersion'],
//       versionKey: json['versionKey'],
//       reviewerIDs: json['reviewerIDs'].cast<String>(),
//       idealScreenDensity: json['idealScreenDensity'],
//       framework: json['framework'],
//       lastSubmittedOn: json['lastSubmittedOn'],
//       createdBy: json['createdBy'],
//       compatibilityLevel: json['compatibilityLevel'],
//       IL_UNIQUE_ID: json['IL_UNIQUE_ID'],
//       maxUserInBatch: json['maxUserInBatch'],
//       nodeId: json['node_id'];
    
//   }
// }
