import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import './../../../ui/pages/_pages/network/my_mdo.dart';
import '../../../util/faderoute.dart';
import '../../widgets/_signup/contact_us.dart';
import './../../../ui/pages/index.dart';
import '../../../constants/index.dart';
import '../../widgets/index.dart';
import './../../../localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearningHub extends StatefulWidget {
  static const route = AppUrl.learningHub;

  @override
  _LearningHubState createState() => _LearningHubState();
}

class _LearningHubState extends State<LearningHub>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  final service = HttpClient();

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _controller = TabController(
        length: LearnMainTab.items(context: context).length,
        vsync: this,
        initialIndex: 0);
    _scrollController = ScrollController();
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void switchIntoYourLearningTab() {
    setState(() {
      _controller.index = 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        duration: Duration(milliseconds: 0),
        child: DefaultTabController(
          length: LearnMainTab.items(context: context).length,
          child: SafeArea(
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leading: BackButton(color: AppColors.greys60),
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsets.fromLTRB(50.0, 0.0, 10.0, 0.0),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/img/Learn.svg',
                            color: AppColors.darkBlue,
                            width: 24.0,
                            height: 24.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12.0, top: 10.0),
                            child: SizedBox(
                              width: 90,
                              child: Text(
                                AppLocalizations.of(context).mStaticLearn,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.greys87,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Spacer(),
                          KarmaPointAppbarWidget(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                FadeRoute(page: ContactUs()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
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
                  ),
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
                        tabs: [
                          for (var tabItem
                              in LearnMainTab.items(context: context))
                            Container(
                              // width: 125.0,
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
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
                        controller: _controller,
                      ),
                    ),
                    pinned: true,
                    floating: false,
                  ),
                ];
              },

              // TabBar view
              body: Container(
                color: AppColors.lightBackground,
                child: FutureBuilder(
                    future: Future.delayed(Duration(milliseconds: 500)),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return TabBarView(
                        controller: _controller,
                        children: [
                          LearningHubPage(
                            parentAction: switchIntoYourLearningTab,
                          ),
                          YourLearningPage(),
                          BrowseLearnPage(),
                          // BitesPage(),
                          ComingSoon(
                            removeGoToWebButton: true,
                          )
                        ],
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: BottomBar(),
    );
  }
}
