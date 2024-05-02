import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_attributes_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/session_details.dart';

class LedByInstructor extends StatefulWidget {
  final Batch batch;
  final Map<String, dynamic> courseDetails;
  final List<Course> enrollmentList;
  const LedByInstructor(
      {Key key,
      @required this.batch,
      @required this.courseDetails,
      @required this.enrollmentList})
      : super(key: key);

  @override
  State<LedByInstructor> createState() => _LedByInstructorState();
}

class _LedByInstructorState extends State<LedByInstructor> {
  bool isExpanded = false;
  BatchAttributes selectedBatchAttributes;
  List<SessionDetailsV2> sessionList;
  final LearnService learnService = LearnService();

  @override
  void initState() {
    getBatchAttributes();
    _readContentProgress(
        widget.batch.batchId, widget.courseDetails["identifier"]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.batch != null
        ? SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(color: AppColors.appBarBackground),
              margin: EdgeInsets.only(
                top: 16,
              ),
              child: ExpansionTile(
                onExpansionChanged: (value) {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: EdgeInsets.only(bottom: 50),
                initiallyExpanded: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        courseTypeButton(title: "Offline"),
                        SizedBox(
                          width: 8,
                        ),
                        courseTypeButton(title: "Online"),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.batch.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greys87,
                      ),
                    )
                  ],
                ),
                trailing: !isExpanded
                    ? Icon(
                        Icons.arrow_drop_up,
                        color: AppColors.darkBlue,
                      )
                    : Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.darkBlue,
                      ),
                children: [
                  ...List.generate(
                      selectedBatchAttributes != null
                          ? selectedBatchAttributes.sessionDetailsV2.length
                          : 0,
                      (index) => SessionDetails(
                            enrollmentList: widget.enrollmentList,
                            selectedBatchAttributes: selectedBatchAttributes,
                            batch: widget.batch,
                            courseDetails: widget.courseDetails,
                            session: sessionList[index],
                            onAttendanceMarked: () {
                              _readContentProgress(widget.batch.batchId,
                                  widget.courseDetails["identifier"]);
                            },
                          )),
                  SizedBox(
                    height: 200,
                  )
                ],
              ),
            ),
          )
        : SizedBox();
  }

  Widget courseTypeButton({@required String title}) {
    return Container(
      height: 16,
      width: 37,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: title.toLowerCase() == "online"
            ? AppColors.positiveLight
            : AppColors.greys60,
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  getBatchAttributes() {
    List batches = widget.courseDetails["batches"];
    if (widget.batch != null) {
      Map<String, dynamic> batch = batches.firstWhere(
        (element) => element["batchId"] == widget.batch.id,
        orElse: () => null,
      );
      if (batch != null) {
        selectedBatchAttributes =
            BatchAttributes.fromJson(batch["batchAttributes"]);
        sessionList = selectedBatchAttributes.sessionDetailsV2;
        if (sessionList.isNotEmpty) {
          // getLiveSessionIds();
        }
        setState(() {});
      }
    }
  }

  Future<void> _readContentProgress(batchId, courseId) async {
    var response = await learnService.readContentProgress(courseId, batchId);
    if (response['result']['contentList'] != null) {
      var contentProgressList = response['result']['contentList'];
      if (contentProgressList != null) {
        for (int i = 0; i < contentProgressList.length; i++) {
          if (contentProgressList[i]['progress'] == 100 &&
              contentProgressList[i]['status'] == 2) {
            //  print(contentProgressList[i]["lastCompletedTime"]);
            //    print(contentProgressList);
            sessionList = sessionList.map((element) {
              if (element.sessionId == contentProgressList[i]['contentId']) {
                element.sessionAttendanceStatus = true;
                element.lastCompletedTime =
                    contentProgressList[i]['lastCompletedTime'];
              }
              return element;
            }).toList();
          }
        }
      }
    }
    setState(() {});
  }
}
