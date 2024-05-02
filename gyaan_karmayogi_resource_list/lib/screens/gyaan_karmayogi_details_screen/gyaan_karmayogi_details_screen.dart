import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/gyaan_karmayogi_resource_list.dart';
import 'package:gyaan_karmayogi_resource_list/screens/gyaan_karmayogi_details_screen/widgets/custom_pdf_viewer.dart';
import 'package:gyaan_karmayogi_resource_list/screens/gyaan_karmayogi_details_screen/widgets/custom_video_player.dart';
import 'package:gyaan_karmayogi_resource_list/screens/gyaan_karmayogi_details_screen/widgets/gyaan_karmayogi_details_screen_header.dart';
import 'package:gyaan_karmayogi_resource_list/screens/gyaan_karmayogi_details_screen/widgets/youtube_video_player.dart';
import 'package:gyaan_karmayogi_resource_list/services/gyaan_karmayogi_services.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:gyaan_karmayogi_resource_list/utils/fade_route.dart';

import '../../data_models/gyaan_karmayogi_resource_details.dart';

class GyaanKarmayogiDetailedView extends StatefulWidget {
  final String apiKey;
  final String apiUrl;
  final String authToken;
  final String baseUrl;
  final String deptId;
  final String wid;
  final String resourceId;
  final Map<String, dynamic> translatedWords;
  final Function(Map<String, dynamic>) contentShare;
  final Function(Map<String, dynamic> data) onTapViewAllButtonTelemetry;
  final Function(Map<String, dynamic> data) cardOnTapTelemetry;
  final Function(Map<String, dynamic> data) viewAllScreenTelemetry;
  final Function(Map<String, dynamic> data) detailsScreenTelemetry;
  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;

  GyaanKarmayogiDetailedView({
    Key key,
    @required this.translatedWords,
    @required this.contentShare,
    @required this.apiKey,
    @required this.apiUrl,
    @required this.wid,
    @required this.resourceId,
    @required this.baseUrl,
    @required this.authToken,
    @required this.deptId,
    @required this.cardOnTapTelemetry,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
    @required this.detailsScreenTelemetry,
    @required this.onTapViewAllButtonTelemetry,
    @required this.viewAllScreenTelemetry,
  }) : super(key: key);

  @override
  State<GyaanKarmayogiDetailedView> createState() =>
      _GyaanKarmayogiDetailedViewState();
}

class _GyaanKarmayogiDetailedViewState
    extends State<GyaanKarmayogiDetailedView> {
  @override
  void initState() {
    // TODO: implement initState
    getResourceDetails();
    super.initState();
  }
  //               "${value["resourceType"]}/${value["resourceId"]}?primaryCategory=Learning%20Resource",

  ResourceDetails resourceDetails;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: AppColors.greys60,
            weight: 700,
          ),
        ),
        title: Row(children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              widget.contentShare({
                "identifier": resourceDetails.identifier,
                "name": resourceDetails.name,
                "posterImage": resourceDetails.posterImage,
                "source": resourceDetails.source,
                "primaryCategory": resourceDetails.primaryCategory,
              });
            },
            icon: const Icon(
              Icons.share,
              size: 24,
              color: AppColors.greys60,
              weight: 700,
            ),
          )
        ]),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          resourceDetails != null
              ? GyaanKarmayogiDetailsScreenHeader(
                  translatedWords: widget.translatedWords,
                  resourceDetails: resourceDetails)
              : const SizedBox(),
          resourceDetails != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: getPlayer(),
                )
              : const SizedBox(),
          resourceDetails != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                  child: Text(
                    resourceDetails.description,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : const SizedBox(),
          resourceDetails != null
              ? GyaanKarmayogiCarousel(
                  viewAllButton: false,
                  apiKey: widget.apiKey,
                  apiUrl: widget.apiUrl,
                  authToken: widget.authToken,
                  baseUrl: widget.baseUrl,
                  deptId: widget.deptId,
                  requestBody: {
                    "request": {
                      "query": "",
                      "filters": {
                        // "mimeType": [resourceDetails.mimeType],
                        "status": ["Live"],
                        "sectorName": resourceDetails.sectorName != null
                            ? [resourceDetails.sectorName.toLowerCase()]
                            : [],
                        "subSectorName": resourceDetails.subSectorName != null
                            ? [resourceDetails.subSectorName.toLowerCase()]
                            : [],
                        "resourceCategory": resourceDetails.resourceCategory !=
                                null
                            ? [
                                resourceDetails.resourceCategory.toLowerCase(),
                                // "Event"
                              ]
                            : []
                      },
                      "sort_by": {"lastUpdatedOn": "desc"},
                      "facets": [
                        "resourceCategory",
                        "sectorName",
                        "subSectorName"
                      ]
                    }
                  },
                  translatedWords: widget.translatedWords,
                  title: widget.translatedWords["relatedResources"] ??
                      "Related resources",
                  wid: widget.wid,
                  courseIdentifier: resourceDetails.identifier,
                  contentShare: (value) {
                    widget.contentShare(value);
                  },
                  cardOnTapTelemetry: widget.cardOnTapTelemetry,
                  contentEndTelemetry: widget.contentEndTelemetry,
                  contentStartTelemetry: widget.contentStartTelemetry,
                  detailsScreenTelemetry: widget.detailsScreenTelemetry,
                  onTapViewAllButtonTelemetry:
                      widget.onTapViewAllButtonTelemetry,
                  viewAllScreenTelemetry: widget.viewAllScreenTelemetry,
                )
              : const SizedBox()
        ]),
      ),
    );
  }

  getResourceDetails() async {
    resourceDetails = await GyaanKarmayogiServices().getCourseData(
        apiKey: widget.apiKey,
        id: widget.resourceId,
        rootOrgId: widget.deptId,
        token: widget.authToken,
        baseUrl: widget.baseUrl,
        wid: widget.wid);

    setState(() {});
    widget.detailsScreenTelemetry(
        {"resourceType": resourceType(), "resourceId": widget.resourceId});
  }

  String resourceType() {
    if (resourceDetails.mimeType == EMimeTypes.youtubeLink ||
        resourceDetails.mimeType == EMimeTypes.externalLink) {
      return "youtube";
    } else if (resourceDetails.mimeType == EMimeTypes.mp4) {
      return "video";
    } else if (resourceDetails.mimeType == EMimeTypes.mp3) {
      return "audio";
    } else {
      return "pdf";
    }
  }

  Widget getPlayer() {
    print("----------------");
    print(resourceDetails.mimeType);
    print(resourceDetails.artifactUrl);
    if (resourceDetails.mimeType == EMimeTypes.youtubeLink ||
        resourceDetails.mimeType == EMimeTypes.externalLink) {
      return Container(
          height: 215,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.translatedWords["open"]} Youtube" ?? "Open Youtube",
                style: GoogleFonts.lato(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.25),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => YouTubePlayerWidget(
                              resourceDetails: resourceDetails,
                              contentEndTelemetry: widget.contentEndTelemetry,
                              contentStartTelemetry:
                                  widget.contentStartTelemetry,
                              videoUrl: resourceDetails.artifactUrl))
                      // FadeRoute(
                      //     page: YouTubePlayerWidget(
                      //   videoUrl: resourceDetails.artifactUrl,
                      // )),
                      );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.orangeTourText,
                      borderRadius: BorderRadius.circular(63)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/link.svg',
                        package: "gyaan_karmayogi_resource_list",
                        color: AppColors.greys87,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.translatedWords["open"] ?? "Open",
                        style: GoogleFonts.lato(
                            color: AppColors.profilebgGrey,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.25),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ));
    } else if (resourceDetails.mimeType == EMimeTypes.mp4) {
      return CustomVideoPlayer(
        isAudio: false,
        resourceDetails: resourceDetails,
        contentEndTelemetry: widget.contentEndTelemetry,
        contentStartTelemetry: widget.contentStartTelemetry,
        videoUrl: resourceDetails.artifactUrl,
      );
    } else if (resourceDetails.mimeType == EMimeTypes.pdf) {
      return Container(
        height: 215,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${widget.translatedWords["open"]} PDF" ?? "Open PDF",
              style: GoogleFonts.lato(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.25),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    FadeRoute(
                        page: CoursePdfPlayer(
                      translatedWords: widget.translatedWords,
                      resourceDetails: resourceDetails,
                      contentEndTelemetry: widget.contentEndTelemetry,
                      contentStartTelemetry: widget.contentStartTelemetry,
                      pdfUrl: resourceDetails.artifactUrl,
                    )));
              },
              child: Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.orangeTourText,
                    borderRadius: BorderRadius.circular(63)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/pdf.svg',
                      package: "gyaan_karmayogi_resource_list",
                      color: AppColors.greys87,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.translatedWords["open"] ?? "Open",
                      style: GoogleFonts.lato(
                          color: AppColors.profilebgGrey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.25),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (resourceDetails.mimeType == EMimeTypes.mp3) {
      return CustomVideoPlayer(
        isAudio: true,
        resourceDetails: resourceDetails,
        contentEndTelemetry: widget.contentEndTelemetry,
        contentStartTelemetry: widget.contentStartTelemetry,
        videoUrl: resourceDetails.artifactUrl,
      );
    }
  }
}
