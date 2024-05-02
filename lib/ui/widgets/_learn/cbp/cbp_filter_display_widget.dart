import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants/index.dart';
import '../../../../models/index.dart';
import '../../../../respositories/_respositories/learn_repository.dart';
import '../../index.dart';

class CBPFilterDisplayWidget extends StatefulWidget {
  const CBPFilterDisplayWidget(
      {Key key,
      @required this.allCourseList,
      @required this.filterParentAction,
      @required this.updateFilterParentAction})
      : super(key: key);

  final List<Course> allCourseList;
  final ValueChanged<bool> filterParentAction;
  final Function(
      {String category,
      List<String> areaList,
      List<String> themeList}) updateFilterParentAction;

  @override
  State<CBPFilterDisplayWidget> createState() => _CBPFilterDisplayWidgetState();
}

class _CBPFilterDisplayWidgetState extends State<CBPFilterDisplayWidget> {
  LearnRepository learnReprository = LearnRepository();
  List<Course> allCourseList = [];
  List<Course> filteredListOfCourses = [];
  List<CBPFilterModel> filterList = [];
  List<Map<String, dynamic>> competencyName = [];
  List<Map<String, dynamic>> filterField = [];
  CBPFilter filterProvider;

  var competencyInfo, providerInfo;

  @override
  void initState() {
    super.initState();
    allCourseList = widget.allCourseList;
    filteredListOfCourses = widget.allCourseList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CBPFilter>(
      builder: (context, _filterProvider, _) {
        filterProvider = _filterProvider;
        filterList = filterProvider.filters;
        if (filterField.isEmpty) {
          getCompetencyAndProviders();
        }
        return Column(
          children: [
            Container(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  for (int index = 0; index < filterList.length; index++)
                    for (int filterIndex = 0;
                        filterIndex < (filterList[index].filters.length);
                        filterIndex++)
                      filterList[index].filters[filterIndex].isSelected
                          ? AnimationConfiguration.staggeredList(
                              position: filterIndex,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 10.0,
                                      right: 15.0,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGrey,
                                      border:
                                          Border.all(color: AppColors.grey08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          filterList[index]
                                              .filters[filterIndex]
                                              .name,
                                          style: GoogleFonts.lato(
                                            color: AppColors.greys87,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            filterProvider.toggleFilter(
                                                filterList[index].category,
                                                filterIndex);
                                            List<String> areaList = [],
                                                themeList = [];
                                            //Get the list of areas and themes being selected
                                            filterList.forEach((filterItem) {
                                              if (filterItem.category ==
                                                  CompetencyFilterCategory
                                                      .competencyArea) {
                                                filterItem.filters
                                                    .forEach((element) {
                                                  if (element.isSelected) {
                                                    areaList.add(element.name);
                                                  }
                                                });
                                              } else if (areaList.isNotEmpty &&
                                                  filterItem.category ==
                                                      CompetencyFilterCategory
                                                          .competencyTheme) {
                                                filterItem.filters
                                                    .forEach((element) {
                                                  if (element.isSelected) {
                                                    themeList.add(element.name);
                                                  }
                                                });
                                              }
                                            });
                                            if (themeList.isEmpty) {
                                              filterProvider.removeFilter(
                                                  CompetencyFilterCategory
                                                      .competencySubtheme);
                                            }
                                            if (areaList.isEmpty) {
                                              filterProvider.removeFilter(
                                                  CompetencyFilterCategory
                                                      .competencyTheme);
                                            }
                                            filterField.clear();
                                            // Adding corresponding theme and subtheme to list
                                            if (filterList[index].category !=
                                                CompetencyFilterCategory
                                                    .competencySubtheme) {
                                              if (themeList.isNotEmpty) {
                                                filterProvider.addCategory(
                                                    CompetencyFilterCategory
                                                        .competencySubtheme);
                                              } else if (areaList.isNotEmpty) {
                                                filterProvider.addCategory(
                                                    CompetencyFilterCategory
                                                        .competencyTheme);
                                              }
                                              widget.updateFilterParentAction(
                                                  category: filterList[index]
                                                              .category ==
                                                          CompetencyFilterCategory
                                                              .competencyArea
                                                      ? CompetencyFilterCategory
                                                          .competencyTheme
                                                      : CompetencyFilterCategory
                                                          .competencySubtheme,
                                                  areaList: areaList,
                                                  themeList: themeList);
                                            }
                                            widget.filterParentAction(true);
                                          },
                                          child: Container(
                                            height: 22,
                                            width: 30,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.close,
                                                color: AppColors.darkBlue,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink()
                ],
              ),
            )),
            FilteredCourseViewWidget(
                filteredListOfCourses: widget.allCourseList)
          ],
        );
      },
    );
  }

  void updateProviderFilter(providerInfo) {
    List<Map<String, dynamic>> providerNameList = [];
    if (providerInfo != null &&
        providerInfo.runtimeType != String &&
        providerInfo.isNotEmpty) {
      providerInfo.forEach((element) {
        providerNameList.add({'name': element['name'], 'id': element['orgId']});
      });
      // Add competency filters to CBPFilter list
      if (providerNameList.isNotEmpty) {
        providerNameList.sort(((a, b) => a['name'].compareTo(b['name'])));
        filterField.add({
          'category': CBPFilterCategory.provider,
          'values': providerNameList
        });
      }
    }
  }

  Future<void> getCompetencyAndProviders() async {
    competencyInfo = await Provider.of<LearnRepository>(context, listen: false)
        .getCompetencySearchInfo();
    providerInfo = await Provider.of<LearnRepository>(context, listen: false)
        .getSearchByProvider();
    if (providerInfo != null && providerInfo.runtimeType != String) {
      updateProviderFilter(providerInfo);
    }
    if (competencyInfo != null && competencyInfo.runtimeType != String) {
      widget.updateFilterParentAction(
          category: CompetencyFilterCategory.competencyArea,
          areaList: [],
          themeList: []);
    }
    Future.delayed((Duration(milliseconds: 500)), () {
      if (filterField != null && filterField.isNotEmpty) {
        filterProvider.addFilters(filterField);
      }
    });
  }
}
