import 'dart:convert';

class Event {
  final String identifier;
  final String name;
  final String description;
  final String eventIcon;
  final String source;
  final dynamic creatorDetails;
  final dynamic startDate;
  final dynamic startTime;
  final dynamic endTime;
  final String status;
  final String instructions;
  final List<dynamic> createdFor;
  final String objectType;
  final String eventType;
  final dynamic raw;

  Event(
      {this.identifier,
      this.name,
      this.description,
      this.eventIcon,
      this.source,
      this.creatorDetails,
      this.startDate,
      this.startTime,
      this.endTime,
      this.status,
      this.instructions,
      this.createdFor,
      this.objectType,
      this.eventType,
      this.raw});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        identifier: json['identifier'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        eventIcon: json['appIcon'] as String,
        source: json['sourceName'] as String,
        creatorDetails: json['creatorDetails'] != null
            ? jsonDecode(json['creatorDetails'])
            : [],
        startDate: json['startDate'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        status: json['status'],
        instructions: json['instructions'],
        createdFor: json['createdFor'] != null ? json['createdFor'] : [],
        objectType: json['objectType'],
        eventType: json['resourceType'] != null ? json['resourceType'] : '',
        raw: json);
  }
}
