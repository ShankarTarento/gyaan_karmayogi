import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookFilterWidget extends StatefulWidget {
  CompetencyPassbookFilterWidget(
      {Key key,
      @required this.updatedFilterList,
      @required this.checkStatus,
      @required this.competencyName,
      @required this.filterField,
      @required this.competencyInfo,
      @required this.filterProvider,
      this.doRefresh = false})
      : super(key: key);

  final updatedFilterList;
  final List checkStatus;
  final List<Map<String, dynamic>> competencyName;
  final List<Map<String, dynamic>> filterField;
  final competencyInfo;
  final CompetencyFilter filterProvider;
  bool doRefresh;

  @override
  State<CompetencyPassbookFilterWidget> createState() =>
      _CompetencyPassbookFilterWidgetState();
}

class _CompetencyPassbookFilterWidgetState
    extends State<CompetencyPassbookFilterWidget> {
  final List<TextEditingController> themeController = [];

  List<FocusNode> themeFocusNode = [];
  Map<String, dynamic> filteredCompetency, competencyInfo;
  var updatedFilterList;

  @override
  void initState() {
    super.initState();
    filteredCompetency = widget.competencyInfo;
    competencyInfo = widget.competencyInfo;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doRefresh) {
      updatedFilterList = widget.updatedFilterList;
      // Creating theme controller instances
      if (themeController.length < updatedFilterList.length) {
        for (var i = themeController.length;
            i < updatedFilterList.length;
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
                      child: TitleBoldWidget(updatedFilterList[index].category,
                          fontSize: 14, letterSpacing: 0.25),
                    ),
                    iconColor: AppColors.darkGrey,
                    collapsedIconColor: AppColors.darkGrey,
                    initiallyExpanded: true,
                    children: [
                      updatedFilterList[index].filters.length <= 4 ||
                              index == updatedFilterList.length - 1
                          ? Column(
                              children: [
                                updatedFilterList[index].category !=
                                        CompetencyFilterCategory.competencyArea
                                    ? Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: searchCompetency(index,
                                            updatedFilterList[index].category))
                                    : SizedBox.shrink(),
                                Column(
                                  children: updatedFilterList[index]
                                      .filters
                                      .map<Widget>((filteringItem) =>
                                          FilteringItemListWidget(
                                            updatedFilterList:
                                                updatedFilterList,
                                            index: index,
                                            filterIndex:
                                                updatedFilterList[index]
                                                    .filters
                                                    .indexOf(filteringItem),
                                            filterProvider:
                                                widget.filterProvider,
                                            checkStatus: widget.checkStatus,
                                            competencyName:
                                                widget.competencyName,
                                            filterField: widget.filterField,
                                            competencyInfo: filteredCompetency,
                                          ))
                                      .toList(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                searchCompetency(
                                    index, updatedFilterList[index].category),
                                SizedBox(height: 4),
                                Container(
                                  height: 200,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        updatedFilterList[index].filters.length,
                                    itemBuilder: (context, filterIndex) {
                                      return FilteringItemListWidget(
                                        updatedFilterList: updatedFilterList,
                                        index: index,
                                        filterIndex: filterIndex,
                                        filterProvider: widget.filterProvider,
                                        checkStatus: widget.checkStatus,
                                        competencyName: widget.competencyName,
                                        filterField: widget.filterField,
                                        competencyInfo: filteredCompetency,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                index < updatedFilterList.length - 1
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
          childCount: updatedFilterList.length,
        )),
      ],
    );
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
                  value, updatedFilterList[index].category);
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
    filteredCompetency = competencyInfo;
    List<String> areaList = [], themeList = [];
    List<Map<String, dynamic>> competencyName = [];
    //Get the list of areas and themes being selected
    updatedFilterList.forEach((filterItem) {
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
      competencyInfo['competency'].forEach((element) {
        competencyName.add({'name': element['name']});
      });
    } else if (category == CompetencyFilterCategory.competencyTheme &&
        areaList != null &&
        areaList.isNotEmpty) {
      areaList.forEach((area) {
        competencyInfo['competency'].forEach((element) {
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
        competencyInfo['competency'].forEach((element) {
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
