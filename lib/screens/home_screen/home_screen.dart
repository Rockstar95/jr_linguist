import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jr_linguist/controllers/question_controller.dart';
import 'package:jr_linguist/models/poster_model.dart';
import 'package:jr_linguist/models/question_model.dart';
import 'package:jr_linguist/models/user_model.dart';
import 'package:jr_linguist/providers/question_provider.dart';
import 'package:jr_linguist/providers/user_provider.dart';
import 'package:jr_linguist/screens/test/test_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../utils/my_print.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';
import '../common/components/language_selection_dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      title: "Home",
      color: Colors.white,
      backbtnVisible: false,
      rightrow: Row(
        children: [
          LanguageSelectionDropdownWidget(
            selectedLanguage: questionProvider.selectedLanguage,
            onLanguageSelected: (String newLanguage) {
              questionProvider.selectedLanguage = newLanguage;
              questionController.getQuestionsFromLanguage();
              questionController.getLanguagewisePostersData();
            },
          ),
        ],
      ),
    );
  }

  Widget getMainBody({UserModel? userModel, required QuestionProvider questionProvider}) {
    if(questionProvider.isLoadingPosters) {
      return const Center(
        child: SpinKitFadingCircle(
          color: Styles.primaryColor,
        ),
      );
    }

    List<PosterModel> posters = questionProvider.posters;

    if(posters.isEmpty) {
      return const Center(
        child: Text("No Poster Available"),
      );
    }

    return ListView.builder(
      itemCount: posters.length,
      itemBuilder: (BuildContext context, int index) {
        PosterModel posterModel = posters[index];

        return CachedNetworkImage(
          imageUrl: posterModel.posterUrl,
          placeholder: (_, __) => const SizedBox(
            height: 200,
            child: Center(
              child: SpinKitFadingCircle(color: Styles.primaryColor,),
            ),
          ),
        );
      },
    );
  }
}
