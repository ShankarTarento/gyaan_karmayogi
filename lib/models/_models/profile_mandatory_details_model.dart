import 'package:flutter/material.dart';

class ProfileMandatoryDetails {
  final String fullName;
  final String primaryEmail;
  final String pinCode;
  final String dob;
  final String gender;
  final String category;
  final String mobile;
  final String group;
  final String position;

  const ProfileMandatoryDetails(
      {@required this.fullName,
      @required this.primaryEmail,
      @required this.pinCode,
      @required this.dob,
      @required this.gender,
      @required this.category,
      @required this.mobile,
      @required this.group,
      @required this.position});
}
