import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/review.dart';
import 'package:simple_moment/simple_moment.dart';
import '../../../services/_services/learn_service.dart';

class Reviews extends StatefulWidget {
  final List filteredReviews;
  final String courseId;
  final String primaryCategory;

  Reviews({
    this.filteredReviews,
    this.courseId,
    this.primaryCategory,
  });

  @override
  State<Reviews> createState() => _ReviewState();
}

class _ReviewState extends State<Reviews> {
  final LearnService learnService = LearnService();
  final dateNow = Moment.now();
  Future<List> couseCommentsFuture;

  @override
  void initState() {
    super.initState();

    couseCommentsFuture = _getReplyComments();
  }

  Future<List> _getReplyComments() async {
    final List allUserIds = [];
    widget.filteredReviews.forEach((filteredReview) {
      allUserIds.add(filteredReview['userId'] != null
          ? filteredReview['userId']
          : filteredReview['user_id']);
    });

    final response = await learnService.getCourseReviewReply(
        widget.courseId, widget.primaryCategory, allUserIds);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: couseCommentsFuture,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return (snapshot.connectionState != ConnectionState.waiting)
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: widget.filteredReviews.length,
                  itemBuilder: (context, index) {
                    final userId =
                        widget.filteredReviews[index]['userId'] != null
                            ? widget.filteredReviews[index]['userId']
                            : widget.filteredReviews[index]['user_id'];
                    return Review(
                      name: (widget.filteredReviews[index]['firstName'] !=
                                  null &&
                              widget.filteredReviews[index]['lastName'] != null)
                          ? (widget.filteredReviews[index]['firstName'] +
                              ' ' +
                              widget.filteredReviews[index]['lastName'])
                          : ((widget.filteredReviews[index]['firstName'] !=
                                      null &&
                                  widget.filteredReviews[index]['lastName'] ==
                                      null)
                              ? widget.filteredReviews[index]['firstName']
                              : ((widget.filteredReviews[index]['firstName'] ==
                                          null &&
                                      widget.filteredReviews[index]
                                              ['lastName'] !=
                                          null)
                                  ? widget.filteredReviews[index]['lastName']
                                  : 'Unknown user')),
                      rating: widget.filteredReviews[index]['rating'] != null
                          ? double.parse(widget.filteredReviews[index]['rating']
                              .toString())
                          : 0,
                      description:
                          widget.filteredReviews[index]['review'] != null
                              ? widget.filteredReviews[index]['review']
                              : '',
                      updatedOn:
                          widget.filteredReviews[index]['updatedon'] != null
                              ? widget.filteredReviews[index]['updatedon']
                              : widget.filteredReviews[index]['date'],
                      courseId: widget.courseId,
                      primaryCategory: widget.primaryCategory,
                      comment: getComment(snapshot.data, userId),
                      review: getReview(snapshot.data, userId),
                      userId: widget.filteredReviews[index]['userId'] != null
                          ? widget.filteredReviews[index]['userId']
                          : widget.filteredReviews[index]['user_id'],
                    );
                  },
                )
              : CircularProgressIndicator();
        });
  }

  getComment(List ratingData, String userId) {
    final ratingContent = ratingData.firstWhere(
      (element) => element['userId'] == userId,
      orElse: () => {},
    );
    return ratingContent['comment'] ?? '';
  }

  getReview(List ratingData, String userId) {
    final ratingContent = ratingData.firstWhere(
      (element) => element['userId'] == userId,
      orElse: () => {},
    );
    return ratingContent['review'] ?? '';
  }
}
