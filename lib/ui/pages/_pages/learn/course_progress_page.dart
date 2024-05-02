import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../constants/index.dart';
import '../../../../models/index.dart';
import '../../../widgets/index.dart';
import '../../index.dart';

class CourseProgressPage extends StatefulWidget {
  final bool completed;
  final List<Course> courses;
  const CourseProgressPage(this.completed, {Key key, this.courses})
      : super(key: key);

  @override
  _CourseProgressPageState createState() => _CourseProgressPageState();
}

class _CourseProgressPageState extends State<CourseProgressPage> {
  final service = HttpClient();
  int pageNo = 1;
  int pageCount;
  int currentPage;

  List<Course> completedCourse = [];
  List<Course> inprogressCourse = [];

  @override
  void initState() {
    super.initState();
    _getContinueLearningCourses();
  }

  Future<dynamic> _getContinueLearningCourses() async {
    try {
      completedCourse = [];
      inprogressCourse = [];
      if (widget.courses != null) {
        widget.courses.forEach((course) {
          if (widget.completed) {
            if (course.raw['completionPercentage'] == 100) {
              completedCourse.add(course);
            }
          } else {
            if (course.raw['completionPercentage'] != 100) {
              inprogressCourse.add(course);
            }
          }
        });
      }
      return widget.courses;
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ((widget.completed && completedCourse.isNotEmpty) ||
                (!widget.completed && inprogressCourse.isNotEmpty))
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: widget.completed
                          ? completedCourse.length
                          : inprogressCourse.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.grey08, width: 1),
                                      color: Colors.white,
                                    ),
                                    child: CourseProgressCard(
                                        widget.completed
                                            ? completedCourse[index]
                                            : inprogressCourse[index],
                                        continueLearningCourse: widget.completed
                                            ? completedCourse
                                            : inprogressCourse,
                                        completed: widget.completed),
                                  ),
                                ),
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              )
            : NoDataWidget(isCompleted: widget.completed, paddingTop: 125),
      ),
    );
  }
}
