library gyaan_karmayogi_resource_list;

export 'package:gyaan_karmayogi_resource_list/gyaan_karmayogi_resource_list.dart';
export 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_sector_model.dart';
export 'package:gyaan_karmayogi_resource_list/widgets/card_skeleton_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/screens/gyaan_karmayogi_details_screen/gyaan_karmayogi_details_screen.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/view_all_screen.dart';
import 'package:gyaan_karmayogi_resource_list/services/gyaan_karmayogi_services.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:gyaan_karmayogi_resource_list/utils/fade_route.dart';
import 'package:gyaan_karmayogi_resource_list/widgets/card_skeleton_loading.dart';
import 'package:gyaan_karmayogi_resource_list/widgets/horizontal_view_card.dart';
import 'package:gyaan_karmayogi_resource_list/widgets/title_skeleton_loading.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'data_models/gyaan_karmayogi_resource_model.dart';

class GyaanKarmayogiCarousel extends StatefulWidget {
  final String courseIdentifier;
  final String title;
  final String apiKey;
  final String apiUrl;
  final String authToken;
  final String baseUrl;
  final String deptId;
  final Map<String, dynamic> translatedWords;
  final Map<String, dynamic> requestBody;
  final String wid;
  final Function(Map<String, dynamic> data) onTapViewAllButtonTelemetry;
  final Function(Map<String, dynamic> data) cardOnTapTelemetry;
  final Function(Map<String, dynamic> data) viewAllScreenTelemetry;
  final Function(Map<String, dynamic> data) detailsScreenTelemetry;
  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;
  final List<String> selectedSector;
  final List<String> selectedSubSector;
  bool viewAllButton;

  Function(Map<String, dynamic>) contentShare;
  GyaanKarmayogiCarousel({
    Key key,
    this.courseIdentifier,
    @required this.contentShare,
    @required this.title,
    @required this.apiKey,
    @required this.translatedWords,
    @required this.authToken,
    @required this.baseUrl,
    @required this.apiUrl,
    @required this.deptId,
    @required this.requestBody,
    @required this.wid,
    this.viewAllButton,
    //

    @required this.cardOnTapTelemetry,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
    @required this.detailsScreenTelemetry,
    @required this.onTapViewAllButtonTelemetry,
    @required this.viewAllScreenTelemetry,
    this.selectedSector,
    this.selectedSubSector,
  }) : super(key: key);

  @override
  State<GyaanKarmayogiCarousel> createState() => _GyaanKarmayogiCarouselState();
}

class _GyaanKarmayogiCarouselState extends State<GyaanKarmayogiCarousel> {
  int currentIndex = 0;
  final int maxCountToShowNavIcon = 1;
  Future karmayogiResources;
  PageController _controller = PageController();

  @override
  void initState() {
    currentIndex = 0;
    karmayogiResources = GyaanKarmayogiServices().getGyaanKarmaYogiResources(
      apiKey: widget.apiKey,
      apiUrl: widget.apiUrl,
      authToken: widget.authToken,
      baseUrl: widget.baseUrl,
      deptId: widget.deptId,
      requestBody: widget.requestBody,
      wid: widget.wid,
    );
    _controller.addListener(() {
      setState(() {
        currentIndex = _controller.page.round();
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(GyaanKarmayogiCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // currentIndex = 0;

    // _controller = PageController(initialPage: 0);

    _controller.addListener(() {
      setState(() {
        currentIndex = _controller.page.round();
      });
    });

    if (oldWidget.requestBody != widget.requestBody) {
      karmayogiResources = GyaanKarmayogiServices().getGyaanKarmaYogiResources(
        apiKey: widget.apiKey,
        apiUrl: widget.apiUrl,
        authToken: widget.authToken,
        baseUrl: widget.baseUrl,
        deptId: widget.deptId,
        requestBody: widget.requestBody,
        wid: widget.wid,
      );
    }
    // print(widget.selectedSector);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GyaanKarmayogiResource>>(
        future: karmayogiResources,
        builder: (context, snapshot) {
          //  print(snapshot.data);
          if (snapshot.data != null) {
            List<GyaanKarmayogiResource> resources = snapshot.data;
            if (widget.courseIdentifier != null) {
              resources.removeWhere(
                  (element) => element.identifier == widget.courseIdentifier);
            }

            return resources.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            widget.viewAllButton == null
                                ? TextButton(
                                    onPressed: () {
                                      widget.onTapViewAllButtonTelemetry(
                                          {"type": widget.title});
                                      Navigator.push(
                                          context,
                                          FadeRoute(
                                            page: MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider.value(
                                                    value:
                                                        GyaanKarmayogiServices()),
                                              ],
                                              child: ViewAllScreen(
                                                selectedSubSector:
                                                    widget.selectedSubSector,
                                                selectedSector:
                                                    widget.selectedSector,
                                                translatedWords:
                                                    widget.translatedWords,
                                                contentShare: (value) {
                                                  widget.contentShare(value);
                                                },
                                                apiKey: widget.apiKey,
                                                rootOrgId: widget.deptId,
                                                token: widget.authToken,
                                                wid: widget.wid,
                                                apiUrl: widget.apiUrl,
                                                baseUrl: widget.baseUrl,
                                                title: widget.title,
                                                cardOnTapTelemetry:
                                                    widget.cardOnTapTelemetry,
                                                contentEndTelemetry:
                                                    widget.contentEndTelemetry,
                                                contentStartTelemetry: widget
                                                    .contentStartTelemetry,
                                                detailsScreenTelemetry: widget
                                                    .detailsScreenTelemetry,
                                                onTapViewAllButtonTelemetry: widget
                                                    .onTapViewAllButtonTelemetry,
                                                viewAllScreenTelemetry: widget
                                                    .viewAllScreenTelemetry,
                                              ),
                                            ),
                                          ));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.translatedWords["viewAll"] ??
                                              "View all",
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.darkBlue,
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 381,
                              margin: const EdgeInsets.only(
                                  left: 0, top: 0, bottom: 15),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: PageView.builder(
                                      controller: _controller,
                                      itemCount: resources.length > 5
                                          ? 4
                                          : resources.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            widget.cardOnTapTelemetry({
                                              "type": snapshot
                                                  .data[index].resourceCategory,
                                              "courseId": snapshot
                                                  .data[index].identifier,
                                              "categoryType": snapshot
                                                  .data[index].resourceCategory
                                            });
                                            Navigator.push(
                                                context,
                                                FadeRoute(
                                                    page:
                                                        GyaanKarmayogiDetailedView(
                                                  cardOnTapTelemetry:
                                                      widget.cardOnTapTelemetry,
                                                  contentEndTelemetry: widget
                                                      .contentEndTelemetry,
                                                  contentStartTelemetry: widget
                                                      .contentStartTelemetry,
                                                  detailsScreenTelemetry: widget
                                                      .detailsScreenTelemetry,
                                                  onTapViewAllButtonTelemetry:
                                                      widget
                                                          .onTapViewAllButtonTelemetry,
                                                  viewAllScreenTelemetry: widget
                                                      .viewAllScreenTelemetry,
                                                  translatedWords:
                                                      widget.translatedWords,
                                                  apiKey: widget.apiKey,
                                                  apiUrl: widget.apiUrl,
                                                  authToken: widget.authToken,
                                                  baseUrl: widget.baseUrl,
                                                  deptId: widget.deptId,
                                                  resourceId: snapshot
                                                      .data[index].identifier,
                                                  wid: widget.wid,
                                                  contentShare: (share) {
                                                    widget.contentShare(share);
                                                  },
                                                )));
                                          },
                                          child: HorizontalViewCard(
                                              cardOnTapTelemetry:
                                                  widget.cardOnTapTelemetry,
                                              contentEndTelemetry:
                                                  widget.contentEndTelemetry,
                                              contentStartTelemetry:
                                                  widget.contentStartTelemetry,
                                              detailsScreenTelemetry:
                                                  widget.detailsScreenTelemetry,
                                              onTapViewAllButtonTelemetry: widget
                                                  .onTapViewAllButtonTelemetry,
                                              viewAllScreenTelemetry:
                                                  widget.viewAllScreenTelemetry,
                                              translatedWords:
                                                  widget.translatedWords,
                                              resource: resources[index]),
                                        );
                                      },
                                    ),
                                  ),
                                  SmoothPageIndicator(
                                    controller: _controller,
                                    count: resources.length > 5
                                        ? 4
                                        : resources.length,
                                    effect: const ExpandingDotsEffect(
                                        activeDotColor:
                                            AppColors.orangeTourText,
                                        dotColor: AppColors.profilebgGrey20,
                                        dotHeight: 4,
                                        dotWidth: 4,
                                        spacing: 4),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                                visible: resources.length > maxCountToShowNavIcon,
                                child: Positioned(
                                  top: 160,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      if (currentIndex > 0) {
                                        _controller.animateToPage(
                                          currentIndex - 1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 16,
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible: resources.length > maxCountToShowNavIcon,
                                child: Positioned(
                                  top: 160,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      if (currentIndex < 3) {
                                        _controller.animateToPage(
                                          currentIndex + 1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 16,
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  )
                : const SizedBox();
          } else if (snapshot.data == null) {
            return const SizedBox();
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Column(
                children: const [
                  SizedBox(
                    height: 30,
                  ),
                  TitleSkeletonLoading(),
                  CardSkeletonLoading(),
                ],
              ),
            );
          }
        });
  }
}
