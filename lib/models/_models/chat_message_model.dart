import 'package:flutter/material.dart';

class ChatMessageModel {
  final String title;
  final String response;
  final bool isUser;
  final DateTime timestamp;
  List suggestions;
  dynamic categoryList;
  final bool isBottomSuggestions;

  ChatMessageModel(
      {@required this.title,
      this.response,
      @required this.isUser,
      @required this.timestamp,
      this.suggestions,
      this.categoryList,
      this.isBottomSuggestions});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
        title: json['title'],
        response: json['response'],
        isUser: json['isUser'],
        timestamp: json['timestamp'],
        suggestions: json['suggestions'],
        categoryList: json['categoryList'],
        isBottomSuggestions: json['isBottomSuggestions']);
  }
}
