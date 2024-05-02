class CourseSharingUserDataModel {
  String firstName;
  ProfileDetails profileDetails;
  String maskedEmail;
  String userId;

  CourseSharingUserDataModel({
    this.firstName,
    this.profileDetails,
    this.maskedEmail,
    this.userId,
  });

  factory CourseSharingUserDataModel.fromJson(Map<String, dynamic> json) {
    return CourseSharingUserDataModel(
      firstName: json['firstName'],
      profileDetails: ProfileDetails.fromJson(json['profileDetails']),
      maskedEmail: json['maskedEmail'],
      userId: json['userId'],
    );
  }
}

class ProfileDetails {
  PersonalDetails personalDetails;

  ProfileDetails({
    this.personalDetails,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    return ProfileDetails(
      personalDetails: PersonalDetails.fromJson(json['personalDetails']),
    );
  }
}

class PersonalDetails {
  String profileImageUrl;
  String primaryEmail;

  PersonalDetails({
    this.profileImageUrl,
    this.primaryEmail,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      profileImageUrl: json['profileImageUrl'],
      primaryEmail: json['primaryEmail'],
    );
  }
}
