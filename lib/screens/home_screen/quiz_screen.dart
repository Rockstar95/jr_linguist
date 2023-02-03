import 'package:flutter/material.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/controllers/question_controller.dart';
import 'package:jr_linguist/models/question_model.dart';
import 'package:jr_linguist/models/user_model.dart';
import 'package:jr_linguist/providers/question_provider.dart';
import 'package:jr_linguist/providers/user_provider.dart';
import 'package:jr_linguist/screens/test/test_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/my_print.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';
import '../common/components/language_selection_dropdown.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late ThemeData themeData;

  late QuestionProvider questionProvider;
  late QuestionController questionController;

  Future<void> resetQuestion({required String languageType, required String questionType}) async {
    /*questionController.addDummyQuestion();
    return;*/

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    questionController.resetQuestionTypeForLanguage(
      language: languageType,
      questionType: questionType,
    );
    userProvider.userModel?.completedQuestionsListLanguageAndTypeWise[languageType]?[questionType]?.clear();
    MyPrint.printOnConsole("UserModel after Updating CompletedQuestionsListLanguageAndTypeWise:${userProvider.userModel}");
    setState(() {});
  }

  Future<void> startTest({required String languageType, required String questionType, required List<QuestionModel> questions}) async {
    /*questionController.addDummyQuestion();
    return;*/

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    await Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
      questionType: questionType,
      languageType: languageType,
      questions: questions,
    )));

    // setState(() {});

    String userId = userProvider.userid;
    MyPrint.printOnConsole("userId:$userId");
    if(userId.isNotEmpty) {
      await UserController().isUserExist(context, userId);
      setState(() {});
    }
  }

  Future<void> completeTest({required String languageType, required String questionType, required List<QuestionModel> questions}) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    List<String> completedQuestionIds = userProvider.userModel?.completedQuestionsListLanguageAndTypeWise[languageType]?[questionType] ?? <String>[];
    List<QuestionModel> finalQuestions = List.from(questions)..removeWhere((element) => completedQuestionIds.contains(element.id));

    startTest(languageType: languageType, questionType: questionType, questions: finalQuestions);
  }

  Future<void> reTest({required String languageType, required String questionType, required List<QuestionModel> questions}) async {
    resetQuestion(languageType: languageType, questionType: questionType);
    startTest(languageType: languageType, questionType: questionType, questions: questions);
  }

  @override
  void initState() {
    super.initState();

    questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionController = QuestionController(questionProvider: questionProvider);

    questionController.getQuestionsFromLanguage(isNotify: false);
    questionController.getLanguagewisePostersData(isNotify: false);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Consumer2<QuestionProvider, UserProvider>(
      builder: (BuildContext context, QuestionProvider questionProvider, UserProvider userProvider, Widget? child) {
        return Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              getAppBar(questionProvider: questionProvider),
              Expanded(
                child: getMainBody(userModel: userProvider.userModel, questionProvider: questionProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getAppBar({required QuestionProvider questionProvider}) {
    return MyAppBar(
      title: "Quiz",
      color: Colors.white,
      backbtnVisible: false,
      rightrow: Row(
        children: [
          LanguageSelectionDropdownWidget(
            selectedLanguage: questionProvider.selectedLanguage,
            onLanguageSelected: (String newLanguage) {
              questionProvider.selectedLanguage = newLanguage;
              questionController.getQuestionsFromLanguage();
              questionController.getLanguagewisePostersData(isNotify: true);
            },
          ),
        ],
      ),
    );
  }

  Widget getMainBody({UserModel? userModel, required QuestionProvider questionProvider}) {
    List<QuestionModel> audioQuestions = questionProvider.audioQuestions;
    List<QuestionModel> imageQuestions = questionProvider.imageQuestions;

    List<String> audioQuestionIds = audioQuestions.map((e) => e.id).toList();
    List<String> imageQuestionIds = imageQuestions.map((e) => e.id).toList();

    List<String> completedAudioQuestionsList = userModel?.completedQuestionsListLanguageAndTypeWise[questionProvider.selectedLanguage]?[QuestionType.audio] ?? <String>[];
    completedAudioQuestionsList.removeWhere((element) => !audioQuestionIds.contains(element));

    List<String> completedImageQuestionsList = userModel?.completedQuestionsListLanguageAndTypeWise[questionProvider.selectedLanguage]?[QuestionType.image] ?? <String>[];
    completedImageQuestionsList.removeWhere((element) => !imageQuestionIds.contains(element));

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: getScoreWidget(
                    text: "${QuestionType.audio} Score",
                    score: completedAudioQuestionsList.length,
                    languageType: questionProvider.selectedLanguage,
                    questionType: QuestionType.audio,
                    questions: audioQuestions,
                    userId: userModel?.id ?? "",
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: getScoreWidget(
                    text: "${QuestionType.image} Score",
                    score: completedImageQuestionsList.length,
                    languageType: questionProvider.selectedLanguage,
                    questionType: QuestionType.image,
                    questions: imageQuestions,
                    userId: userModel?.id ?? "",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getScoreWidget({required String text, required int score, required String languageType, required String questionType, required List<QuestionModel> questions, required String userId}) {
    int questionsLength = questions.length;

    bool isReset = questions.isNotEmpty && score > 0;
    bool isRetest = questions.isNotEmpty && score > 0;
    bool isCompleteTest = questions.isNotEmpty && score > 0 && score < questions.length;
    bool isStartTest = questions.isNotEmpty && score == 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.colorScheme.onPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: themeData.primaryColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                ),
                Text(
                  "Score: $score/$questionsLength",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10,),
        if(isReset) ElevatedButton(
          onPressed: () async {
            resetQuestion(
              languageType: languageType,
              questionType: questionType,
            );
          },
          child: const Text("Reset"),
        ),
        if(isRetest) ElevatedButton(
          onPressed: () async {
            reTest(
              languageType: languageType,
              questionType: questionType,
              questions: questions,
            );
          },
          child: const Text("Retest"),
        ),
        if(isCompleteTest) ElevatedButton(
          onPressed: () async {
            completeTest(
              languageType: languageType,
              questionType: questionType,
              questions: questions,
            );
          },
          child: const Text("Complete Test"),
        ),
        if(isStartTest) ElevatedButton(
          onPressed: () async {
            startTest(
              languageType: languageType,
              questionType: questionType,
              questions: questions,
            );
          },
          child: const Text("Start"),
        ),
      ],
    );
  }
}
