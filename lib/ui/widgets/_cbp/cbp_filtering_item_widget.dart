import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../../../localization/_langs/english_lang.dart';
import '../../../util/helper.dart';
import '../index.dart';

class CBPFilteringItemListWidget extends StatefulWidget {
  final updatedFilterList;
  final int index, filterIndex;
  final CBPFilter filterProvider;
  final List checkStatus;
  final List<Map<String, dynamic>> filterField, competencyName;
  final competencyInfo;
  final bool selectedTimelineValue;
  final Function(
      {String category,
      List<String> areaList,
      List<String> themeList}) updateFilterParentAction;
  const CBPFilteringItemListWidget(
      {Key key,
      @required this.updatedFilterList,
      @required this.index,
      @required this.filterIndex,
      @required this.filterProvider,
      @required this.checkStatus,
      @required this.filterField,
      @required this.competencyName,
      @required this.competencyInfo,
      @required this.selectedTimelineValue,
      @required this.updateFilterParentAction})
      : super(key: key);

  @override
  State<CBPFilteringItemListWidget> createState() =>
      _CBPFilteringItemListWidgetState();
}

class _CBPFilteringItemListWidgetState
    extends State<CBPFilteringItemListWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          widget.updatedFilterList[widget.index].category ==
                  CBPFilterCategory.timeDuration
              ? Radio(
                  activeColor: AppColors.darkBlue,
                  value: widget.updatedFilterList[widget.index]
                      .filters[widget.filterIndex].isSelected,
                  groupValue: widget.selectedTimelineValue,
                  onChanged: (value) {
                    for (int i = 0;
                        i <
                            widget
                                .updatedFilterList[widget.index].filters.length;
                        i++) {
                      if (i == widget.filterIndex) {
                        checkSelectionStatus(widget.checkStatus,
                            widget.updatedFilterList[widget.index], i);
                        widget.filterProvider.toggleFilter(
                            widget.updatedFilterList[widget.index].category,
                            widget.filterIndex);
                      } else {
                        if (widget.updatedFilterList[widget.index].filters[i]
                            .isSelected) {
                          widget.filterProvider.toggleFilter(
                              widget.updatedFilterList[widget.index].category,
                              i);
                        }
                      }
                    }
                  },
                )
              : Checkbox(
                  activeColor: AppColors.darkBlue,
                  value: widget.updatedFilterList[widget.index]
                      .filters[widget.filterIndex].isSelected,
                  onChanged: (value) async {
                    setState(() {
                      checkSelectionStatus(
                          widget.checkStatus,
                          widget.updatedFilterList[widget.index],
                          widget.filterIndex);
                      widget.filterProvider.toggleFilter(
                          widget.updatedFilterList[widget.index].category,
                          widget.filterIndex);
                    });
                    applyCompetencyFilter(widget.index);
                  },
                ),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TitleRegularGrey60(
              Helper().capitalizeFirstCharacter(widget
                  .updatedFilterList[widget.index]
                  .filters[widget.filterIndex]
                  .name),
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  void checkSelectionStatus(List<dynamic> checkStatus, updatedFilter, int i) {
    if (checkStatus.isEmpty) {
      checkStatus.add({'contentType': updatedFilter.category, 'index': i});
    } else {
      bool isExist = false;
      for (int index = 0; index < checkStatus.length; index++) {
        if (checkStatus[index]['contentType'].toString().toLowerCase() ==
            EnglishLang.timeline.toLowerCase()) {
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

  void applyCompetencyFilter(int index) {
    List<String> areaList = [], themeList = [];
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
    if (themeList.isEmpty) {
      widget.filterProvider
          .removeFilter(CompetencyFilterCategory.competencySubtheme);
    }
    if (areaList.isEmpty) {
      widget.filterProvider
          .removeFilter(CompetencyFilterCategory.competencyTheme);
    }
    widget.filterField.clear();
    // Adding corresponding theme and subtheme to list
    if (widget.updatedFilterList[index].category !=
        CompetencyFilterCategory.competencySubtheme) {
      if (themeList.isNotEmpty) {
        widget.filterProvider
            .addCategory(CompetencyFilterCategory.competencySubtheme);
      } else if (areaList.isNotEmpty) {
        widget.filterProvider
            .addCategory(CompetencyFilterCategory.competencyTheme);
      }
      widget.updateFilterParentAction(
          category: widget.updatedFilterList[index].category ==
                  CompetencyFilterCategory.competencyArea
              ? CompetencyFilterCategory.competencyTheme
              : CompetencyFilterCategory.competencySubtheme,
          areaList: areaList,
          themeList: themeList);
    }
  }
}
