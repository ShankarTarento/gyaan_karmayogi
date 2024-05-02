import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/index.dart';
import '../../../../respositories/_respositories/learn_repository.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import '../../../skeleton/index.dart';
import '../../../widgets/index.dart';
import '../../index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyLearningPage extends StatefulWidget {
  final int index;
  final Profile profileInfo;
  final profileParentAction;
  final tabIndex;
  const MyLearningPage(
      {Key key,
      this.index,
      this.profileInfo,
      this.profileParentAction,
      this.tabIndex})
      : super(key: key);

  @override
  _MyLearningPageState createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
        length: 2,
        vsync: this,
        initialIndex: widget.tabIndex != null ? widget.tabIndex : 0);
    if (widget.index == 3) {
      _getContinueLearningCourses();
      _generateTelemetryData();
    }
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.myLearnings,
        userSessionId,
        messageIdentifier,
        TelemetryType.app,
        TelemetryPageIdentifier.myLearnings,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String primaryCategory,
      bool isObjectNull = false}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.myLearnings,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType));
    print(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _triggerInteractTelemetryData(int index) {
    if (index == 0) {
      _generateInteractTelemetryData(TelemetrySubType.inProgress,
          subType: TelemetrySubType.myLearning, isObjectNull: true);
    } else if (index == 1) {
      _generateInteractTelemetryData(TelemetrySubType.completed,
          subType: TelemetrySubType.myLearning, isObjectNull: true);
    }
  }

  void switchIntoYourLearningTab() {
    setState(() {
      _controller.index = 1;
    });
  }

  Future<dynamic> _getContinueLearningCourses() async {
    try {
      await Provider.of<LearnRepository>(context, listen: false)
          .getContinueLearningCourses();
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [
      AppLocalizations.of(context).mLearnYourProgress,
      AppLocalizations.of(context).mCommoncompleted
    ];

    return Scaffold(
        body: SafeArea(
            child: NestedScrollView(headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        widget.index != 0
            ? HomeAppBarNew(
                profileInfo: widget.profileInfo,
                index: widget.index,
                profileParentAction: widget.profileParentAction)
            : SliverAppBar(),
        SliverPersistentHeader(
          delegate: SilverAppBarDelegate(
            TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.darkBlue,
                    width: 2.0,
                  ),
                ),
              ),
              indicatorColor: Colors.white,
              labelPadding: EdgeInsets.only(top: 0.0),
              unselectedLabelColor: AppColors.greys60,
              labelColor: AppColors.darkBlue,
              labelStyle: GoogleFonts.lato(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.lato(
                fontSize: 10.0,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                for (var tabItem in tabs)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          tabItem,
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
              controller: _controller,
              onTap: (value) =>
                  _triggerInteractTelemetryData(_controller.index),
            ),
          ),
          pinned: true,
          floating: false,
        ),
      ];
    }, body: Consumer<LearnRepository>(builder: (context, learnRepository, _) {
      final enrolledCourseList = learnRepository.enrolledCourseList;
      if (enrolledCourseList != null) {
        return enrolledCourseList.runtimeType == String
            ? Center()
            : enrolledCourseList != null && enrolledCourseList.length > 0
                ? TabBarView(
                    controller: _controller,
                    children: [
                      CourseProgressPage(false, courses: enrolledCourseList),
                      CourseProgressPage(true, courses: enrolledCourseList)
                    ],
                  )
                : TabBarView(
                    controller: _controller,
                    children: [
                      NoDataWidget(isCompleted: false, paddingTop: 125),
                      NoDataWidget(isCompleted: true, paddingTop: 125)
                    ],
                  );
      } else {
        return Container(
          child: ListView.separated(
            itemBuilder: (context, index) => CourseProgressSkeletonPage(),
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemCount: 3,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        );
      }
    }))));
  }
}
