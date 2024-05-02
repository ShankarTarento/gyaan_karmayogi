import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/models/_models/creator_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/authors_curators.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_Program_location.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/competencies.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/course_complete_certificate.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/description_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/message_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/overview_icons.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/provider.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/ratings.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/reviews.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/start_discusion_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/summary_description.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/tags.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/_constants/storage_constants.dart';
import '../../../../index.dart';
import 'widgets/countdown.dart';

class AboutTab extends StatefulWidget {
  final dynamic courseRead;
  final List<Course> enrollmentDetails;
  final dynamic courseHierarchy;
  final bool isBlendedProgram;
  final bool highlightRating;

  AboutTab({
    Key key,
    @required this.courseRead,
    @required this.isBlendedProgram,
    @required this.enrollmentDetails,
    @required this.courseHierarchy,
    this.highlightRating = false,
  }) : super(key: key);

  final dataKey = new GlobalKey();
  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  ValueNotifier<bool> showKarmaPointClaimButton = ValueNotifier(false);
  ValueNotifier<bool> showKarmaPointCongratsMessageCard = ValueNotifier(true);
  @override
  void initState() {
    Provider.of<TocServices>(context, listen: false)
        .getCourseRating(courseDetails: widget.courseRead);
    selectedCourse = getSelectedCourse();
    if (selectedCourse != null && selectedCourse.completionPercentage == 100) {
      if (selectedCourse.raw["issuedCertificates"] != null &&
          selectedCourse.raw["issuedCertificates"].isNotEmpty) {
        certificate = _getCompletionCertificate(
            selectedCourse.raw["issuedCertificates"][0]["identifier"]);
      }
    }
    getCBPdata();
    super.initState();
  }

  @override
  void didUpdateWidget(AboutTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enrollmentDetails == null ||
        oldWidget.enrollmentDetails.isEmpty) {
      selectedCourse = getSelectedCourse();
    }
    if (selectedCourse != null && selectedCourse.completionPercentage == 100) {
      if (selectedCourse.raw["issuedCertificates"] != null &&
          selectedCourse.raw["issuedCertificates"].isNotEmpty) {
        certificate = _getCompletionCertificate(
            selectedCourse.raw["issuedCertificates"][0]["identifier"]);
      }
    }
    if (cbpList != null) {
      getCBPdata();
    }
  }

  List<CompetencyPassbook> getCompetencies() {
    List<CompetencyPassbook> competencies = [];
    if (widget.courseRead["competencies_v5"] != null) {
      for (var data in widget.courseRead["competencies_v5"]) {
        competencies.add(CompetencyPassbook.fromJson(data, "courseId"));
      }
    }
    return competencies;
  }

  List<CreatorModel> getAuthors() {
    List<CreatorModel> authors = [];

    if (widget.courseHierarchy["creatorDetails"] != null) {
      for (var author in jsonDecode(widget.courseHierarchy["creatorDetails"])) {
        authors.add(CreatorModel.fromJson(author));
      }
    } else {
      // debugPrint("authors are null");
    }
    return authors;
  }

  List<CreatorModel> getCurators() {
    List<CreatorModel> curators = [];
    if (widget.courseHierarchy["creatorContacts"] != null) {
      for (var curator
          in jsonDecode(widget.courseHierarchy["creatorContacts"])) {
        curators.add(CreatorModel.fromJson(curator));
      }
    } else {
      //  debugPrint("curators are null");
    }
    return curators;
  }

  void getCBPdata() async {
    cbpList = jsonDecode(await _storage.read(key: Storage.cbpdataInfo));
  }

  String getCBPEnddate() {
    String cbpEndDate;

    if (cbpList != null && cbpList.runtimeType != String) {
      var cbpCourse = cbpList['content'] ?? [];
      for (int index = 0; index < cbpCourse.length; index++) {
        var element = cbpCourse[index]['contentList'];
        for (int elementindex = 0;
            elementindex < element.length;
            elementindex++) {
          if (element[elementindex]['identifier'] ==
              widget.courseRead['identifier']) {
            cbpEndDate = cbpCourse[index]['endDate'];
            break;
          }
        }
      }
    }
    return cbpEndDate;
  }

  final LearnService learnService = LearnService();
//  OverallRating overallRating;
  Course selectedCourse;
  Future certificate;
  Map cbpList;
  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    if (widget.highlightRating) {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Scrollable.ensureVisible(widget.dataKey.currentContext,
              curve: Curves.easeInOutBack);
        });
      });
    }
    return SingleChildScrollView(
      // controller: context.watch<TocServices>().aboutScrollController,
      // physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          selectedCourse != null && selectedCourse.completionPercentage == 100
              ? selectedCourse.raw["issuedCertificates"] != null &&
                      selectedCourse.raw["issuedCertificates"].isNotEmpty
                  ? FutureBuilder(
                      future: certificate,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return CourseCompleteCertificate(
                              courseInfo: selectedCourse,
                              certificate: snapshot.data,
                              competencies: getCompetencies(),
                              isCertificateProvided: true);
                        } else {
                          return CourseCompleteCertificate(
                              courseInfo: selectedCourse,
                              competencies: getCompetencies(),
                              isCertificateProvided: true);
                        }
                      })
                  : CourseCompleteCertificate(
                      courseInfo: selectedCourse,
                      competencies: getCompetencies(),
                      isCertificateProvided: false)
              : SizedBox(),
          widget.isBlendedProgram
              ? Consumer<TocServices>(
                  builder: (context, tocServices, _) {
                    return tocServices.batch != null
                        ? Column(
                            children: [
                              Countdown(
                                batch: tocServices.batch,
                              ),
                              BlendedProgramDetails(
                                batch: tocServices.batch,
                              ),
                              BlendedProgramLocation(
                                selectedBatch: tocServices.batch,
                              )
                            ],
                          )
                        : SizedBox();
                  },
                )
              : SizedBox(),
          //  widget.isBlendedProgram ?  : SizedBox(),

          ValueListenableBuilder(
              valueListenable: showKarmaPointClaimButton,
              builder: (BuildContext context, bool value, Widget child) {
                return value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClaimKarmaPoints(
                          courseId: widget.courseRead['identifier'],
                          claimedKarmaPoint: (bool value) {
                            showKarmaPointCongratsMessageCard.value = true;
                            showKarmaPointClaimButton.value = false;
                          },
                        ),
                      )
                    : Center();
              }),
          SizedBox(
            height: 10,
          ),
          widget.courseHierarchy != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OverviewIcons(
                    duration: widget.courseRead["duration"],
                    course: widget.courseHierarchy,
                    cbpDate: getCBPEnddate(),
                    courseDetails: widget.courseRead,
                  ),
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SummaryWidget(
              details: widget.courseRead['description'] != null
                  ? widget.courseRead['description']
                  : "",
              title: AppLocalizations.of(context).mStaticSummary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DescriptionWidget(
              course: widget.courseRead,
              details: widget.courseRead['instructions'] != null
                  ? widget.courseRead['instructions']
                  : "",
              title: AppLocalizations.of(context).mStaticDescription,
            ),
          ),
          widget.courseRead["competencies_v5"] != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
                  child: Competencies(
                    competencies: getCompetencies(),
                  ),
                )
              : SizedBox(),
          widget.courseHierarchy != null &&
                  widget.courseHierarchy["keywords"] != null &&
                  widget.courseHierarchy["keywords"].isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Tags(
                    keywords: widget.courseHierarchy["keywords"],
                  ),
                )
              : SizedBox(),
          selectedCourse != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
                  child: ValueListenableBuilder(
                      valueListenable: showKarmaPointCongratsMessageCard,
                      builder:
                          (BuildContext context, bool value, Widget child) {
                        return MessageCards(
                          course: widget.courseRead,
                          showCourseCongratsMessage:
                              showKarmaPointCongratsMessageCard.value,
                          showKarmaPointClaimButton: (bool value) {
                            showKarmaPointClaimButton.value = value;
                            showKarmaPointCongratsMessageCard.value = false;
                          },
                        );
                      }),
                )
              : Center(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AuthorsCurators(
              curators: getCurators(),
              authors: getAuthors(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CourseProvider(
              courseDetails: widget.courseRead,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StartDiscussionCard(),
          ),
          Consumer<TocServices>(
            builder: (context, toc, child) {
              return Container(
                color: Color(0xff1B4CA1).withOpacity(0.18),
                child: Column(
                  children: [
                    Ratings(
                      ratingAndReview: toc.overallRating,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Reviews(
                      reviewAndRating: toc.overallRating,
                      course: widget.courseRead,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            key: widget.dataKey,
            height: 200,
          )
        ],
      ),
    );
  }

  Course getSelectedCourse() {
    return widget.enrollmentDetails.firstWhere(
      (element) =>
          element.raw["content"]["identifier"] ==
          widget.courseRead["identifier"],
      orElse: () => null,
    );
  }

  Future<dynamic> _getCompletionCertificate(dynamic certificateId) async {
    final certificate =
        await LearnService().getCourseCompletionCertificate(certificateId);
    return certificate;
  }
}
