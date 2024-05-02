import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../../../localization/_langs/english_lang.dart';
import '../../../util/helper.dart';
import '../index.dart';

class FilteringItemListWidget extends StatelessWidget {
  final updatedFilterList;
  final int index, filterIndex;
  final CompetencyFilter filterProvider;
  final List checkStatus;
  final List<Map<String, dynamic>> filterField, competencyName;
  final competencyInfo;
  const FilteringItemListWidget(
      {Key key,
      @required this.updatedFilterList,
      @required this.index,
      @required this.filterIndex,
      @required this.filterProvider,
      @required this.checkStatus,
      @required this.filterField,
      @required this.competencyName,
      @required this.competencyInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Checkbox(
            activeColor: AppColors.darkBlue,
            value: updatedFilterList[index].filters[filterIndex].isSelected,
            onChanged: (value) {
              checkSelectionStatus(
                  checkStatus, updatedFilterList[index], filterIndex);
              filterProvider.toggleFilter(
                  updatedFilterList[index].category, filterIndex);
              List<String> areaList = [], themeList = [];
              //Get the list of areas and themes being selected
              updatedFilterList.forEach((filterItem) {
                if (filterItem.category ==
                    CompetencyFilterCategory.competencyArea) {
                  filterItem.filters.forEach((element) {
                    if (element.isSelected) {
                      areaList.add(element.name);
                    }
                  });
                } else if (areaList.isNotEmpty &&
                    filterItem.category ==
                        CompetencyFilterCategory.competencyTheme) {
                  filterItem.filters.forEach((element) {
                    if (element.isSelected) {
                      themeList.add(element.name);
                    }
                  });
                }
              });
              if (themeList.isEmpty) {
                filterProvider
                    .removeFilter(CompetencyFilterCategory.competencySubtheme);
              }
              if (areaList.isEmpty) {
                filterProvider
                    .removeFilter(CompetencyFilterCategory.competencyTheme);
              }
              filterField.clear();
              // Adding corresponding theme and subtheme to list
              if (updatedFilterList[index].category !=
                  CompetencyFilterCategory.competencySubtheme) {
                if (themeList.isNotEmpty) {
                  filterProvider
                      .addCategory(CompetencyFilterCategory.competencySubtheme);
                } else if (areaList.isNotEmpty) {
                  filterProvider
                      .addCategory(CompetencyFilterCategory.competencyTheme);
                }
                updateCompetencyFilter(
                    category: updatedFilterList[index].category ==
                            CompetencyFilterCategory.competencyArea
                        ? CompetencyFilterCategory.competencyTheme
                        : CompetencyFilterCategory.competencySubtheme,
                    areaList: areaList,
                    themeList: themeList);
                filterProvider.addFilters(filterField);
              }
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TitleRegularGrey60(
              Helper().capitalizeFirstCharacter(
                  updatedFilterList[index].filters[filterIndex].name),
              fontSize: 14,
              maxLines: 1,
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

  void updateCompetencyFilter(
      {String category, List<String> areaList, List<String> themeList}) {
    competencyName.clear();
    if (competencyInfo != null &&
        competencyInfo.runtimeType != String &&
        competencyInfo['competency'].isNotEmpty) {
      if (category == CompetencyFilterCategory.competencyArea) {
        competencyInfo['competency'].forEach((element) {
          competencyName.add({'name': element['name']});
        });
      } else if (category == CompetencyFilterCategory.competencyTheme &&
          areaList != null &&
          areaList.isNotEmpty) {
        areaList.forEach((area) {
          competencyInfo['competency'].forEach((element) {
            if (element['name'].toString().toLowerCase() ==
                    area.toLowerCase() &&
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
          competencyInfo['competency'].forEach((element) {
            if (element['name'].toString().toLowerCase() ==
                    area.toLowerCase() &&
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
      // Add competency filters to CBPFilter list
      if (competencyName.isNotEmpty) {
        competencyName.sort(((a, b) => a['name'].compareTo(b['name'])));
        filterField.add({'category': category, 'values': competencyName});
      }
    }
  }
}
