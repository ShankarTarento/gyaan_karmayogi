import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/gyaan_karmayogi_resource_list.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/widgets/filter_bottom_bar.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/widgets/search_field.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/widgets/view_all_course_card.dart';
import 'package:gyaan_karmayogi_resource_list/services/gyaan_karmayogi_services.dart';
import 'package:gyaan_karmayogi_resource_list/utils/fade_route.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_resource_model.dart';

import '../gyaan_karmayogi_details_screen/gyaan_karmayogi_details_screen.dart';

class ViewAllScreen extends StatefulWidget {
  final String title;
  final String token;
  final String wid;
  final String apiKey;
  final String rootOrgId;
  final String apiUrl;
  final String baseUrl;
  final Map<String, dynamic> translatedWords;
  final Function(Map<String, dynamic>) contentShare;
  final Function(Map<String, dynamic> data) onTapViewAllButtonTelemetry;
  final Function(Map<String, dynamic> data) cardOnTapTelemetry;
  final Function(Map<String, dynamic> data) viewAllScreenTelemetry;
  final Function(Map<String, dynamic> data) detailsScreenTelemetry;
  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;
  final bool viewAllSectors;
  final List<String> selectedSector;
  final List<String> selectedSubSector;

  const ViewAllScreen({
    Key key,
    @required this.viewAllScreenTelemetry,
    @required this.translatedWords,
    @required this.contentShare,
    @required this.token,
    @required this.title,
    @required this.wid,
    @required this.apiKey,
    @required this.apiUrl,
    @required this.baseUrl,
    @required this.rootOrgId,
    @required this.cardOnTapTelemetry,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
    @required this.detailsScreenTelemetry,
    @required this.onTapViewAllButtonTelemetry,
    this.selectedSector,
    this.selectedSubSector,
    this.viewAllSectors = false,
  }) : super(key: key);

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  @override
  void initState() {
    widget.viewAllScreenTelemetry({"type": widget.title.toLowerCase()});
    // TODO: implement initState

    super.initState();
  }

  List<GyaanKarmayogiResource> resources = [];
  Map<String, dynamic> filter;
  String resourceCategory;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gyaanKarmayogiScaffoldBackground,
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
          Text(
            "${widget.translatedWords["viewAll"]} ${resourceCategory ?? widget.title}" ??
                "View all ${resourceCategory ?? widget.title}",
            style: GoogleFonts.montserrat(
              color: AppColors.greys87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          )
        ]),
      ),
      bottomNavigationBar: FilterBottomBar(
        selectedSector: widget.selectedSector,
        selectedSubsector: widget.selectedSubSector,
        translatedWords: widget.translatedWords,
        selectedCategory:
            widget.viewAllSectors ? "event" : widget.title.toLowerCase(),
        applyFilter: (value) {
          filter = value;
          resourceCategory = filter["category"];

          debugPrint("applied filters------------$value");
          setState(() {});
        },
        apiUrl: widget.apiUrl,
        baseUrl: widget.baseUrl,
        apiKey: widget.apiKey,
        rootOrgId: widget.rootOrgId,
        token: widget.token,
        wid: widget.wid,
        showAllSectors: widget.viewAllSectors,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: GyaanKarmayogiServices()),
              ],
              child: SearchField(
                  translatedWords: widget.translatedWords,
                  selectedCategory: widget.title.toLowerCase(),
                  applyFilter: (value) {
                    if (filter == null) {
                      filter = value;
                    } else {
                      filter["query"] = value["query"];
                    }
                    //  resourceCategory = filter["category"];

                    debugPrint("applied filters------------$filter");
                    setState(() {});
                  },
                  apiUrl: widget.apiUrl,
                  baseUrl: widget.baseUrl,
                  apiKey: widget.apiKey,
                  rootOrgId: widget.rootOrgId,
                  token: widget.token,
                  wid: widget.wid),
            ),

            FutureBuilder<List<GyaanKarmayogiResource>>(
                future: filter != null
                    ? getResources(
                        query: filter["query"] ?? "",
                        sectors: filter["sectors"] ?? [],
                        subSectors: filter["subSectors"] ?? [],
                        resourceCategories: filter["category"] ?? null)
                    : widget.viewAllSectors
                        ? getResources()
                        : getResources(
                            resourceCategories: widget.title.toLowerCase()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                        children: List.generate(
                            3, (index) => const CardSkeletonLoading()));
                  }
                  if (snapshot.data != null) {
                    if (snapshot.data.isNotEmpty) {
                      return Column(
                        children: List.generate(
                            snapshot.data.length,
                            (index) => GestureDetector(
                                onTap: () {
                                  widget.cardOnTapTelemetry({
                                    "type":
                                        snapshot.data[index].resourceCategory,
                                    "courseId": snapshot.data[index].identifier,
                                    "categoryType":
                                        snapshot.data[index].resourceCategory
                                  });
                                  Navigator.push(
                                      context,
                                      FadeRoute(
                                          page: GyaanKarmayogiDetailedView(
                                        translatedWords: widget.translatedWords,
                                        contentShare: (value) {
                                          widget.contentShare(value);
                                        },
                                        apiKey: widget.apiKey,
                                        apiUrl: widget.apiUrl,
                                        authToken: widget.token,
                                        baseUrl: widget.baseUrl,
                                        deptId: widget.rootOrgId,
                                        resourceId:
                                            snapshot.data[index].identifier,
                                        wid: widget.rootOrgId,
                                        cardOnTapTelemetry:
                                            widget.cardOnTapTelemetry,
                                        contentEndTelemetry:
                                            widget.contentEndTelemetry,
                                        contentStartTelemetry:
                                            widget.contentStartTelemetry,
                                        detailsScreenTelemetry:
                                            widget.detailsScreenTelemetry,
                                        onTapViewAllButtonTelemetry:
                                            widget.onTapViewAllButtonTelemetry,
                                        viewAllScreenTelemetry:
                                            widget.viewAllScreenTelemetry,
                                      )));
                                },
                                child: ViewAllCourseCard(
                                    resource: snapshot.data[index]))),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          widget.translatedWords["noResourcesFound"] ??
                              "No resources found",
                          style: GoogleFonts.lato(fontSize: 14),
                        ),
                      );
                    }
                  }
                  if (snapshot.data == null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        widget.translatedWords["noResourcesFound"] ??
                            "No resources found",
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                    );
                  }

                  return const SizedBox();
                }),
            // ...List.generate(
            //     resources.length,
            //     (index) => GestureDetector(
            //         onTap: () {
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => GyaanKarmayogiDetailedView(
            //                       // apiKey: widget.apiKey,
            //                       // apiUrl: widget.apiUrl,
            //                       // authToken: widget.token,
            //                       // baseUrl: ,
            //                       )));
            //         },
            //         child: ViewAllCourseCard(resource: resources[index])))
          ]),
        ),
      ),
    );
  }

  Future<List<GyaanKarmayogiResource>> getResources(
      {List<String> sectors,
      List<String> subSectors,
      String query,
      String resourceCategories}) async {
    // print("^^^^^^^^^^66");
    // print(sectors);
    // print(subSectors);
    // print(resourceCategories);
    // print("###########3");
    print(widget.selectedSector);

    return await GyaanKarmayogiServices().getGyaanKarmaYogiResources(
      apiKey: widget.apiKey,
      apiUrl: widget.apiUrl,
      authToken: widget.token,
      baseUrl: widget.baseUrl,
      deptId: widget.rootOrgId,
      requestBody: {
        "request": {
          "query": query,
          "filters": {
            "mimeType": [
              "application/pdf",
              "video/mp4",
              'text/x-url',
              'video/x-youtube',
              'audio/mpeg'
            ],
            "status": ["Live"],
            "sectorName": sectors ?? widget.selectedSector,
            "subSectorName": subSectors ?? widget.selectedSubSector,
            "resourceCategory": resourceCategories
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": [
            "resourceCategory",
            "sector",
          ]
        }
      },
      wid: widget.wid,
    );
  }
}
