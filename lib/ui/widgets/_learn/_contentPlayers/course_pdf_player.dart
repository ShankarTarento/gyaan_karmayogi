import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/index.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import './../../../../services/index.dart';
import './../../../../constants/index.dart';
import './../../../widgets/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';

class CoursePdfPlayer extends StatefulWidget {
  final course;
  final String identifier;
  final String fileUrl;
  final currentProgress;
  final status;
  final String batchId;
  final ValueChanged<bool> parentAction1;
  final ValueChanged<Map> parentAction2;
  final bool isFeaturedCourse;
  final updateProgress;
  final String primaryCategory;
  final String parentCourseId;
  final ValueChanged<bool> playNextResource;
  // final bool isCuratedProgram;

  CoursePdfPlayer(
      {this.course,
      this.identifier,
      this.parentCourseId,
      this.fileUrl,
      this.currentProgress,
      this.status,
      this.batchId,
      this.parentAction1,
      this.parentAction2,
      this.isFeaturedCourse,
      this.updateProgress,
      this.primaryCategory,
      this.playNextResource
      // this.isCuratedProgram = false
      });

  @override
  _CoursePdfPlayerState createState() => _CoursePdfPlayerState();
}

class _CoursePdfPlayerState extends State<CoursePdfPlayer> {
  final LearnService learnService = LearnService();
  final TelemetryService telemetryService = TelemetryService();
  bool _isLoading = true;
  PDFDocument document;
  PageController _pageController;
  int _currentProgress;
  List<String> current = [];
  bool _fullScreen = false;
  String _identifier;
  ValueNotifier<int> _currentPage = ValueNotifier(-1);
  int _totalPages;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  Timer _timer;
  int _start = 0;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  String deviceIdentifier;
  String env;
  var telemetryEventData;
  ValueNotifier<bool> isCompleted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    loadDocument();
    _identifier = widget.identifier;
    _triggerTelemetryData();
  }

  @override
  void didUpdateWidget(CoursePdfPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier) {
      _triggerEndTelemetryData(_identifier);
      _start = 0;
      _identifier = widget.identifier;
      _triggerTelemetryData();
      setState(() => _isLoading = true);
      loadDocument();
    }
  }

  _triggerTelemetryData() {
    if (_start == 0) {
      pageIdentifier = TelemetryPageIdentifier.pdfPlayerPageId;
      telemetryType = TelemetryType.player;
      var batchId = widget.course['batches'] != null
          ? (widget.course['batches'].runtimeType == String
              ? jsonDecode(widget.course['batches'][0]['batchId'])
              : widget.course['batches'][0]['batchId'])
          : '';
      pageUri =
          'viewer/pdf/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
      _generateTelemetryData();
      _startTimer();
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeaturedCourse);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId =
        await Telemetry.getUserDeptId(isPublic: widget.isFeaturedCourse);

    Map eventData1 = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
    Map eventData2 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
    allEventsData.add(eventData1);
    allEventsData.add(eventData2);
    // await telemetryService.triggerEvent(allEventsData);
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = ''}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.learn,
        objectType: widget.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    allEventsData.add(eventData);
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
      widget.fileUrl,
    );
    _totalPages = document.count;
    _currentProgress = int.parse(widget.currentProgress.toString());
    _pageController = PageController(
      initialPage: _currentProgress == 0 ||
              _currentProgress == _totalPages ||
              widget.status == 2
          ? 0
          : _currentProgress - 1, // first page number in the initializer
    );
    _currentPage.value = _pageController.initialPage + 1;
    isCompleted.value = _currentProgress == _totalPages || widget.status == 2;
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateContentProgress(
    int currentPage,
    int totalPages,
  ) async {
    if (widget.batchId != null &&
        !widget.isFeaturedCourse &&
        (int.parse(widget.currentProgress.toString()) < currentPage ||
            currentPage == 0) &&
        widget.status != 2) {
      if (currentPage == 0) {
        currentPage = 1;
      }
      currentPage = currentPage <= totalPages ? currentPage : totalPages;
      current.add((currentPage).toString());
      String courseId = widget.parentCourseId;
      String batchId = widget.batchId;
      String contentId = widget.identifier;
      int status = widget.status != 2
          ? currentPage == totalPages
              ? 2
              : 1
          : 2;
      String contentType = EMimeTypes.pdf;
      var maxSize = totalPages;
      double completionPercentage = currentPage / totalPages * 100;
      await learnService.updateContentProgress(courseId, batchId, contentId,
          status, contentType, current, maxSize, completionPercentage);

      widget.updateProgress({
        'identifier': widget.identifier,
        'mimeType': EMimeTypes.pdf,
        'current': (currentPage).toString(),
        'completionPercentage': completionPercentage / 100
      });
    }
  }

  _triggerEndTelemetryData(String identifier) async {
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        _start,
        telemetryType,
        pageUri,
        {},
        objectId: identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
    _timer.cancel();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_currentPage.value != null && _currentPage.value >= 0) {
        if (!widget.isFeaturedCourse) {
          await _updateContentProgress(_currentPage.value, _totalPages);
        }
      }
      await _triggerEndTelemetryData(widget.identifier);
      _pageController?.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? PageLoader()
          : Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  top: MediaQuery.of(context).padding.top,
                  child: PDFViewer(
                    document: document,
                    controller: _pageController,
                    zoomSteps: 1,
                    showPicker: _fullScreen,
                    scrollDirection: Axis.vertical,
                    showIndicator: false,
                    onPageChanged: (value) async {
                      print(value);
                      if (int.parse(widget.currentProgress.toString()) == 0 ||
                          int.parse(widget.currentProgress.toString()) >
                              _totalPages) {
                        _currentPage.value = value;
                      } else {
                        _currentPage.value = value + 1;
                      }
                      if (_currentPage.value == _totalPages) {
                        isCompleted.value = true;
                        await _updateContentProgress(
                            _currentPage.value, _totalPages);
                      }
                    },
                    navigationBuilder:
                        (context, page, totalPages, jumpToPage, animateToPage) {
                      _totalPages = totalPages;
                      return Container(
                        color: AppColors.appBarBackground,
                        height: 60,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: _currentPage.value != 1
                                    ? InkWell(
                                        onTap: () {
                                          animateToPage(page: page - 2);
                                          _currentPage.value = page - 1;
                                          _generateInteractTelemetryData(
                                              widget.identifier,
                                              subType: TelemetrySubType
                                                  .previousPageButton);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .mStaticPrevious,
                                            style: GoogleFonts.lato(
                                                color: AppColors.darkBlue,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                letterSpacing: 0.25,
                                                height: 1.429),
                                          ),
                                        ))
                                    : SizedBox()),
                            Expanded(
                              flex: 2,
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: isCompleted,
                                  builder: (context, completionValue, child) {
                                    return completionValue
                                        ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.done,
                                                size: 24,
                                                color: AppColors.darkBlue,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .mCommoncompleted,
                                                style: GoogleFonts.lato(
                                                    color: AppColors.darkBlue,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    letterSpacing: 0.25,
                                                    height: 1.429),
                                              ),
                                            ],
                                          )
                                        : Center(
                                          child: InkWell(
                                              onTap: () async {
                                                _generateInteractTelemetryData(
                                                    widget.identifier,
                                                    subType: TelemetrySubType
                                                        .markAsCompletePageButton);
                                                if (!widget.isFeaturedCourse) {
                                                  await _updateContentProgress(
                                                      totalPages, totalPages);
                                                  widget.playNextResource(true);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(63),
                                                    border: Border.all(
                                                        color:
                                                            AppColors.darkBlue)),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .mMarkAsComplete,
                                                  style: GoogleFonts.lato(
                                                      color: AppColors.darkBlue,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                      letterSpacing: 0.25,
                                                      height: 1.429),
                                                ),
                                              )),
                                        );
                                  }),
                            ),
                            Expanded(
                                flex: 1,
                                child: _currentPage.value != totalPages
                                    ? Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                          onTap: () async {
                                            animateToPage(page: page);
                                            if (totalPages < _currentPage.value) {
                                              _currentPage.value = page + 1;
                                              _generateInteractTelemetryData(
                                                  widget.identifier,
                                                  subType: TelemetrySubType
                                                      .nextPageButton);
                                              if (!widget.isFeaturedCourse) {
                                                await _updateContentProgress(
                                                    _currentPage.value,
                                                    _totalPages);
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Text(
                                              AppLocalizations.of(context).mNext,
                                              style: GoogleFonts.lato(
                                                  color: AppColors.darkBlue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  letterSpacing: 0.25,
                                                  height: 1.429),
                                            ),
                                          )),
                                    )
                                    : Center()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: AppColors.greys60),
                    child: ValueListenableBuilder(
                        valueListenable: _currentPage,
                        builder: (context, value, child) {
                          return Text(
                            '$value of $_totalPages',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: AppColors.appBarBackground,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.25),
                          );
                        }),
                  ),
                ),
              ],
            ),
    );
  }
}
