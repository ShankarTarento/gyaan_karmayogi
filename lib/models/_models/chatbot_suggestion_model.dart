class ChatbotSuggestionModel {
  final String catId;
  final String categoryType;
  final int priority;
  final List recommendedQues;

  ChatbotSuggestionModel(
      {this.catId, this.categoryType, this.priority, this.recommendedQues});

  factory ChatbotSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ChatbotSuggestionModel(
        catId: json['catId'],
        categoryType: json['categoryType'],
        priority: json['priority'],
        recommendedQues: json['recommendedQues']);
  }
}
