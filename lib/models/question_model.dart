import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jr_linguist/utils/parsing_helper.dart';

class QuestionModel {
  String id = "", question = "", questionType = "", languageType = "", questionResourceUrl = "";
  Map<String, bool> answers = <String, bool>{};
  Timestamp? createdTime;

  QuestionModel({
    this.id = "",
    this.question = "",
    this.questionType = "",
    this.languageType = "",
    this.questionResourceUrl = "",
    Map<String, bool>? answersMap,
    this.createdTime,
  }) {
    answers = answersMap ?? <String, bool>{};
  }

  QuestionModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    question = ParsingHelper.parseStringMethod(map['question']);
    questionType = ParsingHelper.parseStringMethod(map['questionType']);
    languageType = ParsingHelper.parseStringMethod(map['languageType']);
    questionResourceUrl = ParsingHelper.parseStringMethod(map['questionResourceUrl']);
    answers = ParsingHelper.parseMapMethod<dynamic, dynamic, String, bool>(map['answers']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool isJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "question" : question,
      "questionType" : questionType,
      "languageType" : languageType,
      "questionResourceUrl" : questionResourceUrl,
      "answers" : answers,
      "createdTime" : isJson ? createdTime?.toDate().toIso8601String() : createdTime,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap(isJson: true));
  }
}