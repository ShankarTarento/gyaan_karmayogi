import 'package:flutter/material.dart';

class DeepLink {
  final String url;
  final String category;
  final rawDetails;

  const DeepLink(
      {@required this.url, @required this.category, this.rawDetails});

  factory DeepLink.fromJson(Map<String, dynamic> json) {
    return DeepLink(
        url: json['url'], category: json['category'], rawDetails: json);
  }

  // factory DeepLink.toJson(DeepLink deeplink) {
  //   return {
  //     "url": courseId,
  //     "category": batchId,
  //   };
  // }

  static Map<String, String> toJson(DeepLink deepLink) =>
      {"url": deepLink.url, "category": deepLink.category};
}
