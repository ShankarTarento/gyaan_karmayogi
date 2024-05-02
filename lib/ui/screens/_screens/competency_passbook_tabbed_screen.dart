import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants/_constants/storage_constants.dart';
import '../../../models/_models/competency_data_model.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../pages/index.dart';
import '../../widgets/index.dart';

class CompetencyPassbookTabbedScreen extends StatefulWidget {
  final Map<String, dynamic> competency;
  final int index;

  const CompetencyPassbookTabbedScreen(
      {Key key, @required this.competency, this.index = 0})
      : super(key: key);

  @override
  _CompetencyPassbookTabbedScreenState createState() {
    return _CompetencyPassbookTabbedScreenState();
  }
}

class _CompetencyPassbookTabbedScreenState
    extends State<CompetencyPassbookTabbedScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  TabController _controller;
  List<dynamic> enrolmentList = [],
      allCompetency = [],
      filteredCompetencyList = [],
      selectedFilterList = [];
  List<CBPFilterModel> filterList = [];
  List<Map<String, dynamic>> filterField = [], competencyName = [];
  List checkStatus = [];
  bool isLoad = false, isBuild = false;
  CompetencyFilter filterProvider;
  final _storage = FlutterSecureStorage();
  var competencyThemeList;
  var competencyInfo;
  var updatedFilterList;
  var args;

  @override
  void initState() {
    super.initState();
    // _controller = TabController(length: 4, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    enrolmentList = jsonDecode(await _storage.read(key: Storage.enrolmentList));
    getCompetencyCategoizedList();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List tabNames = [
      AppLocalizations.of(context).mStaticAll,
      AppLocalizations.of(context).mStaticCompetencyPassbookTabBehavioural,
      AppLocalizations.of(context).mStaticCompetencyPassbookTabFunctional,
      AppLocalizations.of(context).mStaticCompetencyPassbookTabDomain,
    ];
    if (!isLoad) {
      args = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      competencyThemeList = args['competency'];
      int index = args['index'] != null ? args['index'] : widget.index;
      filteredCompetencyList = competencyThemeList;
      _controller = TabController(
          length: tabNames.length, vsync: this, initialIndex: index);
      _controller.addListener(_handleTabChange);
      isLoad = true;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: AppColors.greys60),
        title: Row(children: [
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                FadeRoute(page: ContactUs()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: SvgPicture.asset(
                'assets/img/help_icon.svg',
                width: 56.0,
                height: 56.0,
              ),
            ),
          ),
        ]),
      ),
      body: DefaultTabController(
          length: tabNames.length,
          child: SafeArea(
              child: NestedScrollView(headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverPersistentHeader(
                delegate: SilverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.darkBlue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    indicatorColor: Colors.white,
                    labelPadding: EdgeInsets.only(top: 0.0),
                    unselectedLabelColor: AppColors.greys60,
                    labelColor: AppColors.darkBlue,
                    labelStyle: GoogleFonts.lato(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.lato(
                      fontSize: 10.0,
                      fontWeight: FontWeight.normal,
                    ),
                    onTap: (int index) {
                      setState(() {
                        filteredCompetencyList = competencyThemeList;
                        searchController.value = TextEditingValue.empty;
                        competencyThemeList = args['competency'];
                        filteredCompetencyList = competencyThemeList;
                        focusNode.unfocus();
                      });
                    },
                    tabs: [
                      for (var tabItem in tabNames)
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Tab(
                            child: Text(
                              tabItem,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                    controller: _controller,
                  ),
                ),
                pinned: true,
                floating: false,
              ),
            ];
          },

                  // TabBar view
                  body: Consumer<CompetencyFilter>(
                      builder: (context, _filterProvider, _) {
            filterProvider = _filterProvider;
            filterList = filterProvider.filters;
            if (filterField.isEmpty && !isBuild) {
              getCompetency();
              isBuild = true;
            }
            return Container(
              color: AppColors.lightBackground,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 32, left: 16, right: 16, bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.78,
                          height: 48,
                          child: TextFormField(
                              controller: searchController,
                              focusNode: focusNode,
                              onChanged: (value) {
                                filterCompetencyOnSearch(value);
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
                                    color: focusNode.hasFocus
                                        ? AppColors.darkBlue
                                        : AppColors.grey08),
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
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
                                hintText:
                                    AppLocalizations.of(context).mStaticSearch,
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
                        IconButton(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              showBottomFilterSheet(clearInfo: true);
                            },
                            icon: Icon(
                              Icons.filter_list,
                              size: 24,
                              color: AppColors.greys87,
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        competencyPassbookCategorizedViewWidget(
                            competencyThemeList: filteredCompetencyList),
                        competencyPassbookCategorizedViewWidget(
                            competencyThemeList: filteredCompetencyList,
                            category: CompetencyAreas.behavioural),
                        competencyPassbookCategorizedViewWidget(
                            competencyThemeList: filteredCompetencyList,
                            category: CompetencyAreas.functional),
                        competencyPassbookCategorizedViewWidget(
                            competencyThemeList: filteredCompetencyList,
                            category: CompetencyAreas.domain),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })))),
    );
  }

  Widget competencyPassbookCategorizedViewWidget(
      {List<dynamic> competencyThemeList, String category = 'all'}) {
    bool isCompetencyExist = false;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: competencyThemeList.length > 0
          ? ListView.builder(
              itemCount: competencyThemeList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (competencyThemeList[index]
                            .competencyArea
                            .name
                            .toString()
                            .toLowerCase() ==
                        category ||
                    category == 'all') {
                  isCompetencyExist = true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CompetencyPassbookCardWidget(
                      themeItem: competencyThemeList[index],
                      callBack: () {
                        Navigator.pushNamed(
                            context, AppUrl.competencyPassbookThemePage,
                            arguments: {
                              'competencyTheme': competencyThemeList[index]
                            });
                      },
                    ),
                  );
                } else {
                  if (index == competencyThemeList.length - 1 &&
                      !isCompetencyExist) {
                    return NoDataWidget(
                      message: AppLocalizations.of(context)
                          .mStaticCompetencyNotFound,
                    );
                  }
                  return SizedBox.shrink();
                }
              })
          : NoDataWidget(
              message: AppLocalizations.of(context).mStaticCompetencyNotFound,
            ),
    );
  }

  void getCompetencyCategoizedList() {
    if (enrolmentList != null && enrolmentList.isNotEmpty) {
      enrolmentList.forEach((course) {
        if (course['completionPercentage'] == 100) {
          if (course['content'] != null &&
              course['content']['competencies_v5'] != null &&
              course['content']['competencies_v5'].isNotEmpty) {
            course['content']['competencies_v5'].forEach((competency) {
              allCompetency.add(CompetencyPassbook.fromJson(
                  competency, course['content']['identifier']));
            });
          }
        }
      });
    }
    print(allCompetency);
  }

  void filterCompetencyOnSearch(value) {
    filteredCompetencyList = [];
    setState(() {
      filteredCompetencyList = competencyThemeList.where((competencyTheme) {
        return ((competencyTheme.theme.name).toLowerCase())
            .contains(value.toLowerCase()) as bool;
      }).toList();
    });
  }

  Future<void> getCompetency() async {
    competencyInfo = await Provider.of<LearnRepository>(context, listen: false)
        .getCompetencySearchInfo();
    updateCompetencyFilter(category: CompetencyFilterCategory.competencyArea);
    Future.delayed((Duration(milliseconds: 500)), () {
      if (filterField != null && filterField.isNotEmpty) {
        filterProvider.addFilters(filterField);
      }
    });
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

  Future<bool> showBottomFilterSheet({bool clearInfo = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(
            16,
          ),
          topLeft: Radius.circular(
            16,
          ),
        ),
      ),
      builder: (BuildContext context) {
        return Consumer<CompetencyFilter>(
          builder: (context, filterProvider, _) {
            updatedFilterList = List.from(filterProvider.filters);
            Future.delayed(Duration(microseconds: 100), () {
              if (checkStatus.isNotEmpty && clearInfo) {
                for (int index = 0; index < updatedFilterList.length; index++) {
                  var list = updatedFilterList[index];
                  if (list.category ==
                          CompetencyFilterCategory.competencyTheme ||
                      list.category ==
                          CompetencyFilterCategory.competencySubtheme) {
                    filterProvider.removeFilter(list.category);
                  }
                  for (int filterIndex = 0;
                      filterIndex < list.filters.length;
                      filterIndex++) {
                    checkStatus.forEach((element) {
                      if (element['contentType'] == list.category &&
                          element['index'] == filterIndex) {
                        filterProvider.toggleFilter(list.category, filterIndex);
                      }
                    });
                  }
                }
                checkStatus.clear();
              } else if (checkStatus.isEmpty && clearInfo) {
                List<String> areaList = [], themeList = [];
                //Get the list of themes being selected
                updatedFilterList.forEach((filterItem) {
                  if (filterItem.category ==
                      CompetencyFilterCategory.competencyArea) {
                    filterItem.filters.forEach((element) {
                      if (element.isSelected) {
                        areaList.add(element.name);
                      }
                    });
                  } else if (filterItem.category ==
                      CompetencyFilterCategory.competencyTheme) {
                    filterItem.filters.forEach((element) {
                      if (element.isSelected) {
                        themeList.add(element.name);
                      }
                    });
                  }
                });
                updateCompetencyFilter(
                    category: CompetencyFilterCategory.competencyTheme,
                    areaList: areaList,
                    themeList: themeList);
                updateCompetencyFilter(
                    category: CompetencyFilterCategory.competencySubtheme,
                    areaList: areaList,
                    themeList: themeList);
                filterProvider.addFilters(filterField);
              }
              clearInfo = false;
            });
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: StatefulBuilder(builder: (BuildContext context, setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 88,
                        child: FractionallySizedBox(
                          heightFactor: 1,
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: AppColors.greys60,
                                        borderRadius:
                                            BorderRadius.circular(60)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mStaticFilterResults,
                                          style: GoogleFonts.montserrat(
                                              color: AppColors.greys87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.12),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          filterProvider.removeFilter(
                                              CompetencyFilterCategory
                                                  .competencySubtheme);
                                          filterProvider.removeFilter(
                                              CompetencyFilterCategory
                                                  .competencyTheme);
                                          for (int index = 0;
                                              index < updatedFilterList.length;
                                              index++) {
                                            for (int filterIndex = 0;
                                                filterIndex <
                                                    updatedFilterList[index]
                                                        .filters
                                                        .length;
                                                filterIndex++) {
                                              if (updatedFilterList[index]
                                                  .filters[filterIndex]
                                                  .isSelected) {
                                                filterProvider.toggleFilter(
                                                    updatedFilterList[index]
                                                        .category,
                                                    filterIndex);
                                              }
                                            }
                                          }
                                          setState(() {
                                            filteredCompetencyList =
                                                competencyThemeList;
                                          });
                                        },
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          // padding: EdgeInsets.only(left: 50),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .mStaticClearAll,
                                              style: GoogleFonts.lato(
                                                  color: AppColors.darkBlue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.25),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: AppColors.darkGrey,
                                  thickness: 1,
                                  height: 0,
                                ),
                                CompetencyPassbookFilterWidget(
                                    updatedFilterList: updatedFilterList,
                                    checkStatus: checkStatus,
                                    competencyName: competencyName,
                                    filterField: filterField,
                                    competencyInfo: competencyInfo,
                                    filterProvider: filterProvider,
                                    doRefresh: true),
                                SizedBox(
                                  height: 200,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 88,
                        child: Container(
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.grey08, width: 1),
                              color: AppColors.appBarBackground),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonWidget(
                                  title: AppLocalizations.of(context)
                                      .mStaticCancel,
                                  bgColor: AppColors.appBarBackground,
                                  textColor: AppColors.darkBlue,
                                  onPressed: () {
                                    for (int index = 0;
                                        index < updatedFilterList.length;
                                        index++) {
                                      var list = updatedFilterList[index];
                                      for (int filterIndex = 0;
                                          filterIndex < list.filters.length;
                                          filterIndex++) {
                                        checkStatus.forEach((element) {
                                          if (element['contentType'] ==
                                                  list.category &&
                                              element['index'] == filterIndex) {
                                            filterProvider.toggleFilter(
                                                list.category, filterIndex);
                                          }
                                        });
                                      }
                                    }
                                    checkStatus.clear();
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 20),
                              ButtonWidget(
                                  title: AppLocalizations.of(context)
                                      .mCompetenciesContentTypeApplyFilters,
                                  onPressed: () async {
                                    checkStatus.forEach((element) {
                                      for (int index = 0;
                                          index < updatedFilterList.length;
                                          index++) {
                                        var list = updatedFilterList[index];
                                        for (int filterIndex = 0;
                                            filterIndex < list.filters.length;
                                            filterIndex++) {
                                          if (element['contentType'] ==
                                                  list.category &&
                                              element['index'] == filterIndex) {
                                            list.filters[filterIndex]
                                                    .isSelected =
                                                !list.filters[filterIndex]
                                                    .isSelected;
                                            filterProvider.toggleFilter(
                                                list.category, filterIndex);
                                          }
                                        }
                                      }
                                    });
                                    checkStatus.clear();
                                    selectedFilterList = updatedFilterList;
                                    await filterCourses();
                                    Navigator.pop(context);
                                  })
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Future<void> filterCourses() async {
    List<CompetencyTheme> filteredList = [];
    List<dynamic> tempList = List.from(competencyThemeList);
    //Fetch enrolment list from storage
    enrolmentList = jsonDecode(await _storage.read(key: Storage.enrolmentList));
    selectedFilterList.forEach((element) {
      switch (element.category) {
        // Filtering based on competency area
        case CompetencyFilterCategory.competencyArea:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((competency) {
                if (competency.competencyArea.name.toString().toLowerCase() ==
                    item.name.toString().toLowerCase()) {
                  filteredList.add(competency);
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on competency theme
        case CompetencyFilterCategory.competencyTheme:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((competency) {
                if (competency.theme.name.toString().toLowerCase() ==
                    item.name.toString().toLowerCase()) {
                  var list = filteredList.firstWhere(
                      (filtereditem) =>
                          filtereditem.theme.name.toLowerCase() ==
                          item.name.toString().toLowerCase(),
                      orElse: () => CompetencyTheme());
                  if (list.competencyArea == null) {
                    filteredList.add(competency);
                  }
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on competency sub-theme
        case CompetencyFilterCategory.competencySubtheme:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((competency) {
                if (competency.competencySubthemes != null &&
                    competency.competencySubthemes.isNotEmpty) {
                  competency.competencySubthemes.forEach((subtheme) {
                    if (subtheme.name.toString().toLowerCase() ==
                        item.name.toString().toLowerCase()) {
                      var list = filteredList.firstWhere(
                          (filtereditem) =>
                              filtereditem.theme.name.toLowerCase() ==
                              item.name.toString().toLowerCase(),
                          orElse: () => CompetencyTheme());
                      if (list.competencyArea == null) {
                        filteredList.add(competency);
                      }
                    }
                  });
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        default:
      }
    });
    setState(() {
      filteredCompetencyList = tempList;
    });
  }

  // Listener function to be called when the tab changes.
  void _handleTabChange() {
    if (updatedFilterList != null && updatedFilterList.runtimeType != String) {
      filterProvider.removeFilter(CompetencyFilterCategory.competencySubtheme);
      filterProvider.removeFilter(CompetencyFilterCategory.competencyTheme);
      for (int index = 0; index < updatedFilterList.length; index++) {
        for (int filterIndex = 0;
            filterIndex < updatedFilterList[index].filters.length;
            filterIndex++) {
          if (updatedFilterList[index].filters[filterIndex].isSelected) {
            filterProvider.toggleFilter(
                updatedFilterList[index].category, filterIndex);
          }
        }
      }
    }
  }
}
