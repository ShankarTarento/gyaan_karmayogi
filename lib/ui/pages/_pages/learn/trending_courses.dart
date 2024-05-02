import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
// import 'package:karmayogi_mobile/models/_models/provider_model.dart';
import 'package:provider/provider.dart';
import '../../../../util/faderoute.dart';
import '../../../widgets/_signup/contact_us.dart';
import './../../../../constants/index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class TrendingCoursesPage extends StatefulWidget {
  String selectedContentType;
  final bool isProgram;
  final bool isStandaloneAssessment;
  final bool isModerated;
  final bool isBlendedProgram;
  final bool isCuratedProgram;
  final String title;
  TrendingCoursesPage(
      {Key key,
      this.selectedContentType = 'course',
      this.isProgram = false,
      this.isStandaloneAssessment = false,
      this.isModerated = false,
      this.isBlendedProgram = false,
      this.isCuratedProgram = false,
      this.title});

  @override
  _TrendingCoursesPageState createState() => _TrendingCoursesPageState();
}

class _TrendingCoursesPageState extends State<TrendingCoursesPage> {
  final service = HttpClient();
  final LearnService learnService = LearnService();
  int pageNo = 1;
  int pageCount;
  int currentPage;

  List _data = [];
  Future<dynamic> _coursesList;
  RouteSettings settings;

  String dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.trendingCourses,
    EnglishLang.recentCourses
  ];

  List contentTypes = [
    EnglishLang.program,
    EnglishLang.course,
    EnglishLang.standaloneAssessment,
    EnglishLang.moderatedCourse.toLowerCase()
    // EnglishLang.learningResource,
  ];

  List resourceTypes = [
    EnglishLang.interactiveContent,
    EnglishLang.image,
    EnglishLang.webpage,
    EnglishLang.assessment,
    EnglishLang.pdf,
    EnglishLang.course,
    EnglishLang.video,
    EnglishLang.audio
  ];

  List providers = [];
  // List<ProviderCardModel> _providersList = [];

  List<String> selectedContentTypes = [PrimaryCategory.course];
  List<String> selectedResourceTypes = [];
  List<String> actualResourceTypes = [];
  List<String> selectedProviders = [];
  Map resourceTypeMapping = {
    EnglishLang.interactiveContent: [
      'application/vnd.ekstep.html-archive',
      'application/vnd.ekstep.ecml-archive'
    ],
    EnglishLang.image: ['image/jpeg', 'image/png'],
    EnglishLang.webpage: ['text/x-url'],
    EnglishLang.assessment: ['application/json', 'application/quiz'],
    EnglishLang.pdf: ['application/pdf'],
    EnglishLang.course: ['application/vnd.ekstep.content-collection'],
    EnglishLang.video: [
      'video/mp4',
      'video/x-youtube',
      'application/x-mpegURL'
    ],
    EnglishLang.audio: ['audio/mpeg'],
  };

  bool _showLoader = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _getListOfProviders();
    setState(() {
      dropdownValue = EnglishLang.trendingCourses;
    });
    if (widget.isProgram) {
      setState(() {
        selectedContentTypes = [PrimaryCategory.program];
      });
    }
    if (widget.isStandaloneAssessment) {
      setState(() {
        selectedContentTypes = [PrimaryCategory.standaloneAssessment];
      });
    }
    if (widget.isModerated) {
      setState(() {
        selectedContentTypes = [EnglishLang.moderatedCourse.toLowerCase()];
      });
    }
    if (widget.isBlendedProgram) {
      setState(() {
        selectedContentTypes = [EnglishLang.blendedProgram.toLowerCase()];
      });
    }
    if (widget.isCuratedProgram) {
      setState(() {
        selectedContentTypes = [PrimaryCategory.curatedProgram.toLowerCase()];
      });
    }
    _getPageDetails();
    _coursesList = _getTrendingCourses();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Future<List<ProviderCardModel>> _getListOfProviders() async {
  //   _providersList = await Provider.of<LearnRepository>(context, listen: false)
  //       .getListOfProviders();

  //   for (var provider in _providersList) {
  //     providers.add(provider.name);
  //   }
  //   providers.removeWhere((value) => value == null);
  //   return _providersList;
  // }

  /// Get recent discussions
  Future<dynamic> _getTrendingCourses() async {
    try {
      _data.addAll(await Provider.of<LearnRepository>(context, listen: false)
          .getCourses(pageNo, '', selectedContentTypes, actualResourceTypes,
              selectedProviders,
              isModerated: selectedContentTypes
                  .contains(EnglishLang.moderatedCourse.toLowerCase())));

      _data = _data.toSet().toList();
      _showLoader = false;
      return _data;
    } catch (err) {
      return err;
    }
  }

  /// Get pageDetails
  Future<void> _getPageDetails() async {
    int pageNos;
    try {
      pageNos = await learnService.getTotalCoursePages(
              selectedContentTypes, selectedProviders,
              isModerated: selectedContentTypes
                  .contains(EnglishLang.moderatedCourse.toLowerCase())) ??
          1;
      setState(() {
        pageCount = pageNos;
      });
    } catch (err) {
      return err;
    }
  }

  void updateFilters(Map data) async {
    setState(() {
      pageNo = 1;
      _data = [];
      _showLoader = true;
    });
    switch (data['filter']) {
      case EnglishLang.contentType:
        if (selectedContentTypes.contains(data['item'].toLowerCase()))
          selectedContentTypes.remove(data['item'].toLowerCase());
        else
          selectedContentTypes.add(data['item'].toLowerCase());
        break;
      case EnglishLang.resourceType:
        if (selectedResourceTypes.contains(data['item']))
          selectedResourceTypes.remove(data['item']);
        else
          selectedResourceTypes.add(data['item']);
        actualResourceTypes = [];
        for (var resource in selectedResourceTypes) {
          actualResourceTypes.addAll(resourceTypeMapping[resource]);
        }
        break;
      default:
        // if (!selectedProviders.contains(data['item'].toLowerCase()) &&
        //     selectedProviders.length > 0)
        //   selectedProviders.remove(selectedProviders[0]);
        if (selectedProviders.contains(data['item'].toLowerCase()))
          selectedProviders.remove(data['item'].toLowerCase());
        else
          selectedProviders.add(data['item'].toLowerCase());
        break;
    }
    // print("content types: " + selectedContentTypes.toString());
    // print("resource type: " + selectedResourceTypes.toString());
    // print("providers: " + selectedProviders.toString());
    _coursesList = _getTrendingCourses();
  }

  Future<void> setDefault(String filter) async {
    setState(() {
      pageNo = 1;
      _data = [];
      _showLoader = true;
    });
    switch (filter) {
      case EnglishLang.contentType:
        setState(() {
          selectedContentTypes = [];
          // _data = [];
        });

        break;
      case EnglishLang.resourceType:
        setState(() {
          selectedResourceTypes = [];
        });
        break;
      default:
        setState(() {
          selectedProviders = [];
        });
    }
    _coursesList = _getTrendingCourses();

    setState(() {});
  }

  /// Load cards on scroll
  // _loadMore() {
  //   if (pageNo < pageCount) {
  //     setState(() {
  //       pageNo = pageNo + 1;
  //     });
  //     _coursesList = _getTrendingCourses();
  //   }
  // }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              '',
              style: GoogleFonts.montserrat(
                color: AppColors.greys87,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
          future: _coursesList,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if ((snapshot.hasData &&
                    (snapshot.data != null && _data.length > 0)) &&
                !_showLoader) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TitleBoldWidget(widget.title),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    color: AppColors.whiteGradientOne,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: BrowseCard(
                                      course: _data[index],
                                      isProgram: widget.selectedContentType ==
                                              PrimaryCategory.program
                                          ? true
                                          : false,
                                      isBlendedProgram: widget.isBlendedProgram,
                                      isModerated: widget.isModerated,
                                      isCuratedProgram:
                                          widget.isCuratedProgram),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // if (pageNo < pageCount)
                  //   Center(
                  //     child: Container(
                  //         height: 24,
                  //         width: 24,
                  //         margin: EdgeInsets.all(16),
                  //         child: PageLoader()),
                  //   )
                ],
              );
            } else if (_data.length == 0 &&
                snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 125),
                            child: SvgPicture.asset(
                              'assets/img/empty_search.svg',
                              alignment: Alignment.center,
                              // color: AppColors.grey16,
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          EnglishLang.noResultsFound,
                          style: GoogleFonts.lato(
                            color: AppColors.greys60,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            AppLocalizations.of(context).mStaticNoResultsFound,
                            style: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.25,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              );
            } else {
              return PageLoader(
                bottom: 150,
              );
            }
          },
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   child: Container(
      //     // height: _activeTabIndex == 0 ? 60 : 0,
      //     height: 60,
      //     child: Row(
      //       children: [
      //         Container(
      //           margin: const EdgeInsets.all(10),
      //           child: IconButton(
      //               icon: Icon(
      //                 Icons.filter_list,
      //                 color: Colors.white,
      //               ),
      //               onPressed: () {}),
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(8),
      //             color: AppColors.primaryThree,
      //           ),
      //           height: 40,
      //         ),
      //         Expanded(
      //           child: ListView(
      //             scrollDirection: Axis.horizontal,
      //             shrinkWrap: true,
      //             // mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               InkWell(
      //                 onTap: () => {
      //                   // print('Selected: $selectedContentTypes'),
      //                   Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder: (context) => CourseFilters(
      //                         filterName: EnglishLang.contentType,
      //                         items: contentTypes,
      //                         selectedItems: selectedContentTypes,
      //                         parentAction1: updateFilters,
      //                         parentAction2: setDefault,
      //                       ),
      //                     ),
      //                   ),
      //                 },
      //                 child: Container(
      //                     margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      //                     padding: const EdgeInsets.only(left: 0, right: 0),
      //                     height: 40,
      //                     child: FilterCard(
      //                         EnglishLang.contentType,
      //                         selectedContentTypes.length == 1
      //                             ? selectedContentTypes[0].toUpperCase()
      //                             : selectedContentTypes.length == 0
      //                                 ? EnglishLang.all
      //                                 : (selectedResourceTypes.length == 0
      //                                     ? EnglishLang.all
      //                                     : EnglishLang.multipleSelected))),
      //               ),
      //               // InkWell(
      //               //   onTap: () => {
      //               //     Navigator.push(
      //               //       context,
      //               //       MaterialPageRoute(
      //               //         builder: (context) => CourseFilters(
      //               //           filterName: EnglishLang.resourceType,
      //               //           items: resourceTypes,
      //               //           selectedItems: selectedResourceTypes,
      //               //           parentAction1: updateFilters,
      //               //           parentAction2: setDefault,
      //               //         ),
      //               //       ),
      //               //     ),
      //               //   },
      //               //   child: Container(
      //               //       margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      //               //       padding: const EdgeInsets.only(left: 10, right: 10),
      //               //       height: 40,
      //               //       child: FilterCard(
      //               //           EnglishLang.resourceType,
      //               //           selectedResourceTypes.length == 1
      //               //               ? selectedResourceTypes[0].toUpperCase()
      //               //               : (selectedResourceTypes.length == 0
      //               //                   ? EnglishLang.all
      //               //                   : EnglishLang.multipleSelected))),
      //               // ),
      //               InkWell(
      //                   onTap: () => {
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) => CourseFilters(
      //                               filterName: EnglishLang.providers,
      //                               items: providers,
      //                               selectedItems: selectedProviders,
      //                               parentAction1: updateFilters,
      //                               parentAction2: setDefault,
      //                             ),
      //                           ),
      //                         ),
      //                       },
      //                   child: Container(
      //                       margin: const EdgeInsets.fromLTRB(8, 10, 0, 10),
      //                       padding: const EdgeInsets.only(left: 0, right: 0),
      //                       height: 40,
      //                       child: FilterCard(
      //                           EnglishLang.providers,
      //                           selectedProviders.length == 1
      //                               ? selectedProviders[0].toUpperCase()
      //                               : (selectedProviders.length == 0
      //                                   ? EnglishLang.all
      //                                   : EnglishLang.multipleSelected)))),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // )
    );
  }
}
