import 'package:flutter/material.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/models/question_model.dart';

class QuestionProvider extends ChangeNotifier {
  bool isLoadingQuestions = false;
  List<QuestionModel> audioQuestions = <QuestionModel>[], imageQuestions = <QuestionModel>[];

  String selectedLanguage = LanguagesType.english;
}