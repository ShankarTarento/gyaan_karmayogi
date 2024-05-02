import 'dart:convert';

class Review {
  final String objectType;
  final String userId;
  final int date;
  final double rating;
  final String review;
  final String firstName;

  Review({
    this.objectType,
    this.userId,
    this.date,
    this.rating,
    this.review,
    this.firstName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      objectType: json['objectType'],
      userId: json['user_id'],
      date: json['date'],
      rating: json['rating'].toDouble(),
      review: json['review'],
      firstName: json['firstName'],
    );
  }
}

class OverallRating {
  String activityId;
  String activityType;
  double totalCount1Stars;
  double totalCount2Stars;
  double totalCount3Stars;
  double totalCount4Stars;
  double totalCount5Stars;
  double totalNumberOfRatings;
  double sumOfTotalRatings;
  List<Review> reviews;

  OverallRating({
    this.activityId,
    this.activityType,
    this.totalCount1Stars,
    this.totalCount2Stars,
    this.totalCount3Stars,
    this.totalCount4Stars,
    this.totalCount5Stars,
    this.totalNumberOfRatings,
    this.sumOfTotalRatings,
    this.reviews,
  });

  factory OverallRating.fromJson(Map<String, dynamic> json) {
    List<dynamic> reviewsJson = json != null &&
            json.containsKey('latest50Reviews') &&
            json['latest50Reviews'] != null
        ? jsonDecode(json['latest50Reviews']) as List
        : [];

    List<Review> reviews = reviewsJson.isNotEmpty
        ? reviewsJson
            .map((review) => Review.fromJson(review as Map<String, dynamic>))
            .toList()
        : [];

    return OverallRating(
      activityId: json['activityId'],
      activityType: json['activityType'],
      totalCount1Stars: json['totalcount1stars'],
      totalCount2Stars: json['totalcount2stars'],
      totalCount3Stars: json['totalcount3stars'],
      totalCount4Stars: json['totalcount4stars'],
      totalCount5Stars: json['totalcount5stars'],
      totalNumberOfRatings: json['total_number_of_ratings'],
      sumOfTotalRatings: json['sum_of_total_ratings'],
      reviews: reviews,
    );
  }
}

class TopReview {
  final String activityId;
  final String review;
  final String rating;
  final String updatedOn;
  final String updatedOnUUID;
  final String activityType;
  final String userId;
  final String firstName;

  TopReview({
    this.activityId,
    this.review,
    this.rating,
    this.updatedOn,
    this.updatedOnUUID,
    this.activityType,
    this.userId,
    this.firstName,
  });

  factory TopReview.fromJson(Map<String, dynamic> json) {
    return TopReview(
      activityId: json['activityId'],
      review: json['review'],
      rating: json['rating'].toString(),
      updatedOn: json['updatedon'].toString(),
      updatedOnUUID: json['updatedOnUUID'],
      activityType: json['activityType'],
      userId: json['userId'],
      firstName: json['firstName'],
    );
  }
}
