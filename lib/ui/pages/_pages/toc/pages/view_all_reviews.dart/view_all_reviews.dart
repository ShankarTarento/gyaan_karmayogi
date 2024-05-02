import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/view_all_reviews.dart/widgets/review_filter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/helper.dart';

class ViewAllReviews extends StatefulWidget {
  final Map<String, dynamic> course;

  const ViewAllReviews({Key key, @required this.course}) : super(key: key);

  @override
  State<ViewAllReviews> createState() => _ViewAllReviewsState();
}

class _ViewAllReviewsState extends State<ViewAllReviews> {
  final LearnService learnService = LearnService();
  int dropdownValue = 0;
  List<dynamic> courseReviews;
  int limit = 10;
  List<TopReview> topReview = [];
  List<TopReview> filteredTopReviews = [];
  OverallRating overallRating;
  ScrollController scrollController = ScrollController();
  List<Review> latestReviews = [];
  List<Review> filteredLatestReviews = [];

  @override
  void initState() {
    super.initState();
    getReviews();
    scrollController.addListener(scrollListener);
  }

  filterLatestReviews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLatestReviews = latestReviews;
      } else {
        filteredLatestReviews = latestReviews
            .where((review) =>
                review.review.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void filterReviews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTopReviews = topReview;
      } else {
        filteredTopReviews = topReview
            .where((review) =>
                review.review.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      limit = limit + 5;
      loadMoreReviews();
    }
  }

  Future<void> loadMoreReviews() async {
    topReview = [];
    if (dropdownValue == 0) {
      final response = await learnService.getCourseReview(
        widget.course['identifier'],
        widget.course['primaryCategory'],
        limit,
      );

      if (response != null) {
        setState(() {
          response
              .forEach((element) => topReview.add(TopReview.fromJson(element)));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.chevron_left),
        ),
        iconTheme: IconThemeData(color: AppColors.greys60),
        shadowColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).mStaticReviews,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 16),
                          height: 48,
                          child: TextFormField(
                            onChanged: (value) {
                              if (dropdownValue == 0) {
                                filterReviews(value);
                              } else {
                                filterLatestReviews(value);
                              }
                            },
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            style: GoogleFonts.lato(fontSize: 14.0),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
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
                                borderRadius: BorderRadius.circular(1.0),
                                borderSide: BorderSide(
                                  color: AppColors.primaryThree,
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
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return ReviewFilter(
                                  selectedIndex: dropdownValue,
                                  onChanged: (index) {
                                    dropdownValue = index;
                                    getReviews();
                                  },
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.filter_list,
                            color: AppColors.greys60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dropdownValue == 0
                  ? filteredTopReviews.isEmpty
                      ? 1
                      : filteredTopReviews.length
                  : filteredLatestReviews != null
                      ? filteredLatestReviews.length
                      : 1,
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 10,
                color: AppColors.black16,
                thickness: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (dropdownValue == 0) {
                  if (filteredTopReviews.isEmpty) {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context).mStaticNoReviewsToShow),
                    );
                  }
                  return reviewCard(
                    context: context,
                    name: filteredTopReviews[index].firstName,
                    rating: filteredTopReviews[index].rating,
                    review: filteredTopReviews[index].review,
                    time: filteredTopReviews[index].updatedOn,
                  );
                } else {
                  if (filteredLatestReviews != null &&
                      filteredLatestReviews.isNotEmpty) {
                    return reviewCard(
                      context: context,
                      review: filteredLatestReviews[index].review,
                      time: filteredLatestReviews[index].date.toString(),
                      rating: filteredLatestReviews[index].rating.toString(),
                      name: filteredLatestReviews[index].firstName,
                    );
                  } else {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context).mStaticNoReviewsToShow),
                    );
                  }
                }
              },
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  Widget reviewCard(
      {@required BuildContext context,
      @required String review,
      @required String time,
      @required String rating,
      @required String name}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.25,
                child: Text(
                  review,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.primaryOne,
                  ),
                  Text(
                    "$rating",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greys60,
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.greenTwo,
                child: Text(
                  Helper.getInitials(name),
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                name,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppColors.greys60,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 1,
                  backgroundColor: AppColors.greys60,
                ),
              ),
              Text(
                getReviewTime(time),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppColors.greys60,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  getReviews() async {
    topReview = [];
    if (dropdownValue == 0) {
      final response = await learnService.getCourseReview(
          widget.course['identifier'], widget.course['primaryCategory'], limit);

      if (response != null) {
        response
            .forEach((element) => topReview.add(TopReview.fromJson(element)));
        //  print(topReview);
      }
    } else if (dropdownValue == 1) {
      final response = await learnService.getCourseReviewSummery(
          widget.course['identifier'], widget.course['primaryCategory']);

      if (response != null) {
        overallRating = OverallRating.fromJson(response);
        latestReviews = overallRating.reviews;
        filteredLatestReviews = latestReviews;
      }
    }
    filteredTopReviews = topReview;
    setState(() {});
  }

  String getReviewTime(String time) {
    DateTime now = DateTime.now();
    DateTime reviewTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    Duration difference = now.difference(reviewTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppLocalizations.of(context).mStaticMinutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${AppLocalizations.of(context).mStaticHoursAgo}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${AppLocalizations.of(context).mStaticDaysAgo}';
    } else {
      int months =
          (now.year - reviewTime.year) * 12 + now.month - reviewTime.month;
      return '$months ${AppLocalizations.of(context).mStaticMonthsAgo}';
    }
  }
}
