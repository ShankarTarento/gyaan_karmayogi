import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../pages/index.dart';
import '../../widgets/index.dart';
import '../index.dart';

class TocPlayerSkeleton extends StatefulWidget {
  final bool showCourseShareOption;
  final Function courseShareOptionCallback;
  TocPlayerSkeleton(
      {Key key, this.showCourseShareOption, this.courseShareOptionCallback})
      : super(key: key);
  TocPlayerSkeletonState createState() => TocPlayerSkeletonState();
}

class TocPlayerSkeletonState extends State<TocPlayerSkeleton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> animation;
  TabController learnTabController;

  @override
  void didChangeDependencies() {
        learnTabController = TabController(
        length: LearnTab.tocTabs(context).length, vsync: this, initialIndex: 1);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  
    animation = TweenSequence<Color>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
      ],
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: LearnTab.tocTabs(context).length,
        child: Stack(children: [
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SafeArea(
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, innerBoxIsScrolled) {
                    return <Widget>[
                      TocAppbarWidget(
                        isOverview: true,
                        showCourseShareOption: true,
                        courseShareOptionCallback:
                            widget.courseShareOptionCallback,
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width,
                          color: AppColors.grey08,
                        ),
                      ),
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        flexibleSpace: Container(
                          color: AppColors.darkBlue,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            child: Container(
                              padding: EdgeInsets.only(top: 4),
                              color: Colors.white,
                              child: TabBar(
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
                                tabs: [
                                  for (var tabItem in LearnTab.tocTabs(context))
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Tab(
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            tabItem.title,
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                                controller: learnTabController,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(controller: learnTabController, children: [
                    TocAboutSkeletonPage(),
                    TocContentSkeletonPage()
                  ])),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffEEEEEE).withOpacity(0),
                      Color(0xffFFFFFF).withOpacity(1)
                    ],
                  ),
                ),
                child: ContainerSkeleton(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
              )),
        ]));
  }
}
