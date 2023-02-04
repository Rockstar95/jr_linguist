import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/configs/typedefs.dart';
import 'package:jr_linguist/controllers/navigation_controller.dart';
import 'package:jr_linguist/models/poster_model.dart';
import 'package:jr_linguist/models/question_model.dart';
import 'package:jr_linguist/providers/question_provider.dart';
import 'package:jr_linguist/providers/user_provider.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:jr_linguist/utils/myutils.dart';
import 'package:provider/provider.dart';

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
  Future<List<PosterModel>> getLanguagewisePostersData({bool isNotify = true}) async {
    MyPrint.printOnConsole("QuestionController().getLanguagewisePostersData() called");

    QuestionProvider provider = questionProvider;

    provider.isLoadingPosters = true;
    if(isNotify) provider.notifyListeners();
    
    List<PosterModel> posters = <PosterModel>[];

    try {
      Query<Map<String, dynamic>> query = FirebaseNodes.postersCollectionReference
          .where("languageType", isEqualTo: provider.selectedLanguage)
          .orderBy("priority", descending: false);
      MyPrint.printOnConsole("query:${query.parameters}");

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Query snapshot data length:${querySnapshot.docs.length}");

      posters.addAll(querySnapshot.docs.map((e) {
        return PosterModel.fromMap(e.data());
      }));
      
      MyPrint.printOnConsole("Final Posters Length for Language '${provider.selectedLanguage}':${posters.length}");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in QuestionController().getLanguagewisePostersData():$e");
      MyPrint.printOnConsole(s);
    }

    provider.posters = posters;

    provider.isLoadingPosters = false;
    provider.notifyListeners();

    return provider.posters;
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