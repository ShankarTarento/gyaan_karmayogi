import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../util/helper.dart';

class TocHelper {
  Future<Course> checkIsCoursesInProgress(
      {List<Course> enrolmentList,
      String courseId,
      BuildContext context}) async {
    var enrolledCourse =
        checkCourseEnrolled(id: courseId, enrolmentList: enrolmentList);
    if (enrolledCourse != null &&
        enrolledCourse.raw['lastReadContentId'] != null &&
        enrolledCourse.raw['status'] != 2) {
      var response = await getCourseInfo(courseId, context);
      Course courseInfo = Course.fromJson(response);
      if (courseInfo.raw['courseCategory'] ==
          PrimaryCategory.moderatedProgram) {
        if (isProgramLive(enrolledCourse)) {
          return enrolledCourse;
        } else {
          return null;
        }
      } else if (courseInfo.raw['courseCategory'] ==
          PrimaryCategory.blendedProgram) {
        if (isProgramLive(enrolledCourse)) {
          return enrolledCourse;
        } else {
          return null;
        }
      } else if (isInviteOnlyProgram(courseInfo)) {
        if (isProgramLive(enrolledCourse)) {
          return enrolledCourse;
        } else {
          return null;
        }
      } else {
        return enrolledCourse;
      }
    }
    return null;
  }

  dynamic checkCourseEnrolled({String id, List<Course> enrolmentList}) {
    if (enrolmentList == null && enrolmentList.isEmpty) {
      return null;
    } else {
      return enrolmentList.firstWhere(
        (element) => element.raw['contentId'] == id,
        orElse: () => null,
      );
    }
  }

  // Content read api - To get all course details including batch info
  Future<dynamic> getCourseInfo(String courseId, BuildContext context) async {
    return await Provider.of<LearnRepository>(context, listen: false)
        .getCourseData(courseId);
  }

  isInviteOnlyProgram(Course courseInfo) {
    return courseInfo.raw["batches"] != null &&
        courseInfo.raw["batches"].isNotEmpty &&
        courseInfo.raw["batches"][0]["enrollmentType"] == "invite-only";
  }

  bool isProgramLive(enrolledCourse) {
    if ((DateTime.parse(enrolledCourse.raw['batch']['startDate'])
                .isAfter(DateTime.now()) &&
            Helper.getDateTimeInFormat(
                    enrolledCourse.raw['batch']['startDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString())) ||
        (enrolledCourse.raw['batch']['endDate'] != null &&
            DateTime.parse(enrolledCourse.raw['batch']['endDate'])
                .isBefore(DateTime.now()) &&
            Helper.getDateTimeInFormat(
                    enrolledCourse.raw['batch']['endDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString()))) {
      return false;
    } else {
      return true;
    }
  }

  bool checkInviteOnlyProgramIsActive(
      Course courseDetails, Course enrolledCourse) {
    if (courseDetails.raw["batches"] != null &&
        courseDetails.raw["batches"].isNotEmpty &&
        courseDetails.raw["batches"][0]["enrollmentType"] == "invite-only") {
      if (enrolledCourse != null) {
        if (DateTime.parse(enrolledCourse.raw["batch"]["startDate"])
            .isAfter(DateTime.now())) {
          return false;
        } else if (DateTime.parse(enrolledCourse.raw["batch"]["startDate"])
                .isBefore(DateTime.now()) &&
            DateTime.parse(enrolledCourse.raw["batch"]["endDate"])
                .isAfter(DateTime.now())) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (courseDetails.raw["batches"] != null &&
        courseDetails.raw["batches"].isNotEmpty &&
        courseDetails.raw["batches"][0]["enrollmentType"] == 'open' &&
        enrolledCourse != null) {
      return true;
    } else {
      return false;
    }
  }
}
