class Question {
  final String identifier;
  final String mimeType;
  final String objectType;
  final String primaryCategory;
  final String qType;
  final dynamic editorState;

  const Question({
    this.identifier,
    this.mimeType,
    this.objectType,
    this.primaryCategory,
    this.qType,
    this.editorState,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
        identifier: json['identifier'],
        mimeType: json['mimeType'],
        objectType: json['objectType'],
        primaryCategory: json['primaryCategory'],
        qType: json['qType'],
        editorState: json['editorState']);
  }
}
