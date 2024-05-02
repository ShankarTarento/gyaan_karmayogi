import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/view_all_screen.dart';
import 'package:gyaan_karmayogi_resource_list/services/gyaan_karmayogi_services.dart'
    as GyaanKarmayogiServicesProvider;
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/services/gyaan_karmayogi_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/services/gyaan_karmayogi_telemetry.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/widgets/sectors_view.dart';
import 'package:gyaan_karmayogi_resource_list/gyaan_karmayogi_resource_list.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/api_endpoints.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../util/faderoute.dart';
import '../../../../util/helper.dart';
import '../learn/course_sharing/course_sharing_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GyaanKarmayogi extends StatefulWidget {
  const GyaanKarmayogi({Key key}) : super(key: key);

  @override
  State<GyaanKarmayogi> createState() => _GyaanKarmayogiState();
}

class _GyaanKarmayogiState extends State<GyaanKarmayogi> {
  initState() {
    super.initState();
    GyaanKarmayogiTelemetry().generateImpressionTelemetryData(
        pageIdentifier: TelemetryPageIdentifier.gyaanKarmayogiPageId,
        pageUri: TelemetryPageIdentifier.gyaanKarmayogiUri);
    getData();
  }

  @override
  void didChangeDependencies() {
    // Provider.of<GyaanKarmayogiServices>(context, listen: false)
    //     .getAvailableSector(type: "sectors",showAllSectors: );
    translatedWords = {
      "of": AppLocalizations.of(context).mStaticOf,
      "viewAll": AppLocalizations.of(context).mStaticViewAll,
      "searchInGyaanKarmayogi":
          AppLocalizations.of(context).mSearchInGyaanKarmayogi,
      "cancel": AppLocalizations.of(context).mStaticCancel,
      "applyFilters":
          AppLocalizations.of(context).mCompetenciesContentTypeApplyFilters,
      "filterResults": AppLocalizations.of(context).mStaticFilterResults,
      "sector": AppLocalizations.of(context).mStaticSector,
      "searchSecctor": AppLocalizations.of(context).mSearchSector,
      "subSector": AppLocalizations.of(context).mStaticSubSector,
      "searchSubSector": AppLocalizations.of(context).mSearchSubSector,
      "categories": AppLocalizations.of(context).mStaticCategories,
      "searchCategory": AppLocalizations.of(context).mSearchCategory,
      "relatedResources": AppLocalizations.of(context).mRelatedResources,
      "openPdf": "Open PDF",
      "open": AppLocalizations.of(context).mStaticOpen,
      "back": AppLocalizations.of(context).mBack,
      "by": AppLocalizations.of(context).mCommonBy,
      "publishedOn": AppLocalizations.of(context).mPublishedOn,
      "resourceType": AppLocalizations.of(context).mResourceType,
      "previous": AppLocalizations.of(context).mStaticPrevious,
      "next": AppLocalizations.of(context).mNext,
      "finish": AppLocalizations.of(context).mFinish,
      "sectors": AppLocalizations.of(context).mStaticSectors,
      "subSectors": AppLocalizations.of(context).mStaticSubSectors,
      "category": AppLocalizations.of(context).mStaticCategory,
      "noResourcesFound": AppLocalizations.of(context).mNoResourcesFound
    };
    super.didChangeDependencies();
  }

  final _storage = FlutterSecureStorage();
  String authToken;
  String wid;
  String deptId;
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  List<GyaanKarmayogiSector> availableSectors = [];
  bool showAll = false;
  Map<String, dynamic> translatedWords;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: AppColors.greys60),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).mCommonGyannKarmayogi,
                style: GoogleFonts.montserrat(
                  color: AppColors.greys87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SectorsView(
              navigateToViewAll: () {
                navigateToViewAllScreen(context);
              },
            ),
            Container(
              color: AppColors.yellowBckground,
              child: Column(
                children: [
                  authToken != null
                      ? Consumer<GyaanKarmayogiServices>(
                          builder: (contextm, provider, child) {
                            return Column(children: [
                              provider.selectedResourceCategories.isNotEmpty
                                  ? Column(
                                      children: List.generate(
                                          provider.selectedResourceCategories
                                                          .length >
                                                      3 &&
                                                  !showAll
                                              ? 3
                                              : provider
                                                  .selectedResourceCategories
                                                  .length, (index) {
                                      return GyaanKarmayogiCarousel(
                                        translatedWords: translatedWords,
                                        contentShare: (share) async {
                                          await showModalBottomSheet(
                                            context: contextm,
                                            isScrollControlled: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            backgroundColor: Colors.transparent,
                                            builder: (BuildContext context) {
                                              return Container(
                                                  child: CourseSharingPage(
                                                      1694586265488,
                                                      share["identifier"],
                                                      share['name'],
                                                      share['posterImage'],
                                                      share['source'],
                                                      share["primaryCategory"],
                                                      shareResponse()));
                                            },
                                          );
                                        },
                                        title: Helper.capitalize(provider
                                            .selectedResourceCategories[index]),
                                        apiKey: ApiUrl.apiKey,
                                        authToken: authToken,
                                        baseUrl: ApiUrl.baseUrl,
                                        apiUrl: coursesUrl,
                                        deptId: deptId,
                                        requestBody: {
                                          "request": {
                                            "query": "",
                                            "filters": {
                                              "mimeType": [
                                                "application/pdf",
                                                "video/mp4",
                                                'text/x-url',
                                                'video/x-youtube',
                                                'audio/mpeg'
                                              ],
                                              "status": ["Live"],
                                              "resourceCategory": [
                                                provider.selectedResourceCategories[
                                                    index]
                                                // "event"
                                              ],
                                              "sectorName":
                                                  provider.sectorFilters,
                                              "subSectorName":
                                                  provider.subSectorFilters
                                            },
                                            "sort_by": {
                                              "lastUpdatedOn": "desc"
                                            },
                                            "facets": [
                                              "resourceCategory",
                                              "sector",
                                            ]
                                          }
                                        },
                                        selectedSubSector:
                                            provider.subSectorFilters,
                                        selectedSector: provider.sectorFilters,
                                        wid: wid,
                                        cardOnTapTelemetry: (value) {
                                          GyaanKarmayogiTelemetry()
                                              .generateInteractTelemetryData(
                                            subType:
                                                value["type"].toLowerCase(),
                                            contentId: TelemetryPageIdentifier
                                                .gyaanKarmayogiCardId,
                                            pageIdentifier:
                                                TelemetryPageIdentifier
                                                    .gyaanKarmayogiViewAll,
                                          );
                                        },
                                        contentEndTelemetry: (value) {
                                          GyaanKarmayogiTelemetry()
                                              .triggerEndTelemetryEvent(
                                                  pageIdentifier:
                                                      TelemetryPageIdentifier
                                                          .gyaanKarmayogiDetailsId,
                                                  pageUrl: value["pageUri"],
                                                  time: value["time"]);
                                        },
                                        contentStartTelemetry: (value) {
                                          print(value);
                                          GyaanKarmayogiTelemetry()
                                              .triggerStartTelemetryEvent(
                                                  pageIdentifier:
                                                      TelemetryPageIdentifier
                                                          .gyaanKarmayogiDetailsId,
                                                  pageUri: value["pageUri"]);
                                        },
                                        detailsScreenTelemetry: (value) {
                                          print(value);
                                          GyaanKarmayogiTelemetry()
                                              .generateImpressionTelemetryData(
                                            pageIdentifier:
                                                TelemetryPageIdentifier
                                                    .gyaanKarmayogiDetailsId,
                                            pageUri: TelemetryPageIdentifier
                                                    .gyaanKarmayogiDetailsUri +
                                                "${value["resourceType"]}/${value["resourceId"]}?primaryCategory=Learning%20Resource",
                                          );
                                        },
                                        onTapViewAllButtonTelemetry: (value) {
                                          GyaanKarmayogiTelemetry()
                                              .generateInteractTelemetryData(
                                                  subType: value["type"]
                                                      .toLowerCase(),
                                                  contentId: "view-all",
                                                  pageIdentifier:
                                                      TelemetryPageIdentifier
                                                          .gyaanKarmayogiViewAll);
                                        },
                                        viewAllScreenTelemetry: (value) {
                                          print(value);
                                          GyaanKarmayogiTelemetry()
                                              .generateImpressionTelemetryData(
                                                  pageIdentifier:
                                                      TelemetryPageIdentifier
                                                              .gyaanKarmayogiViewAllImpressionPageId +
                                                          value["type"],
                                                  pageUri: TelemetryPageIdentifier
                                                          .gyaanKarmayogiViewAllImpressionPageUri +
                                                      value["type"]);
                                        },
                                      );
                                    }))
                                  : SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mNoResourcesFound,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                              provider.selectedResourceCategories.length > 3
                                  ? ElevatedButton(
                                      onPressed: () {
                                        showAll = showAll ? false : true;
                                        setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          side: BorderSide(
                                              color: AppColors.darkBlue),
                                        ),
                                      ),
                                      child: Text(
                                        showAll
                                            ? AppLocalizations.of(context)
                                                .mStaticViewLess
                                            : AppLocalizations.of(context)
                                                .mViewAllCategories,
                                        style: GoogleFonts.lato(
                                          color: AppColors.darkBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(height: 20),
                            ]);
                          },
                        )
                      : CardSkeletonLoading(),
                ],
              ),
            ),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  getData() async {
    wid = await _storage.read(key: Storage.wid);
    deptId = await _storage.read(key: Storage.deptId);
    authToken = await _storage.read(key: Storage.authToken);
    //  availableSectors =

    setState(() {});
  }

  shareResponse() {}

  navigateToViewAllScreen(BuildContext context) async {
    List<String> sectors = await Provider.of<GyaanKarmayogiServices>(context,
            listen: false)
        .getAvailableSector(showAllSectors: false, type: "sector", query: "");
    Navigator.push(
        context,
        FadeRoute(
          page: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                  value:
                      GyaanKarmayogiServicesProvider.GyaanKarmayogiServices()),
            ],
            child: ViewAllScreen(
              selectedSector: sectors,
              // selectedSubSector:
              //     context.watch<GyaanKarmayogiServices>().subSectorFilters,
              translatedWords: translatedWords,
              contentShare: (share) async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return Container(
                        child: CourseSharingPage(
                      1694586265488,
                      share["identifier"],
                      share['name'],
                      share['posterImage'],
                      share['source'],
                      share["primaryCategory"],
                      shareResponse(),
                    ));
                  },
                );
              },

              apiKey: ApiUrl.apiKey,
              token: authToken,
              baseUrl: ApiUrl.baseUrl,
              apiUrl: coursesUrl,
              rootOrgId: deptId,
              wid: wid,
              title: "sectors",
              cardOnTapTelemetry: (value) {
                GyaanKarmayogiTelemetry().generateInteractTelemetryData(
                  subType: value["type"].toLowerCase(),
                  contentId: TelemetryPageIdentifier.gyaanKarmayogiCardId,
                  pageIdentifier: TelemetryPageIdentifier.gyaanKarmayogiViewAll,
                );
              },
              contentEndTelemetry: (value) {
                GyaanKarmayogiTelemetry().triggerEndTelemetryEvent(
                    pageIdentifier:
                        TelemetryPageIdentifier.gyaanKarmayogiDetailsId,
                    pageUrl: value["pageUri"],
                    time: value["time"]);
              },
              contentStartTelemetry: (value) {
                print(value);
                GyaanKarmayogiTelemetry().triggerStartTelemetryEvent(
                    pageIdentifier:
                        TelemetryPageIdentifier.gyaanKarmayogiDetailsId,
                    pageUri: value["pageUri"]);
              },
              detailsScreenTelemetry: (value) {
                print(value);
                GyaanKarmayogiTelemetry().generateImpressionTelemetryData(
                  pageIdentifier:
                      TelemetryPageIdentifier.gyaanKarmayogiDetailsId,
                  pageUri: TelemetryPageIdentifier.gyaanKarmayogiDetailsUri +
                      "${value["resourceType"]}/${value["resourceId"]}?primaryCategory=Learning%20Resource",
                );
              },
              onTapViewAllButtonTelemetry: (value) {
                GyaanKarmayogiTelemetry().generateInteractTelemetryData(
                    subType: value["type"].toLowerCase(),
                    contentId: "view-all",
                    pageIdentifier:
                        TelemetryPageIdentifier.gyaanKarmayogiViewAll);
              },
              viewAllScreenTelemetry: (value) {
                print(value);
                GyaanKarmayogiTelemetry().generateImpressionTelemetryData(
                    pageIdentifier: TelemetryPageIdentifier
                            .gyaanKarmayogiViewAllImpressionPageId +
                        value["type"],
                    pageUri: TelemetryPageIdentifier
                            .gyaanKarmayogiViewAllImpressionPageUri +
                        value["type"]);
              },
              viewAllSectors: true,
            ),
          ),
        ));
  }
}
