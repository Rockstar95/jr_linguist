import 'dart:convert';

import 'package:jr_linguist/utils/parsing_helper.dart';

class QuestionModel {
  String id = "", question = "", questionType = "", languageType = "", questionResourceUrl = "";
  Map<String, bool> answers = <String, bool>{};

  QuestionModel({
    this.id = "",
    this.question = "",
    this.questionType = "",
    this.languageType = "",
    this.questionResourceUrl = "",
    Map<String, bool>? answersMap,
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
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id" : id,
      "question" : question,
      "questionType" : questionType,
      "languageType" : languageType,
      "questionResourceUrl" : questionResourceUrl,
      "answers" : answers,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}