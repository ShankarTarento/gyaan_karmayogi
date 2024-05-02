import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class OverviewIcons extends StatefulWidget {
  final Map<String, dynamic> course;
  final String duration;
  final String cbpDate;
  final Map<String, dynamic> courseDetails;
  const OverviewIcons(
      {Key key,
      @required this.course,
      @required this.courseDetails,
      @required this.duration,
      @required this.cbpDate})
      : super(key: key);

  @override
  State<OverviewIcons> createState() => _OverviewIconsState();
}

class _OverviewIconsState extends State<OverviewIcons> {
  @override
  void initState() {
    if (widget.course['children'] != null) {
      for (int i = 0; i < widget.course['children'].length; i++) {
        if (widget.course['children'][i]['contentType'] == 'Course') {
          structure['course'] += 1;
          // structure['module'] += 1;
          countArtifacts(widget.course['children'][i]);
        } else if (widget.course['children'][i]['contentType'] ==
                'Collection' ||
            widget.course['children'][i]['contentType'] == 'CourseUnit') {
          // structure['learningModule '] += 1;
          structure['module'] += 1;
          countArtifacts(widget.course['children'][i]);
        } else {
          if (widget.course['children'][i]['mimeType'] != null) {
            switch (widget.course['children'][i]['mimeType'].trim()) {
              case EMimeTypes.mp4:
                structure['video'] += 1;
                break;
              case EMimeTypes.pdf:
                structure['pdf'] += 1;
                break;
              case EMimeTypes.assessment:
                structure['assessment'] += 1;
                break;
              case EMimeTypes.collection:
                structure['module'] += 1;
                break;
              case EMimeTypes.html:
                structure['html'] += 1;
                break;
              case EMimeTypes.mp3:
                structure['audio'] += 1;
                break;
              case EMimeTypes.offline:
                structure['offlineSession'] += 1;
                break;
              case EMimeTypes.externalLink:
                structure['externalLink'] += 1;
                break;
              case EMimeTypes.newAssessment:
                widget.course['children'][i]['primaryCategory'] ==
                        PrimaryCategory.practiceAssessment
                    ? structure['practiceTest'] += 1
                    : structure['finalTest'] += 1;
                break;
              default:
                structure['other'] += 1;
                break;
            }
          }
        }
      }
    }
    super.initState();
  }

  void countArtifacts(children) {
    if (children['children'] != null) {
      for (int i = 0; i < children['children'].length; i++) {
        switch (children['children'][i]['mimeType']) {
          case EMimeTypes.mp4:
            structure['video'] += 1;
            break;
          case EMimeTypes.pdf:
            structure['pdf'] += 1;
            break;
          case EMimeTypes.assessment:
            structure['assessment'] += 1;
            break;
          case EMimeTypes.collection:
            structure['module'] += 1;
            countArtifacts(children['children'][i]);
            break;
          case EMimeTypes.html:
            structure['html'] += 1;
            break;
          case EMimeTypes.mp3:
            structure['audio'] += 1;
            break;
          case EMimeTypes.offline:
            structure['offlineSession'] += 1;
            break;
          case EMimeTypes.externalLink:
            structure['externalLink'] += 1;
            break;
          case EMimeTypes.newAssessment:
            children['children'][i]['primaryCategory'] ==
                    PrimaryCategory.practiceAssessment
                ? structure['practiceTest'] += 1
                : structure['finalTest'] += 1;
            break;
          default:
            structure['other'] += 1;
            break;
        }
      }
    }
  }

  Map structure = {
    'video': 0,
    'pdf': 0,
    'assessment': 0,
    'Session': 0,
    'module': 0,
    'other': 0,
    'html': 0,
    'course': 0,
    'practiceTest': 0,
    'finalTest': 0,
    'audio': 0,
    'externalLink': 0,
    'offlineSession': 0,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 55,
        child: Row(children: [
          widget.cbpDate != null
              ? cbpEnddateWidget(text1: "test", text2: "test")
              : SizedBox(),
          widget.duration != null && calculateDuration() != "0 m"
              ? detailsWidget(
                  imagepath: 'assets/img/clock_white.svg',
                  title: calculateDuration())
              : Center(),
          structure['course'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/course_icon.svg',
                  title: structure['course'].toString() +
                      (structure['course'] == 1 ? ' Course' : ' Courses'))
              : Center(),
          structure['module'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-module.svg',
                  title: structure['module'].toString() +
                      (structure['module'] == 1 ? ' Module' : ' Modules'))
              : Center(),
          structure['offlineSession'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-module.svg',
                  title: structure['offlineSession'].toString() +
                      (structure['offlineSession'] == 1
                          ? ' Session'
                          : ' Sessions'))
              : Center(),
          structure['video'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-av-play.svg',
                  title: structure['video'].toString() +
                      (structure['video'] == 1 ? ' Video' : ' Videos'))
              : Center(),
          structure['pdf'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-pdf-alternate.svg',
                  title: structure['pdf'].toString() +
                      (structure['pdf'] == 1 ? ' PDF' : ' PDFs'))
              : Center(),
          structure['audio'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/audio.svg',
                  title: structure['audio'].toString() +
                      (structure['audio'] == 1 ? ' Audio' : ' Audios'))
              : Center(),
          structure['assessment'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['assessment'].toString() +
                      (structure['assessment'] == 1
                          ? ' Assessment'
                          : ' Assessments'))
              : Center(),
          structure['externalLink'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/web_page.svg',
                  title: structure['externalLink'].toString() +
                      (structure['externalLink'] == 1
                          ? ' Web page'
                          : ' Web pages'))
              : Center(),
          structure['html'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/link.svg',
                  title: structure['html'].toString() +
                      (structure['html'] == 1
                          ? ' Interactive Content'
                          : ' Interactive Contents'))
              : Center(),
          structure['practiceTest'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['practiceTest'].toString() +
                      (structure['practiceTest'] == 1
                          ? ' Practice test'
                          : ' Practice tests'))
              : Center(),
          structure['finalTest'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['finalTest'].toString() +
                      (structure['finalTest'] == 1
                          ? ' Final test'
                          : ' Final tests'))
              : Center(),
          widget.courseDetails["learningMode"] != null
              ? detailsWidget(
                  imagepath: 'assets/img/instructor_led.svg',
                  title: widget.courseDetails["learningMode"])
              : Center(),
          widget.course["license"] != null
              ? detailsWidget(
                  imagepath: 'assets/img/key.svg',
                  title: widget.course["license"],
                )
              : Center(),
          detailsWidget(
            imagepath: 'assets/img/rupee.svg',
            title: "Free",
          )
        ]),
      ),
    );
  }

  Widget detailsWidget({@required String title, @required String imagepath}) {
    return Container(
      height: 60,
      width: 64,
      margin: const EdgeInsets.only(right: 24.0),
      child: Column(
        children: [
          SvgPicture.asset(
            imagepath,
            alignment: Alignment.center,
            height: 20,
            width: 20,
            color: Color(0xff1B4CA1),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  String calculateDuration() {
    int durationInMinutes = int.parse(widget.duration) ~/ 60.toInt();

    int hours = (durationInMinutes ~/ 60).toInt();
    int remainingMinutes = durationInMinutes % 60;
    if (hours > 0) {
      if (remainingMinutes > 0) {
        return '$hours h $remainingMinutes m';
      } else {
        return '$hours h';
      }
    } else {
      return '$remainingMinutes m';
    }
  }

  Widget cbpEnddateWidget({text1, text2}) {
    int dateDiff = getTimeDiff(widget.cbpDate);
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppColors.darkBlue,
            size: 20,
          ),
          Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                  color: dateDiff < 0
                      ? AppColors.negativeLight
                      : dateDiff < 30
                          ? AppColors.verifiedBadgeIconColor
                          : AppColors.positiveLight,
                  borderRadius: BorderRadius.all(const Radius.circular(4.0))),
              child: Text(
                Helper.getDateTimeInFormat(widget.cbpDate,
                    desiredDateFormat: IntentType.dateFormat2),
                style: GoogleFonts.lato(
                    decoration: TextDecoration.none,
                    color: AppColors.appBarBackground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ))
        ]));
  }

  int getTimeDiff(String date1) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .inDays;
  }
}
