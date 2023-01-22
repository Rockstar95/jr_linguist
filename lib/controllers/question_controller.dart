import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/configs/typedefs.dart';
import 'package:jr_linguist/controllers/navigation_controller.dart';
import 'package:jr_linguist/models/question_model.dart';
import 'package:jr_linguist/providers/question_provider.dart';
import 'package:jr_linguist/providers/user_provider.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:jr_linguist/utils/myutils.dart';
import 'package:provider/provider.dart';

import '../utils/parsing_helper.dart';

class QuestionController {
  late QuestionProvider _questionProvider;

  QuestionController({required QuestionProvider? questionProvider}) {
    _questionProvider = questionProvider ?? QuestionProvider();
  }

  QuestionProvider get questionProvider => _questionProvider;

  Future<List<QuestionModel>> getQuestionsFromLanguage({bool isNotify = true}) async {
    QuestionProvider provider = questionProvider;

    MyPrint.printOnConsole("QuestionController().getQuestionsFromLanguage() called with language:'${provider.selectedLanguage}'");

    List<QuestionModel> questions = <QuestionModel>[];

    if(provider.selectedLanguage.isEmpty) {
      return questions;
    }

    provider.isLoadingQuestions = true;
    if(isNotify) provider.notifyListeners();

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.questionsCollectionReference.where("languageType", isEqualTo: provider.selectedLanguage).get();

    questions.addAll(querySnapshot.docs.map((e) {
      return QuestionModel.fromMap(e.data());
    }));

    MyPrint.printOnConsole("Final Questions Length for Language '${provider.selectedLanguage}':${questions.length}");
    provider.audioQuestions = questions.where((element) => element.questionType == QuestionType.audio).toList();
    provider.imageQuestions = questions.where((element) => element.questionType == QuestionType.image).toList();
    provider.isLoadingQuestions = false;
    provider.notifyListeners();

    return questions;
  }

  Future<void> answerQuestion({required String language, required String questionType, required String questionId}) async {
    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainNavigatorKey.currentContext!, listen: false);
    if(userProvider.userid.isNotEmpty) {
      await FirebaseNodes.usersDocumentReference(userId: userProvider.userid).update({
        "completedQuestionsListLanguageAndTypeWise.$language.$questionType" : FieldValue.arrayUnion([questionId]),
      });
    }
  }

  Future<void> resetQuestionTypeForLanguage({required String language, required String questionType}) async {
    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainNavigatorKey.currentContext!, listen: false);
    if(userProvider.userid.isNotEmpty) {
      await FirebaseNodes.usersDocumentReference(userId: userProvider.userid).update({
        "completedQuestionsListLanguageAndTypeWise.$language.$questionType" : [],
      });
    }
  }

  //region Posters
  Future<Map<String, String>> getLanguagewisePostersData({bool isNotify = true}) async {
    MyPrint.printOnConsole("QuestionController().getLanguagewisePostersData() called");

    QuestionProvider provider = questionProvider;

    Map<String, String> data = <String, String>{};

    provider.isLoadingPosters = true;
    if(isNotify) provider.notifyListeners();

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.languagewisePostersDocumentReference().get();
      MyPrint.printOnConsole("snapshot data:${snapshot.data()}");

      if(snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
        snapshot.data()!.forEach((String language, dynamic urlDynamic) {
          String url = ParsingHelper.parseStringMethod(urlDynamic);
          if(url.isNotEmpty) {
            data[language] = url;
          }
        });
      }
      MyPrint.printOnConsole("Final Posters Data:$data");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in QuestionController().getLanguagewisePostersData():$e");
      MyPrint.printOnConsole(s);
    }

    provider.posters = data;

    provider.isLoadingPosters = false;
    provider.notifyListeners();

    return data;
  }
  //endregion

  Future<void> addDummyQuestion() async {
    /*QuestionModel questionModel = QuestionModel(
      id: MyUtils.getUniqueId(),
      question: "Recognize the Text",
      questionType: QuestionType.image,
      languageType: LanguagesType.english,
      questionResourceUrl: "https://img.freepik.com/premium-vector/speech-bubble-with-text-hi-hello-design-template-white-bubble-message-hi-yellow-background_578506-193.jpg?w=2000",
      answersMap: {
        "Hello" : true,
        "Hiii" : false,
        "My" : false,
        "Ram" : false,
      },
    );*/

    QuestionModel questionModel = QuestionModel(
      id: MyUtils.getUniqueId(),
      question: "Recognize the Text",
      questionType: QuestionType.audio,
      languageType: LanguagesType.hindi,
      questionResourceUrl: "क्षमा",
      answersMap: {
        "क्षमा" : true,
        "Hello" : false,
        "Hiii" : false,
        "Nice To Meet You" : false,
      },
    );
    MyPrint.printOnConsole("questionModel:$questionModel");

    await FirebaseNodes.questionsDocumentReference(questionId: questionModel.id).set(questionModel.toMap());
    MyPrint.printOnConsole("Dummy Question Created");
  }
}