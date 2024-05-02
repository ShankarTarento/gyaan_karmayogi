import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../data_models/gyaan_karmayogi_category_model.dart';
import '../../../data_models/gyaan_karmayogi_sector_model.dart';
import '../../../services/gyaan_karmayogi_services.dart';
import '../filter_screen/filter_screen.dart';

class FilterBottomBar extends StatefulWidget {
  final Function(Map<String, dynamic>) applyFilter;
  final String token;
  final String wid;
  final String apiKey;
  final String apiUrl;
  final String rootOrgId;
  final String baseUrl;
  final String selectedCategory;
  final List<String> selectedSector;
  final List<String> selectedSubsector;
  final Map<String, dynamic> translatedWords;
  final bool showAllSectors;
  const FilterBottomBar(
      {Key key,
      @required this.translatedWords,
      @required this.applyFilter,
      @required this.token,
      @required this.wid,
      @required this.apiUrl,
      @required this.apiKey,
      @required this.baseUrl,
      this.selectedSector,
      this.selectedSubsector,
      this.showAllSectors,
      @required this.selectedCategory,
      @required this.rootOrgId})
      : super(key: key);

  @override
  State<FilterBottomBar> createState() => _FilterBottomBarState();
}

class _FilterBottomBarState extends State<FilterBottomBar> {
  @override
  void initState() {
    getData(false);
    // TODO: implement initState
    super.initState();
  }

  List<FilterModel> sectors = [];
  List<FilterModel> subSector = [];
  List<FilterModel> categories = [];
  List<String> selectedSectors = [];
  List<String> selectedSubSectors = [];
  String selectedCategory;

  getData(bool clearAll) async {
    sectors = await Provider.of<GyaanKarmayogiServices>(context, listen: false)
        .getAvailableSector(
            type: "sector",
            authToken: widget.token,
            apiUrl: widget.apiUrl,
            wid: widget.wid,
            apiKey: widget.apiKey,
            baseUrl: widget.baseUrl,
            deptId: widget.rootOrgId);
    subSector =
        await Provider.of<GyaanKarmayogiServices>(context, listen: false)
            .getAvailableSector(
                type: "subSector",
                authToken: widget.token,
                apiUrl: widget.apiUrl,
                wid: widget.wid,
                apiKey: widget.apiKey,
                baseUrl: widget.baseUrl,
                deptId: widget.rootOrgId);
    categories =
        await Provider.of<GyaanKarmayogiServices>(context, listen: false)
            .getAvailableSector(
                type: "",
                authToken: widget.token,
                apiUrl: widget.apiUrl,
                wid: widget.wid,
                apiKey: widget.apiKey,
                baseUrl: widget.baseUrl,
                deptId: widget.rootOrgId);
    if (!clearAll) {
      if (widget.showAllSectors != null && widget.showAllSectors) {
        selectedSectors = sectors.map((e) => e.title).toList();
        for (var sec in sectors) {
          if (selectedSectors.contains(sec.title)) {
            sec.isSelected = true;
          }
        }
      }
      if (widget.selectedSector != null && widget.selectedSector.isNotEmpty) {
        selectedSectors = widget.selectedSector;
        for (var sec in sectors) {
          if (widget.selectedSector.contains(sec.title)) {
            sec.isSelected = true;
          }
        }
      }
      if (widget.selectedSubsector != null &&
          widget.selectedSubsector.isNotEmpty) {
        selectedSubSectors = widget.selectedSubsector;
        for (var sec in subSector) {
          if (widget.selectedSubsector.contains(sec.title)) {
            sec.isSelected = true;
          }
        }
      }
    } else {
      selectedSectors = [];
      selectedSubSectors = [];
    }
    // print(widget.selectedSector);
    // print(widget.selectedSubsector);

    // // sectors[0].isSelected = true;
    // print(selectedSectors);
    setState(() {});
  }

  Map<String, dynamic> searchFilter;
  List<GyaanKarmayogiSector> availableSectors;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, bottom: 18),
      child: Row(children: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  useSafeArea: true,
                  isDismissible: true,
                  enableDrag: true,
                  context: context,
                  builder: (BuildContext context) {
                    return FilterScreen(
                      translatedWords: widget.translatedWords,
                      categotiesVisibility: true,
                      sectorVisibility: true,
                      subSectorVisobility: true,
                      selectedCategory:
                          selectedCategory ?? widget.selectedCategory,
                      selectedSectors: selectedSectors,
                      selectedSubsectors: selectedSubSectors,
                      applyFilters: (value) {
                        // print("bottom bar value");
                        // print(value);
                        widget.applyFilter({
                          "sectors": value["sectors"].isNotEmpty
                              ? value["sectors"]
                              : sectors.map((e) => e.title).toList(),
                          "subSectors": value["subSectors"],
                          "category": value["category"],
                        });
                        selectedSectors = value["sectors"];
                        selectedSubSectors = value["subSectors"];
                        searchFilter = value;
                        selectedCategory = value["category"];
                        sectors = sectors
                            .map((sector) =>
                                selectedSectors.contains(sector.title)
                                    ? FilterModel(
                                        title: sector.title,
                                        isSelected: true,
                                      )
                                    : FilterModel(
                                        title: sector.title,
                                        isSelected: false,
                                      ))
                            .toList();
                        subSector = subSector
                            .map((sub) => selectedSubSectors.contains(sub.title)
                                ? FilterModel(
                                    title: sub.title,
                                    isSelected: true,
                                  )
                                : FilterModel(
                                    title: sub.title,
                                    isSelected: false,
                                  ))
                            .toList();
                        debugPrint("${sectors}");

                        Navigator.pop(context);
                        setState(() {});
                      },
                      clearAllFilters: () async {
                        // getData(true);
                        // //  selectedCategory = null;
                        // selectedSectors = [];
                        // selectedSubSectors = [];

                        // widget.applyFilter(
                        //     {"sectors": sectors.map((e) => e.title).toList()});

                        // Navigator.pop(context);
                      },
                      sectors: sectors,
                      subSector: subSector,
                      categories: categories,
                    );
                  });
            },
            icon: const Icon(Icons.filter_list_outlined)),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterButton(
                  displayTitle: widget.translatedWords["sectors"] ?? "Sectors",
                  title: "Sectors",
                  count: selectedSectors.length.toString(),
                ),
                const SizedBox(
                  width: 12,
                ),
                filterButton(
                    displayTitle:
                        widget.translatedWords["subSectors"] ?? "Sub-sectors",
                    title: "Sub-sectors",
                    count: selectedSubSectors.length.toString()),
                const SizedBox(
                  width: 12,
                ),
                filterButton(
                    displayTitle:
                        widget.translatedWords["categories"] ?? "Categories",
                    title: "Categories",
                    count: "1"),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget filterButton(
      {@required String title,
      @required String count,
      @required String displayTitle}) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            enableDrag: true,
            context: context,
            builder: (BuildContext context) {
              return FilterScreen(
                translatedWords: widget.translatedWords,
                categotiesVisibility: title == "Categories" ? true : false,
                sectorVisibility: title == "Sectors" ? true : false,
                subSectorVisobility: title == "Sub-sectors" ? true : false,
                selectedCategory: selectedCategory ?? widget.selectedCategory,
                selectedSectors: selectedSectors,
                selectedSubsectors: selectedSubSectors,
                applyFilters: (value) {
                  print("bottom bar value");
                  print(value);
                  widget.applyFilter({
                    "sectors": value["sectors"].isNotEmpty
                        ? value["sectors"]
                        : sectors.map((e) => e.title).toList(),
                    "subSectors": value["subSectors"],
                    "category": value["category"],
                  });
                  selectedSectors = value["sectors"];
                  selectedSubSectors = value["subSectors"];
                  searchFilter = value;
                  selectedCategory = value["category"];
                  sectors = sectors
                      .map((sector) => selectedSectors.contains(sector.title)
                          ? FilterModel(
                              title: sector.title,
                              isSelected: true,
                            )
                          : FilterModel(
                              title: sector.title,
                              isSelected: false,
                            ))
                      .toList();
                  subSector = subSector
                      .map((sub) => selectedSubSectors.contains(sub.title)
                          ? FilterModel(
                              title: sub.title,
                              isSelected: true,
                            )
                          : FilterModel(
                              title: sub.title,
                              isSelected: false,
                            ))
                      .toList();
                  debugPrint("${sectors}");

                  Navigator.pop(context);
                  setState(() {});
                },
                clearAllFilters: () async {
                  //  getData(true);
                  //  selectedCategory = [widget];
                  // selectedSectors = [];
                  // selectedSubSectors = [];
                  // widget.applyFilter(
                  //     {"sectors": sectors.map((e) => e.title).toList()});
                  // Navigator.pop(context);
                },
                sectors: sectors,
                subSector: subSector,
                categories: categories,
              );
            });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, left: 8),
            height: 32,
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.black16),
            ),
            child: Center(
              child: Row(
                children: [
                  Text(
                    displayTitle,
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          ),
          count != "0"
              ? Positioned(
                  top: -1,
                  left: 15,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: AppColors.darkBlue,
                    child: Text(
                      count,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ))
              : const SizedBox()
        ],
      ),
    );
  }
}
