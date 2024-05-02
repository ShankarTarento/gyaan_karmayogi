import 'dart:async';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_resource_details.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';

class CoursePdfPlayer extends StatefulWidget {
  String pdfUrl;
  ResourceDetails resourceDetails;
  final Map<String, dynamic> translatedWords;

  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;

  CoursePdfPlayer({
    this.pdfUrl,
    @required this.resourceDetails,
    @required this.translatedWords,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
  });

  @override
  _CoursePdfPlayerState createState() => _CoursePdfPlayerState();
}

class _CoursePdfPlayerState extends State<CoursePdfPlayer> {
  bool _isLoading = true;
  PDFDocument document;
  PageController _pageController;

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
  ValueNotifier<bool> isCompleted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  @override
  void didUpdateWidget(CoursePdfPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    loadDocument();
  }

  triggerTelemetryEvent() {
    if (_start == 0) {
      pageUri =
          'viewer/pdf/${widget.resourceDetails.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.resourceDetails.identifier}&collectionType=Course&batchId=';
      widget.contentStartTelemetry({"pageUri": pageUri});
    }

    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
      widget.pdfUrl,
    );
    _totalPages = document.count;

    _pageController = PageController(initialPage: 0);
    _currentPage.value = _pageController.initialPage + 1;

    if (mounted) {
      setState(() => _isLoading = false);
    }
    triggerTelemetryEvent();
  }

  @override
  void dispose() async {
    _pageController.dispose();
    widget.contentEndTelemetry({"pageUri": pageUri, "time": _start});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppColors.appBarBackground,
                pinned: false,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.greys60,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                // expandedHeight: 112,
                flexibleSpace: Center(
                  child: Text(
                    "PDF",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25),
                  ),
                ),
              ),
            ];
          },
          body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
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
                            // if (value
                            //         _totalPages) {
                            _currentPage.value = value + 1;
                            // } else {
                            //   _currentPage.value = value + 1;
                            // }
                            // if (_currentPage.value == _totalPages) {
                            //   isCompleted.value = true;

                            // }
                          },
                          navigationBuilder: (context, page, totalPages,
                              jumpToPage, animateToPage) {
                            _totalPages = totalPages;
                            return Container(
                              color: AppColors.appBarBackground,
                              height: 60,
                              child: ButtonBar(
                                alignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _currentPage.value != 1
                                      ? InkWell(
                                          onTap: () {
                                            animateToPage(page: page - 2);
                                            _currentPage.value = page - 1;
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Text(
                                              widget.translatedWords[
                                                      "previous"] ??
                                                  "Previous",
                                              style: GoogleFonts.lato(
                                                  color: AppColors.darkBlue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  letterSpacing: 0.25,
                                                  height: 1.429),
                                            ),
                                          ))
                                      : Center(),
                                  _currentPage.value != totalPages ||
                                          _currentPage.value == totalPages
                                      ? InkWell(
                                          onTap: () async {
                                            if (_currentPage.value ==
                                                totalPages) {
                                              Navigator.pop(context);
                                            } else {
                                              animateToPage(page: page);
                                              if (totalPages <=
                                                  _currentPage.value) {
                                                _currentPage.value = page + 1;
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Text(
                                              _currentPage.value == totalPages
                                                  ? widget.translatedWords[
                                                          "finish"] ??
                                                      "Finish"
                                                  : widget.translatedWords[
                                                          "next"] ??
                                                      "Next",
                                              style: GoogleFonts.lato(
                                                  color: AppColors.darkBlue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  letterSpacing: 0.25,
                                                  height: 1.429),
                                            ),
                                          ))
                                      : const Center(),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              color: AppColors.greys60),
                          child: ValueListenableBuilder(
                              valueListenable: _currentPage,
                              builder: (context, value, child) {
                                return Text(
                                  '$value ${widget.translatedWords["of"] ?? "of"} $_totalPages',
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
          ),
        ),
      ),
    );
  }
}
