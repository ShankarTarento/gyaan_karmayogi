import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../../localization/_langs/english_lang.dart';
import '../index.dart';

class CBPFilterWidget extends StatefulWidget {
  CBPFilterWidget(
      {Key key,
      @required this.updatedFilterList,
      @required this.selectedTimelineValue,
      @required this.checkStatus,
      @required this.filterProvider,
      @required this.competencyInfo,
      @required this.updateFilterParentAction,
      this.doRefresh = false})
      : super(key: key);
  final updatedFilterList;
  final CBPFilter filterProvider;
  final List checkStatus;
  final competencyInfo;
  bool doRefresh;
  final bool selectedTimelineValue;
  final Function(
      {String category,
      List<String> areaList,
      List<String> themeList}) updateFilterParentAction;

  @override
  State<CBPFilterWidget> createState() => _CBPFilterWidgetState();
}

class _CBPFilterWidgetState extends State<CBPFilterWidget> {
  bool selectedTimelineValue;
  List checkStatus = [];
  CBPFilter filterProvider;
  List<Map<String, dynamic>> competencyName = [], filterField = [];
  Map<String, dynamic> filteredCompetency;
  final List<TextEditingController> themeController = [];
  List<FocusNode> themeFocusNode = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doRefresh != null && widget.doRefresh) {
      selectedTimelineValue = widget.selectedTimelineValue;
      checkStatus = widget.checkStatus;
      filterProvider = widget.filterProvider;
      if (themeController.length < widget.updatedFilterList.length) {
        for (var i = themeController.length;
            i < widget.updatedFilterList.length;
            i++) {
          themeController.add(TextEditingController());
          themeController[i] = TextEditingController();
          themeFocusNode.add(FocusNode());
          themeFocusNode[i] = FocusNode();
        }
      }
      widget.doRefresh = false;
    }
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: TitleBoldWidget(
                            widget.updatedFilterList[index].category,
                            fontSize: 14,
                            letterSpacing: 0.25),
                      ),
                      iconColor: AppColors.darkGrey,
                      collapsedIconColor: AppColors.darkGrey,
                      initiallyExpanded: true,
                      children: [
                        (widget.updatedFilterList[index].category ==
                                    CBPFilterCategory.competencyTheme &&
                                widget.updatedFilterList[index].filters.length >
                                    4 &&
                                index != widget.updatedFilterList.length - 1)
                            ? Column(
                                children: [
                                  searchCompetency(index,
                                      widget.updatedFilterList[index].category),
                                  SizedBox(height: 4),
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.updatedFilterList[index]
                                          .filters.length,
                                      itemBuilder: (context, filterIndex) {
                                        return CBPFilteringItemListWidget(
                                          checkStatus: checkStatus,
                                          competencyInfo: widget.competencyInfo,
                                          competencyName: competencyName,
                                          filterField: filterField,
                                          index: index,
                                          filterIndex: filterIndex,
                                          filterProvider: filterProvider,
                                          selectedTimelineValue:
                                              selectedTimelineValue,
                                          updatedFilterList:
                                              widget.updatedFilterList,
                                          updateFilterParentAction:
                                              widget.updateFilterParentAction,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  widget.updatedFilterList[index].category ==
                                          CBPFilterCategory.competencyTheme
                                      ? Padding(
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: searchCompetency(
                                              index,
                                              widget.updatedFilterList[index]
                                                  .category),
                                        )
                                      : SizedBox.shrink(),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: widget.updatedFilterList[index]
                                        .filters.length,
                                    itemBuilder: (context, filterIndex) {
                                      selectedTimelineValue = true;
                                      return CBPFilteringItemListWidget(
                                          checkStatus: checkStatus,
                                          competencyInfo: widget.competencyInfo,
                                          competencyName: competencyName,
                                          filterField: filterField,
                                          index: index,
                                          filterIndex: filterIndex,
                                          filterProvider: filterProvider,
                                          selectedTimelineValue:
                                              selectedTimelineValue,
                                          updatedFilterList:
                                              widget.updatedFilterList,
                                          updateFilterParentAction:
                                              widget.updateFilterParentAction);
                                    },
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  index < widget.updatedFilterList.length - 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Divider(
                            color: AppColors.darkGrey,
                            thickness: 1,
                            height: 0,
                          ),
                        )
                      : SizedBox.shrink()
                ],
              );
            },
            childCount: widget.updatedFilterList.length,
          ),
        )
      ],
    );
  }

  void checkSelectionStatus(List<dynamic> checkStatus, updatedFilter, int i) {
    if (checkStatus.isEmpty) {
      checkStatus.add({'contentType': updatedFilter.category, 'index': i});
    } else {
      bool isExist = false;
      for (int index = 0; index < checkStatus.length; index++) {
        if (checkStatus[index]['contentType'].toString().toLowerCase() ==
            EnglishLang.timeDuration.toLowerCase()) {
          checkStatus.removeAt(index);
        } else if (checkStatus[index]['contentType'] ==
                updatedFilter.category &&
            checkStatus[index]['index'] == i) {
          checkStatus.removeAt(index);
          isExist = true;
        }
      }
      if (!isExist) {
        checkStatus.add({'contentType': updatedFilter.category, 'index': i});
      }
    }
  }

  Padding searchCompetency(int index, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        child: TextFormField(
            controller: themeController[index],
            focusNode: themeFocusNode[index],
            onChanged: (value) {
              filterCompetencyOnSearch(
                  value, widget.updatedFilterList[index].category);
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            cursorColor: AppColors.darkBlue,
            style: GoogleFonts.lato(fontSize: 14.0),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusColor: AppColors.darkBlue,
              prefixIcon: Icon(Icons.search,
                  color: themeFocusNode[index].hasFocus
                      ? AppColors.darkBlue
                      : AppColors.grey08),
              contentPadding: EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: AppColors.grey16,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: AppColors.darkBlue,
                ),
              ),
              hintText: category,
              hintStyle: GoogleFonts.lato(
                  color: AppColors.greys60,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: '',
            )),
      ),
    );
  }

  void filterCompetencyOnSearch(String value, category) {
    filteredCompetency = widget.competencyInfo;
    // setState(() {
    List<String> areaList = [], themeList = [];
    List<Map<String, dynamic>> competencyName = [];
    //Get the list of areas and themes being selected
    widget.updatedFilterList.forEach((filterItem) {
      if (filterItem.category == CompetencyFilterCategory.competencyArea) {
        filterItem.filters.forEach((element) {
          if (element.isSelected) {
            areaList.add(element.name);
          }
        });
      } else if (areaList.isNotEmpty &&
          filterItem.category == CompetencyFilterCategory.competencyTheme) {
        filterItem.filters.forEach((element) {
          if (element.isSelected) {
            themeList.add(element.name);
          }
        });
      }
    });
    // If category is theme get all theme name
    if (category == CompetencyFilterCategory.competencyArea) {
      widget.competencyInfo['competency'].forEach((element) {
        competencyName.add({'name': element['name']});
      });
    } else if (category == CompetencyFilterCategory.competencyTheme &&
        areaList != null &&
        areaList.isNotEmpty) {
      areaList.forEach((area) {
        widget.competencyInfo['competency'].forEach((element) {
          if (element['name'].toString().toLowerCase() == area.toLowerCase() &&
              element['children'] != null &&
              element['children'].isNotEmpty) {
            element['children'].forEach((item) {
              competencyName.add({'name': item['name']});
            });
          }
        });
      });
    } else if (category == CompetencyFilterCategory.competencySubtheme &&
        areaList != null &&
        areaList.isNotEmpty &&
        themeList != null &&
        themeList.isNotEmpty) {
      areaList.forEach((area) {
        widget.competencyInfo['competency'].forEach((element) {
          if (element['name'].toString().toLowerCase() == area.toLowerCase() &&
              element['children'] != null &&
              element['children'].isNotEmpty) {
            element['children'].forEach((item) {
              themeList.forEach((theme) {
                if (item['name'].toString().toLowerCase() ==
                        theme.toLowerCase() &&
                    item['children'] != null &&
                    item['children'].isNotEmpty) {
                  item['children'].forEach((subtheme) {
                    competencyName.add({'name': subtheme['name']});
                  });
                }
              });
            });
          }
        });
      });
    }
    competencyName.removeWhere((competencyTheme) =>
        !((competencyTheme['name']).toString().toLowerCase())
            .contains(value.toLowerCase()));
    widget.filterProvider.searchFilters([
      {'category': category, 'values': competencyName}
    ]);
  }
}
