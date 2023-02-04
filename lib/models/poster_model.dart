import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/parsing_helper.dart';

class PosterModel {
  String id = "", posterUrl = "", languageType = "";
  int priority = 0;
  Timestamp? createdTime;

  PosterModel({
    this.id = "",
    this.posterUrl = "",
    this.languageType = "",
    this.priority = 0,
    this.createdTime,
  });

  PosterModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    posterUrl = ParsingHelper.parseStringMethod(map['posterUrl']);
    languageType = ParsingHelper.parseStringMethod(map['languageType']);
    priority = ParsingHelper.parseIntMethod(map['priority']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool isJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "posterUrl" : posterUrl,
      "languageType" : languageType,
      "priority" : priority,
      "createdTime" : isJson ? createdTime?.toDate().toIso8601String() : createdTime,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap(isJson: true));
  }
}