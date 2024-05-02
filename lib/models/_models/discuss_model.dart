import 'package:equatable/equatable.dart';

class Discuss extends Equatable {
  final Map user;
  final dynamic timeStamp;
  final String title;
  final Map category;
  final int upVotes;
  final int downVotes;
  final int tid;
  final List tags;
  final int topicCount;
  final int nextStart;
  final int cid;
  final int postCount;
  final int viewCount;

  const Discuss(
      {this.user,
      this.timeStamp,
      this.title,
      this.category,
      this.upVotes,
      this.downVotes,
      this.tid,
      this.tags,
      this.topicCount,
      this.nextStart,
      this.cid,
      this.postCount,
      this.viewCount});

  factory Discuss.fromJson(Map<String, dynamic> json,
      {int topicCount, int nextStart}) {
    return Discuss(
        user: json['user'],
        timeStamp: json['timestamp'],
        title: json['titleRaw'] != null
            ? json['titleRaw']
            : json['topic'] != null
                ? json['topic']['titleRaw']
                : '',
        category: json['category'],
        upVotes: json['upvotes'],
        downVotes: json['downvotes'],
        tid: json['tid'],
        tags: json['tags'],
        topicCount: topicCount != null ? topicCount : json['topicCount'],
        nextStart: nextStart != null ? nextStart : json['nextStart'],
        cid: json['cid'],
        postCount: json['postcount'] != null
            ? json['postcount']
            : json['topic'] != null
                ? json['topic']['postcount'] != null
                    ? json['topic']['postcount']
                    : 0
                : 0,
        viewCount: json['viewcount']);
  }

  @override
  List<Object> get props => [
        user,
        timeStamp,
        title,
        category,
        upVotes,
        downVotes,
        tid,
        tags,
        topicCount,
        nextStart,
        cid,
        postCount,
        viewCount
      ];
}
