import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

class TocServices extends ChangeNotifier {
  Batch _batch;
  List data;
  final LearnService learnService = LearnService();
  OverallRating _overallRating;
  double _courseProgress;
  
  Batch get batch => _batch;

  double get courseProgress => _courseProgress;
  OverallRating get overallRating => _overallRating;
  
  setBatchDetails({@required Batch selectedBatch}) async {
    data = [];

    _batch = selectedBatch;

    notifyListeners();
  }

  DateTime getBatchStartTime() {
    if (batch != null) {
      return DateTime.parse(batch.startDate);
    }
  }

  String getButtonTitle({
    @required List<Course> enrollmentData,
    @required String courseId,
  }) {
    Course course = enrollmentData.firstWhere(
        (element) => element.raw["courseId"] == courseId,
        orElse: () => null);

    if (course != null) {
      if (course.completionPercentage == 100) {
        return "Start again";
      } else if (course.completionPercentage == 0) {
        return "Start";
      } else if (course.completionPercentage > 0 &&
          course.completionPercentage < 100) {
        return "Resume";
      }
    } else {
      return "Enroll";
    }
    return "Enroll";
  }

  void setInitialBatch(
      {List<Batch> batches, List enrollmentList, String courseId}) {
    var approvedCourse = enrollmentList.firstWhere(
      (element) => element.raw["content"]["identifier"] == courseId,
      orElse: () => null,
    );

    if (approvedCourse != null) {
      //  print(approvedBlendedCourse);

      Batch approvedBatch = batches.firstWhere(
          (element) => element.id == approvedCourse.raw["batch"]["identifier"]);
      _batch = approvedBatch;
      setBatchDetails(selectedBatch: _batch);
    } else {
      try {
        DateTime now = DateTime.now();
        _batch = batches.fold(null, (closest, current) {
          DateTime startDate = DateTime.parse(current.startDate);
          if (startDate.isAfter(now) &&
              (closest == null ||
                  startDate.isBefore(DateTime.parse(closest.startDate)))) {
            return current;
          }
          return closest;
        });
        if (_batch != null) {
          setBatchDetails(selectedBatch: _batch);
        }
      } catch (e) {
        _batch = null;
      }
    }

    notifyListeners();
  }

  void setCourseProgress(double progress) {
    if (_courseProgress == null || _courseProgress < progress) {
      _courseProgress = progress;
      notifyListeners();
    }
  }

  void getCourseRating({@required Map<String, dynamic> courseDetails}) async {
    _overallRating = null;
    final response = await learnService.getCourseReviewSummery(
        courseDetails['identifier'], courseDetails['primaryCategory']);

    if (response != null) {
      _overallRating = OverallRating.fromJson(response);
    }

    notifyListeners();
  }


  void clearCourseProgress() {
    _courseProgress = null;
    notifyListeners();
  }
}
