
class LeaderboardModel {
  final String profileImage;
  final String month;
  final String year;
  final String orgId;
  final int totalPoints;
  final int rank;
  final int previousRank;
  final String fullname;
  final int rowNum;
  final String userId;

  LeaderboardModel({
    this.profileImage,
    this.month,
    this.year,
    this.orgId,
    this.totalPoints,
    this.rank,
    this.previousRank,
    this.fullname,
    this.rowNum,
    this.userId,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      profileImage: json['profile_image'],
      month: json['month'],
      year: json['year'],
      orgId: json['org_id'],
      totalPoints: json['total_points'],
      rank: json['rank'] ?? 0,
      previousRank: json['previous_rank'] ?? 0,
      fullname: json['fullname'],
      rowNum: json['row_num'],
      userId: json['userId'],
    );
  }
}