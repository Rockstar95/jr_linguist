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

class QuestionController {
  Future<List<QuestionModel>> getQuestionsFromLanguage({bool isNotify = true}) async {
    QuestionProvider questionProvider = Provider.of<QuestionProvider>(NavigationController.mainNavigatorKey.currentContext!, listen: false);

    MyPrint.printOnConsole("QuestionController().getQuestionsFromLanguage() called with language:'${questionProvider.selectedLanguage}'");

    List<QuestionModel> questions = <QuestionModel>[];

    if(questionProvider.selectedLanguage.isEmpty) {
      return questions;
    }

    questionProvider.isLoadingQuestions = true;
    if(isNotify) questionProvider.notifyListeners();

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.questionsCollectionReference.where("languageType", isEqualTo: questionProvider.selectedLanguage).get();

    questions.addAll(querySnapshot.docs.map((e) {
      return QuestionModel.fromMap(e.data());
    }));

    MyPrint.printOnConsole("Final Questions Length for Language '${questionProvider.selectedLanguage}':${questions.length}");
    questionProvider.audioQuestions = questions.where((element) => element.questionType == QuestionType.audio).toList();
    questionProvider.imageQuestions = questions.where((element) => element.questionType == QuestionType.image).toList();
    questionProvider.isLoadingQuestions = false;
    questionProvider.notifyListeners();

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