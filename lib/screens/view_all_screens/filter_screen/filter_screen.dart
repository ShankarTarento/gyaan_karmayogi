import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/screens/view_all_screens/filter_screen/widget/filter_screen_checkbox.dart';

import '../../../data_models/gyaan_karmayogi_category_model.dart';
import '../../../utils/app_colors.dart';
import 'widget/filter_radio_button.dart';

class FilterScreen extends StatefulWidget {
  List<FilterModel> sectors;
  List<FilterModel> subSector;
  List<FilterModel> categories;
  List<String> selectedSectors;
  List<String> selectedSubsectors;
  String selectedCategory;
  final Function() clearAllFilters;
  bool sectorVisibility;
  bool subSectorVisobility;
  bool categotiesVisibility;
  final Map<String, dynamic> translatedWords;
  void Function(Map<String, dynamic>) applyFilters;

  FilterScreen(
      {Key key,
      @required this.translatedWords,
      @required this.selectedSectors,
      @required this.selectedSubsectors,
      @required this.selectedCategory,
      @required this.clearAllFilters,
      @required this.applyFilters,
      @required this.sectors,
      @required this.subSector,
      @required this.sectorVisibility,
      @required this.categotiesVisibility,
      @required this.subSectorVisobility,
      @required this.categories})
      : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  initState() {
    super.initState();
    selectedSectors = widget.selectedSectors;
    debugPrint("${widget.sectors}");
    selectedSubSectors = widget.selectedSubsectors;
    category = widget.selectedCategory;
    sectors = widget.sectors;
    subSector = widget.subSector;
  }

  List<FilterModel> sectors;
  List<FilterModel> subSector;
  List<String> selectedSectors = [];
  List<String> selectedSubSectors = [];
  String category;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0, color: AppColors.grey08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.8,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(color: AppColors.darkBlue, width: 1),
                  ),
                  child: Text(
                    widget.translatedWords["cancel"] ?? "Cancel",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.8,
                child: ElevatedButton(
                  onPressed: () {
                    //   widget.sectors = sectors;
                    widget.applyFilters({
                      "sectors": selectedSectors,
                      "subSectors": selectedSubSectors,
                      "category": category,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(color: AppColors.darkBlue, width: 1),
                  ),
                  child: Text(
                    widget.translatedWords["applyFilters"] ?? "Apply filters",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 8,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.greys60,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  children: [
                    Text(
                      widget.translatedWords["filterResults"] ??
                          "Filter results",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        //  widget.;
                        if (widget.sectorVisibility) {
                          sectors = sectors
                              .map((sector) => FilterModel(
                                    title: sector.title,
                                    isSelected: false,
                                  ))
                              .toList();
                          selectedSectors = [];
                          widget.selectedSectors = [];
                        } else if (widget.subSectorVisobility) {
                          subSector = subSector
                              .map((sub) => FilterModel(
                                    title: sub.title,
                                    isSelected: false,
                                  ))
                              .toList();
                          selectedSubSectors = [];
                          widget.selectedSubsectors = [];
                        } else {
                          subSector = subSector
                              .map((sub) => FilterModel(
                                    title: sub.title,
                                    isSelected: false,
                                  ))
                              .toList();
                          sectors = sectors
                              .map((sector) => FilterModel(
                                    title: sector.title,
                                    isSelected: false,
                                  ))
                              .toList();
                          selectedSectors = [];
                          selectedSubSectors = [];
                          widget.selectedSectors = [];
                          widget.selectedSubsectors = [];
                        }

                        setState(() {});
                        print("clear all filters");
                        // widget.clearAllFilters();
                      },
                      child: Text(
                        widget.translatedWords['clearAll'] ?? "Clear all",
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Divider(
                      color: AppColors.grey08,
                      thickness: 2,
                    ),
                    Visibility(
                      visible: widget.sectorVisibility,
                      child: Column(
                        children: [
                          FilterCheckbox(
                            title:
                                widget.translatedWords["sectors"] ?? "Sectors",
                            selectedItems: selectedSectors,
                            checkListItems: sectors,
                            onChanged: (value) {
                              print(value);
                              selectedSectors = value;
                              widget.selectedSectors = value;
                            },
                            searchHint:
                                widget.translatedWords["searchSector"] ??
                                    "Search sector",
                          ),
                          const Divider(
                            color: AppColors.grey08,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.subSectorVisobility,
                      child: Column(
                        children: [
                          FilterCheckbox(
                            selectedItems: selectedSubSectors,
                            title: widget.translatedWords["subSectors"] ??
                                "Sub-sectors",
                            checkListItems: subSector,
                            onChanged: (value) {
                              print(value);
                              selectedSubSectors = value;
                              widget.selectedSubsectors = value;
                            },
                            searchHint:
                                widget.translatedWords["searchSubSector"] ??
                                    "Search sub-sector",
                          ),
                          const Divider(
                            color: AppColors.grey08,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.categotiesVisibility,
                      child: FilterRadioButton(
                        title: widget.translatedWords["categories"] ??
                            "Categories",
                        selectedItem: widget.selectedCategory,
                        checkListItems: widget.categories,
                        onChanged: (value) {
                          print(value);
                          category = value;
                          print("!!!!!!!!!!!!$category");
                        },
                        searchHint: widget.translatedWords["searchCategory"] ??
                            "Search category",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
