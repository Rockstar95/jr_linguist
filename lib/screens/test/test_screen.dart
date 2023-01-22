import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/controllers/question_controller.dart';
import 'package:jr_linguist/models/question_model.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:jr_linguist/utils/snakbar.dart';

import '../../utils/styles.dart';
import '../common/components/app_bar.dart';

class TestScreen extends StatefulWidget {
  final String languageType, questionType;
  final List<QuestionModel> questions;

  const TestScreen({
    Key? key,
    required this.languageType,
    required this.questionType,
    required this.questions,
  }) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late ThemeData themeData;

  int score = 0;

  PageController pageController = PageController(initialPage: 0,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: SafeArea(
        child: Column(
          children: [
            getAppBar(),
            Expanded(
              child: Center(child: getQuestionsList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBar() {
    return MyAppBar(
      title: "Test",
      color: Colors.white,
      backbtnVisible: false,
      rightrow: Row(
        children: [
          Text("$score/${widget.questions.length}"),
        ],
      ),
    );
  }

  Widget getQuestionsList() {
    if(widget.questions.isEmpty) {
      return const Center(
        child: Text("No Questions"),
      );
    }


    return PageView.builder(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      pageSnapping: true,
      // scrollDirection: A,
      itemCount: widget.questions.length,
      itemBuilder: (BuildContext context, int index) {
        QuestionModel questionModel = widget.questions[index];

        return QuestionWidget(
          questionModel: questionModel,
          onRightAnswer: () {
            score++;
            // UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
            QuestionController(questionProvider: null).answerQuestion(
              language: questionModel.languageType,
              questionType: questionModel.questionType,
              questionId: questionModel.id,
            );
            /*userProvider.userModel?.completedQuestionsListLanguageAndTypeWise[questionModel.languageType]?[questionModel.questionType]?.add(questionModel.id);
            MyPrint.printOnConsole("UserModel after Updating CompletedQuestionsListLanguageAndTypeWise:${userProvider.userModel}");
            setState(() {});*/
          },
          onGivedAnswer: () async {
            MyPrint.printOnConsole("pageController.page Before:${pageController.page}");
            if(pageController.page != null) {
              if(pageController.page! == widget.questions.length - 1) {
                Navigator.pop(context);
              }
              else {
                await pageController.nextPage(duration: const Duration(milliseconds: 10), curve: Curves.bounceIn);
                MyPrint.printOnConsole("pageController.page After:${pageController.page}");
              }
            }
          },
        );
      },
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final QuestionModel questionModel;
  final void Function()? onRightAnswer, onGivedAnswer;

  const QuestionWidget({Key? key, required this.questionModel, this.onRightAnswer, this.onGivedAnswer}) : super(key: key);

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late ThemeData themeData;

  List<String> answers = <String>[];

  String? answerValue;

  @override
  void initState() {
    super.initState();
    answers = (widget.questionModel.answers.keys.toList())..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          children: [
            Text(
              widget.questionModel.question,
              style: themeData.textTheme.headline6?.copyWith(

              ),
            ),
            const SizedBox(height: 10,),
            getQuestionResourceWidget(questionModel: widget.questionModel),
            const SizedBox(height: 10,),
            getAnswersWidget(answers: answers),
            const SizedBox(height: 10,),
            submitAnswerButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget getQuestionResourceWidget({required QuestionModel questionModel}) {
    if(questionModel.questionType == QuestionType.image) {
      return Flexible(
        child: CachedNetworkImage(
          imageUrl: questionModel.questionResourceUrl,
          placeholder: (_, __) => const SpinKitFadingCircle(color: Styles.primaryColor,),
        ),
      );
    }
    else {
      return ElevatedButton(
        onPressed: () async {
          if(questionModel.questionResourceUrl.isNotEmpty) {
            FlutterTts flutterTts = FlutterTts();
            await flutterTts.speak(questionModel.questionResourceUrl);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.volume_up),
            SizedBox(),
            Text("Play Audio"),
          ],
        ),
      );
    }
  }

  Widget getAnswersWidget({required List<String> answers}) {
    MyPrint.printOnConsole("getAnswersWidget called with answers:$answers");
    return Column(
      children: answers.map((e) {
        return RadioListTile<String>(
          value: e,
          groupValue: answerValue,
          onChanged: (String? value) {
            answerValue = value;
            setState(() {});
          },
          title: Text(e),
        );
      }).toList(),
    );
  }

  Widget submitAnswerButtonWidget() {
    return ElevatedButton(
      onPressed: answerValue != null ? () {
        if(widget.questionModel.answers[answerValue] == true) {
          Snakbar.showSuccessSnakbar(context: context, msg: "Right Answer");

          if(widget.onRightAnswer != null) {
            widget.onRightAnswer!();
          }
        }
        else {
          Snakbar.showErrorSnakbar(context: context, msg: "Wrong Answer");
        }
        if(widget.onGivedAnswer != null) {
          widget.onGivedAnswer!();
        }
        // QuestionController().answerQuestion(context: context, questionModel: widget.questionModel, answer: answerValue!);
      } : null,
      child: const Text("Submit"),
    );
  }
}
