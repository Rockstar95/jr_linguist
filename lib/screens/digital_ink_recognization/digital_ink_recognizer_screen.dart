import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:jr_linguist/utils/snakbar.dart';
import 'package:provider/provider.dart';

import '../../controllers/question_controller.dart';
import '../../providers/question_provider.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';

class DigitalInkRecognizerScreen extends StatefulWidget {
  const DigitalInkRecognizerScreen({super.key});

  @override
  State<DigitalInkRecognizerScreen> createState() => _DigitalInkRecognizerScreenState();
}

class _DigitalInkRecognizerScreenState extends State<DigitalInkRecognizerScreen> {
  late ThemeData themeData;

  late QuestionProvider questionProvider;
  late QuestionController questionController;

  final DigitalInkRecognizerModelManager _modelManager = DigitalInkRecognizerModelManager();
  final String _language = 'en-US';
  late final DigitalInkRecognizer _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = '';
    });
  }

  Future<void> _isModelDownloaded() async {
    Snakbar.showInfoSnakbar(context: context, msg: "Checking if model is downloaded...");

    bool isDownloaded = await _modelManager.isModelDownloaded(_language);

    if(context.mounted) {
      if(isDownloaded) {
        Snakbar.showSuccessSnakbar(context: context, msg: "downloaded");
      }
      else {
        Snakbar.showErrorSnakbar(context: context, msg: "not downloaded");
      }
    }
  }

  Future<void> _deleteModel() async {
    Snakbar.showInfoSnakbar(context: context, msg: "Deleting model...");

    bool isDownloaded = await _modelManager.deleteModel(_language);

    if(context.mounted) {
      if(isDownloaded) {
        Snakbar.showSuccessSnakbar(context: context, msg: "success");
      }
      else {
        Snakbar.showErrorSnakbar(context: context, msg: "failed");
      }
    }
  }

  Future<void> _downloadModel() async {
    Snakbar.showInfoSnakbar(context: context, msg: "Downloading model...");

    bool isDownloaded = await _modelManager.downloadModel(_language);

    if(context.mounted) {
      if(isDownloaded) {
        Snakbar.showSuccessSnakbar(context: context, msg: "success");
      }
      else {
        Snakbar.showErrorSnakbar(context: context, msg: "failed");
      }
    }
  }

  Future<void> _recogniseText() async {
    showDialog(
        context: context,
        builder: (context) => const AlertDialog(
              title: Text('Recognizing'),
            ),
        barrierDismissible: true,
    );

    MyPrint.printOnConsole("checking with language:$_language");

    bool isDownloaded = await _modelManager.isModelDownloaded(_language);

    if(!isDownloaded) {
      Navigator.pop(context);
      if(context.mounted) {
        Snakbar.showErrorSnakbar(context: context, msg: "not downloaded");
      }
      return;
    }

    try {
      final candidates = await _digitalInkRecognizer.recognize(_ink);
      _recognizedText = '';
      for (final candidate in candidates) {
        _recognizedText += '\n${candidate.text}';
      }
      setState(() {});
      Navigator.pop(context);
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Recognizing Text:$e");
      MyPrint.printOnConsole(s);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  String getLanguageFromLanguageName({required String languageName}) {
    if(languageName == LanguagesType.gujarati) {
      return "gu";
    }
    else if(languageName == LanguagesType.hindi) {
      return "hi-Latn";
    }
    else if(languageName == LanguagesType.kannad) {
      return "kn";
    }
    else if(languageName == LanguagesType.marathi) {
      return "mr";
    }
    else if(languageName == LanguagesType.sanskrit) {
      return "hi";
    }
    else {
      return "gu";
    }
  }

  @override
  void initState() {
    super.initState();
    questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionController = QuestionController(questionProvider: questionProvider);
  }

  @override
  void dispose() {
    _digitalInkRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Styles.background,
      body: Column(
        children: [
          getAppBar(questionProvider: questionProvider),
          Expanded(
            child: getMainBody(questionProvider: questionProvider),
          ),
        ],
      ),
    );
  }

  Widget getAppBar({required QuestionProvider questionProvider}) {
    return MyAppBar(
      title: "Notepad",
      color: Colors.white,
      backbtnVisible: false,
      /*rightrow: Row(
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
      ),*/
    );
  }

  Widget getMainBody({required QuestionProvider questionProvider}) {
    return Column(
      children: [
        /*Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Language Code: $_language',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 10,),*/
        Expanded(
          child: GestureDetector(
            onPanStart: (DragStartDetails details) {
              _ink.strokes.add(Stroke());
            },
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                final RenderObject? object = context.findRenderObject();
                final localPosition = (object as RenderBox?)
                    ?.globalToLocal(details.localPosition);
                if (localPosition != null) {
                  _points = List.from(_points)
                    ..add(StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ));
                }
                if (_ink.strokes.isNotEmpty) {
                  _ink.strokes.last.points = _points.toList();
                }
              });
            },
            onPanEnd: (DragEndDetails details) {
              _points.clear();
              setState(() {});
            },
            child: CustomPaint(
              painter: Signature(ink: _ink),
              size: Size.infinite,
            ),
          ),
        ),
        if (_recognizedText.isNotEmpty)
          Text(
            'Recognized Text: $_recognizedText',
            style: const TextStyle(fontSize: 23),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _recogniseText,
                child: const Text('Read Text'),
              ),
              ElevatedButton(
                onPressed: _clearPad,
                child: const Text('Clear Pad'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isModelDownloaded,
                child: const Text('Check Model'),
              ),
              ElevatedButton(
                onPressed: _downloadModel,
                child: const Text('Download'),
              ),
              ElevatedButton(
                onPressed: _deleteModel,
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class Signature extends CustomPainter {
  Ink ink;

  Signature({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(Offset(p1.x.toDouble(), p1.y.toDouble()),
            Offset(p2.x.toDouble(), p2.y.toDouble()), paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}
