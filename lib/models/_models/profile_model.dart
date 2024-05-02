import 'package:flutter/material.dart';

class Profile {
  final String firstName;
  final String middleName;
  final String surname;
  final Object personalDetails;
  final String username;
  final String primaryEmail;
  final dynamic interests;
  final Object skills;
  final String designation;
  final String department;
  final String location;
  final String photo;
  final List experience;
  final List education;
  final List competencies;
  final Object employmentDetails;
  final List professionalDetails;
  final List userRoles;
  final List selectedTopics;
  final List desiredTopics;
  final List desiredCompetencies;
  final List roles;
  final List tags;
  final rawDetails;
  final bool verifiedKarmayogi;
  final String profileImageUrl;
  final bool phoneVerified;
  final int profileCompletionPercentage;
  final String group;
  final String ehrmsId;
  final String ehrmsSystem;
  final String lastMotivationalMessageTime;

  const Profile(
      {@required this.firstName,
      this.middleName,
      @required this.surname,
      @required this.personalDetails,
      this.username,
      @required this.primaryEmail,
      this.interests,
      this.skills,
      this.designation,
      @required this.department,
      this.photo,
      this.location,
      this.experience,
      this.education,
      this.competencies,
      this.employmentDetails,
      this.professionalDetails,
      this.userRoles,
      this.selectedTopics,
      this.desiredTopics,
      this.desiredCompetencies,
      this.roles,
      this.tags,
      @required this.rawDetails,
      this.verifiedKarmayogi,
      this.profileImageUrl,
      this.phoneVerified,
      this.profileCompletionPercentage,
      this.group,
      this.ehrmsId,
      this.ehrmsSystem,
      this.lastMotivationalMessageTime
      });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      firstName:
          json['profileDetails']['personalDetails']['firstname'] as String,
      middleName:
          json['profileDetails']['personalDetails']['middlename'] != null
              ? json['profileDetails']['personalDetails']['middlename']
              : '',
      surname: json['profileDetails']['personalDetails']['surname'] as String,
      personalDetails: json['profileDetails']['personalDetails'] as Object,
      username: json['userName'] != null
          ? json['userName']
          : json['profileDetails']['personalDetails']['username'] as String,
      primaryEmail:
          json['profileDetails']['personalDetails']['primaryEmail'] as String,
      interests: json['profileDetails']['interests'] != null
          ? json['profileDetails']['interests']
          : {},
      skills: json['profileDetails']['skills'] != null
          ? json['profileDetails']['skills']
          : {},
      designation: (json['profileDetails']['professionalDetails'] != null &&
              json['profileDetails']['professionalDetails'].length > 0)
          ? json['profileDetails']['professionalDetails'][0]['designation']
          : '',
      department: json['profileDetails']['employmentDetails'] != null
          ? json['profileDetails']['employmentDetails']['departmentName']
              as String
          : '',
      photo: json['profileDetails']['photo'] != null
          ? json['profileDetails']['photo']
          : '',
      location:
          json['profileDetails']['personalDetails']['postalAddress'] != null
              ? json['profileDetails']['personalDetails']['postalAddress']
              : '',
      experience: json['profileDetails']['professionalDetails'] != null
          ? json['profileDetails']['professionalDetails']
          : [],
      education: json['profileDetails']['academics'] != null
          ? json['profileDetails']['academics']
          : [],
      competencies: json['profileDetails']['competencies'] != null
          ? json['profileDetails']['competencies']
          : [],
      employmentDetails: json['profileDetails']['employmentDetails'] != null
          ? json['profileDetails']['employmentDetails']
          : {},
      professionalDetails: json['profileDetails']['professionalDetails'] != null
          ? json['profileDetails']['professionalDetails']
          : [],
      userRoles: json['profileDetails']['userRoles'] != null
          ? json['profileDetails']['userRoles']
          : [],
      selectedTopics: json['profileDetails']['systemTopics'] != null
          ? json['profileDetails']['systemTopics']
          : [],
      desiredTopics: json['profileDetails']['desiredTopics'] != null
          ? json['profileDetails']['desiredTopics']
          : [],
      desiredCompetencies: json['profileDetails']['desiredCompetencies'] != null
          ? json['profileDetails']['desiredCompetencies']
          : [],
      roles: json['roles'],
      tags: json['profileDetails']['additionalProperties'] != null
          ? json['profileDetails']['additionalProperties']['tag'] != null
              ? json['profileDetails']['additionalProperties']['tag']
              : []
          : [],
      rawDetails: json,
      verifiedKarmayogi: json['profileDetails']['verifiedKarmayogi'] != null
          ? json['profileDetails']['verifiedKarmayogi']
          : false,
      profileImageUrl: json['profileDetails']['profileImageUrl'] != null
          ? json['profileDetails']['profileImageUrl']
          : '',
      phoneVerified:
          json['phoneVerified'] != null ? json['phoneVerified'] : false,
      profileCompletionPercentage: json['profileUpdateCompletion'] != null
          ? json['profileUpdateCompletion']
          : 0,
      group: (json['profileDetails']['professionalDetails'] != null &&
              json['profileDetails']['professionalDetails'].length > 0)
          ? json['profileDetails']['professionalDetails'][0]['group']
          : null,
      ehrmsId: json['profileDetails']['additionalProperties'] != null
          ? json['profileDetails']['additionalProperties']['externalSystemId']
          : null,
      ehrmsSystem: json['profileDetails']['additionalProperties'] != null
          ? json['profileDetails']['additionalProperties']['externalSystem']
          : null,
        lastMotivationalMessageTime: json['profileDetails']['lastMotivationalMessageTime'] !=null? json['profileDetails']['lastMotivationalMessageTime'] : ''

    );
  }
}
