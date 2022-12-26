import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jr_linguist/utils/parsing_helper.dart';

class UserModel {
  String id = "", name = "", image = "", mobile = "", email = "";
  Timestamp? createdTime;
  Map<String, Map<String, List<String>>> completedQuestionsListLanguageAndTypeWise = <String, Map<String, List<String>>>{};

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    image = ParsingHelper.parseStringMethod(map['image']);
    mobile = ParsingHelper.parseStringMethod(map['mobile']);
    email = ParsingHelper.parseStringMethod(map['email']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);

    completedQuestionsListLanguageAndTypeWise.clear();
    Map<String, dynamic> questionScoreLanguageAndTypeWiseMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['completedQuestionsListLanguageAndTypeWise']);
    questionScoreLanguageAndTypeWiseMap.forEach((String language, dynamic value) {
        Map<String, List<String>> scoreMapTypeWise = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(value).map((key, value) {
          return MapEntry(key, ParsingHelper.parseListMethod<dynamic, String>(value).toSet().toList());
        });

        completedQuestionsListLanguageAndTypeWise[language] = scoreMapTypeWise;
    });
  }

  Map<String, dynamic> toMap() {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "mobile" : mobile,
      "email" : email,
      "createdTime" : createdTime,
      "completedQuestionsListLanguageAndTypeWise" : completedQuestionsListLanguageAndTypeWise,
    };
  }

  @override
  String toString() {
    return "id:${id}, name:$name, image:$image, mobile:$mobile, email:$email, createdTime:$createdTime, "
        "completedQuestionsListLanguageAndTypeWise:$completedQuestionsListLanguageAndTypeWise,";
  }
}