import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/index.dart';
import '../../../../util/faderoute.dart';
import '../../../widgets/_signup/contact_us.dart';
import '../../../widgets/index.dart';

class ShowAllCourses extends StatefulWidget {
  final List<Course> courseList;
  final String title;
  const ShowAllCourses({Key key, this.courseList, this.title})
      : super(key: key);

  @override
  _ShowAllCoursesState createState() => _ShowAllCoursesState();
}

class _ShowAllCoursesState extends State<ShowAllCourses> {
  List<Course> courseDisplayList = [];
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> updateCourseList() async {
    try {
      if (widget.courseList.length >= courseDisplayList.length + 5) {
        courseDisplayList.addAll(widget.courseList
            .sublist(courseDisplayList.length, courseDisplayList.length + 5));
      } else {
        courseDisplayList.addAll(widget.courseList.sublist(
            courseDisplayList.length,
            widget
                .courseList.length)); // If original list has less than 5 items
      }
      _showLoader = false;
      return courseDisplayList;
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() {
    super.dispose();
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
      body: NotificationListener<ScrollNotification>(
        // ignore: missing_return
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (widget.courseList.length != courseDisplayList.length) {
              setState(() {});
            }
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: updateCourseList(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if ((snapshot.hasData &&
                      (snapshot.data != null &&
                          courseDisplayList.length > 0)) &&
                  !_showLoader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TitleBoldWidget(widget.title),
                    ),
                    AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: courseDisplayList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < courseDisplayList.length) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: BrowseCard(
                                      course: courseDisplayList[index],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (courseDisplayList.length !=
                              widget.courseList.length) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 100),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return Center();
                          }
                        },
                      ),
                    )
                  ],
                );
              } else if (courseDisplayList.length == 0) {
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
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            AppLocalizations.of(context).mStaticNoResultsFound,
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
                              AppLocalizations.of(context).mCommonRemoveFilters,
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
      ),
    );
  }
}
