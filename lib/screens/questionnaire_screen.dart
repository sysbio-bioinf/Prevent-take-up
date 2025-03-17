import 'dart:convert';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:questionnaires/widgets/slider_dialog.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:questionnaires/configs/app_colors.dart';
import 'package:questionnaires/models/answer.dart';
import 'package:questionnaires/widgets/image_question.dart';
import 'package:questionnaires/models/interpretation.dart';
import 'package:questionnaires/models/question.dart';
import 'package:questionnaires/models/questionnaire.dart';
import 'package:questionnaires/models/questionType.dart';
import 'package:questionnaires/screens/result_screen.dart';
import 'package:questionnaires/services/rest_service.dart';
import 'package:questionnaires/widgets/button.dart';
import 'package:questionnaires/widgets/radio_group.dart';
import 'package:questionnaires/enums/stack.dart' as stack;
import 'package:questionnaires/widgets/info_button.dart';
import 'package:http/http.dart' as http;
import 'package:group_button/group_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_group_button/src/group_items_alignment.dart';
//import 'package:flutter_group_button/src/radio_group.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Questionnaire questionnaire;

  QuestionnaireScreen({required this.questionnaire});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  //Formkeys to access forms
  Map<String, TextEditingController> controllers =
      Map<String, TextEditingController>();
  Map<String, bool> valid = new Map<String, bool>();
  List<String> get identifiers => widget.questionnaire.questionIDs;
  List<Question> get questions => widget.questionnaire.questions;
  int questionIndex = 0;
  stack.Stack<int> prevQuestionIndex = stack.Stack<int>();
  Question get currentQuestion => questions[questionIndex];
  int get numberOfQuestions => questions.length;
  Map<String, List<int>> answerIdc =
      new Map<String, List<int>>(); //nested list for answer indices selected
  Map<String, List<int>> answerSet = new Map<String, List<int>>();
  List<int> interpretations =
      List<int>.empty(growable: true); //list of recommended answers
  bool get userHasAnsweredCurrentQuestion =>
      answerIdc[identifiers[questionIndex]]!.isNotEmpty &&
      answerIdc[identifiers[questionIndex]]![0] != -1 &&
      valid[identifiers[questionIndex]]!;
  String get instructions => widget.questionnaire.instructions;

  late QuestImage currImage;

  List<String> sendResultToServer() {
    Future<http.Response> res = sendPostRequest(
      widget.questionnaire.answersToJson(answerIdc),
    );

    var body = "";
    res.then(
        (value) => print((value.statusCode.toString() + ": " + value.body)),
        onError: (e) => print(e));

    return <String>[
      'Vielen Dank für Ihre Teilahme. Das Ergebnis wurde erfolgreich abgeschickt.'
    ];
    // if something went wrong, return the worst interpretation
  }

  List<String> evaluateResult() {
    List<Interpretation> interpretations = widget.questionnaire.interpretations;
    //print("DEBUG : in eval" + this.interpretations.toString());

    List<String> res = [];

    List<int> uniq = List<int>.empty(growable: true);

    for (int score in this.interpretations) {
      if (!uniq.contains(score)) uniq.add(score);
    }

    for (int score in uniq) {
      if (score < 100) {
        for (Interpretation interpretation in interpretations) {
          if (score == interpretation.score) {
            res.add(interpretation.text);
            break;
          }
        }
      }
    }

    //walk over given answers and check which recommendations to give:
    return res;
    // if something went wrong, return the worst interpretation
  }

  List<String> evaluateRisks() {
    List<Interpretation> interpretations = widget.questionnaire.interpretations;
    //print("DEBUG : in eval" + this.interpretations.toString());

    List<String> res = [];

    for (int score in this.interpretations) {
      if (score > 100) {
        for (Interpretation interpretation in interpretations) {
          if (score == interpretation.score) {
            res.add(interpretation.text);
            break;
          }
        }
      }
    }
    //walk over given answers and check which recommendations to give:
    return res;
    // if something went wrong, return the worst interpretation
  }

  @override
  void initState() {
    super.initState();

    questionIndex = 0;
    answerIdc = new Map<String, List<int>>();
    answerSet = new Map<String, List<int>>();
    valid = new Map<String, bool>();
    controllers = Map<String, TextEditingController>();
    interpretations = List<int>.empty(growable: true);
    widget.questionnaire.questionIDs.forEach((questID) {
      //init idcs with dummy index -1
      answerIdc[questID] = List<int>.filled(1, -1, growable: true);
      answerSet[questID] = List<int>.filled(1, -1, growable: true);
      //init form controllers if required
      controllers[questID] = TextEditingController();

      if (questions[identifiers.indexOf(questID)].answers[0].minValue != null ||
          questions[identifiers.indexOf(questID)].answers[0].maxValue != null) {
        valid[questID] = false;
        controllers[questID]!.addListener(() {
          if (controllers[questID]!.text == null ||
              controllers[questID]!.text.isEmpty) return;

          String? input = controllers[questID]!.text.replaceAll(r',', '.');
          if (input == null) return;

          double? numInput = double.tryParse(input)!;
          print(numInput);
          setState(() {
            valid[questID] = input.isNotEmpty &&
                (numInput != null) &&
                (numInput >=
                    questions[identifiers.indexOf(questID)]
                        .answers[0]
                        .minValue!) &&
                (numInput <=
                    questions[identifiers.indexOf(questID)]
                        .answers[0]
                        .maxValue!);
          });
        });
      } else
        valid[questID] = true;
    });
    prevQuestionIndex = stack.Stack<int>();
  }

  @override
  Widget build(BuildContext context) {
    GroupButtonController _radioController = GroupButtonController(
      selectedIndex: !userHasAnsweredCurrentQuestion
          ? null
          : answerIdc[identifiers[questionIndex]]![0],
      onDisablePressed: (i) => debugPrint('Disable Button #$i pressed'),
    );
    return ScalingWrapper(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0),
              child: AutoSizeText(
                instructions,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor,
                ),
                maxLines: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: //ConstrainedBox(
                  //constraints: BoxConstraints.expand(height: 500),
                  Container(
                      child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Center(
                        child: FittedBox(
                      fit: BoxFit.fill,
                      child: DotsIndicator(
                        dotsCount: numberOfQuestions,
                        position: questionIndex.toDouble(),
                        decorator: DotsDecorator(
                          size: Size.square(15),
                          activeSize: Size(18, 18),
                          activeColor: Theme.of(context).primaryColor,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    )),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 8.0),
                      child: AutoSizeText(
                        currentQuestion.text,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.left,
                        maxLines: 4,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.SingleChoice),
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: new RadioGroup(
                                children: currentQuestion.answers
                                    .map((answer) => AutoSizeText(
                                          answer.text,
                                          maxLines: 3,
                                          minFontSize: 18,
                                        ))
                                    .toList(),
                                activeColor: Theme.of(context).primaryColor,
                                priority: RadioPriority.textBeforeRadio,
                                textBeforeRadio: false,
                                groupItemsAlignment: GroupItemsAlignment.column,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                internMainAxisAlignment: MainAxisAlignment
                                    .start,
                                defaultSelectedItem:
                                    !userHasAnsweredCurrentQuestion
                                        ? -1
                                        : answerIdc[
                                            identifiers[questionIndex]]![0],
                                onSelectionChanged: (index) {
                                  if (index != null) {
                                    setState(() {
                                      print(answerIdc);
                                      answerIdc[identifiers[questionIndex]]!
                                          .clear();
                                      answerSet[identifiers[questionIndex]]!
                                          .clear();
                                      //if (index != _radioController.selectedIndex) {
                                      answerIdc[identifiers[questionIndex]]!
                                          .add(index);

                                      answerSet[identifiers[questionIndex]]!
                                          .add(index);
                                    });
                                  }
                                }))),
                    // Visibility(
                    //     visible: (questions[questionIndex].questionType ==
                    //         QuestionType.ImageChoice),
                    //     child: Padding(
                    //         padding: EdgeInsets.all(10),
                    //         child: currImage = new QuestImage(
                    //             key: UniqueKey(),
                    //             question: questions[questionIndex]))),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.MultipleChoice),
                        //child: Expanded(
                        child: new ListView.builder(
                            shrinkWrap: true,
                            itemCount: currentQuestion.answers.length,
                            itemBuilder: (BuildContext context, int index) {
                              return new Card(
                                  child: new Container(
                                      padding: new EdgeInsets.all(1.0),
                                      child: CheckboxListTile(
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          dense: false,
                                          //font change
                                          title: new AutoSizeText(
                                            currentQuestion.answers[index].text,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5),
                                            maxLines: 3,
                                          ),
                                          value: answerIdc[identifiers[
                                                      questionIndex]]!
                                                  .indexOf(questions[
                                                          questionIndex]
                                                      .answers
                                                      .indexOf(currentQuestion
                                                          .answers[index])) !=
                                              -1, //if index of current answer is stored in list of indices of selected answers
                                          onChanged: (bool? val) {
                                            if (val != null && val) {
                                              setState(() {
                                                //remove dummy index, if neccessary
                                                if (answerIdc[identifiers[
                                                            questionIndex]]!
                                                        .isNotEmpty &&
                                                    answerIdc[identifiers[
                                                                questionIndex]]![
                                                            0] ==
                                                        -1) {
                                                  answerIdc[identifiers[
                                                          questionIndex]]!
                                                      .remove(-1);
                                                }

                                                if (answerSet[identifiers[
                                                            questionIndex]]!
                                                        .isNotEmpty &&
                                                    answerSet[identifiers[
                                                                questionIndex]]![
                                                            0] ==
                                                        -1) {
                                                  answerSet[identifiers[
                                                          questionIndex]]!
                                                      .remove(-1);
                                                }
                                                //if answer has clearFlag, delete all other selections
                                                if (currentQuestion
                                                    .answers[index].clearFlag) {
                                                  answerSet[identifiers[
                                                          questionIndex]]!
                                                      .clear();
                                                  answerIdc[identifiers[
                                                          questionIndex]]!
                                                      .clear();
                                                }
                                                //if other question was selected, deselect answer with clearFlag
                                                List<int> tmp =
                                                    new List<int>.from(
                                                        answerIdc[identifiers[
                                                                questionIndex]]!
                                                            .toList());
                                                for (int selectedIndex in tmp) {
                                                  if (currentQuestion
                                                      .answers[selectedIndex]
                                                      .clearFlag) {
                                                    answerSet[identifiers[
                                                            questionIndex]]!
                                                        .remove(selectedIndex);
                                                    answerIdc[identifiers[
                                                            questionIndex]]!
                                                        .remove(selectedIndex);
                                                  }
                                                }

                                                answerIdc[identifiers[
                                                        questionIndex]]!
                                                    .add(questions[
                                                            questionIndex]
                                                        .answers
                                                        .indexOf(currentQuestion
                                                                .answers[
                                                            index])); //add index if answer was selected

                                                answerSet[identifiers[
                                                        questionIndex]]!
                                                    .add(questions[
                                                            questionIndex]
                                                        .answers
                                                        .indexOf(currentQuestion
                                                                .answers[
                                                            index])); //add index if answer was selected
                                              });
                                            } else {
                                              setState(() {
                                                answerIdc[identifiers[
                                                        questionIndex]]!
                                                    .remove(questions[
                                                            questionIndex]
                                                        .answers
                                                        .indexOf(currentQuestion
                                                                .answers[
                                                            index])); //remove index if answer was unselected

                                                answerSet[identifiers[
                                                        questionIndex]]!
                                                    .remove(questions[
                                                            questionIndex]
                                                        .answers
                                                        .indexOf(currentQuestion
                                                                .answers[
                                                            index])); //remove index if answer was unselected
                                              });
                                            }
                                            ;
                                          })));
                            })),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.TextInput),
                        child: new TextField(
                          obscureText: false,
                          onChanged: (text) {
                            setState(() {
                              questions[questionIndex]
                                  .answers[0] //only one answer in there anyways
                                  .text = text;
                              answerIdc[identifiers[questionIndex]]!.clear();
                              answerIdc[identifiers[questionIndex]]!.add(0);
                            });
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: questions[questionIndex]
                                  .answers[0] //only one answer in there anyways
                                  .text),
                        )),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.ImageChoice),
                        child: new QuestImage(
                            key: UniqueKey(),
                            question: questions[questionIndex],
                            gridSize: 10,
                            answerIdc: answerIdc[identifiers[questionIndex]]!
                                .toList())),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.NumberInput),
                        child: new TextFormField(
                          controller: controllers[identifiers[questionIndex]],
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          enableIMEPersonalizedLearning: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (questions[questionIndex].answers[0].minValue !=
                                    null ||
                                questions[questionIndex].answers[0].maxValue !=
                                    null) {
                              double? val = double.tryParse(value!.replaceAll(
                                  r',',
                                  '.')); //convert , to . and parse to double

                              if (val == null)
                                return 'Eine Eingabe ist erforderlich. Bei der Eingabe sind nur Zahlen zulässig.';

                              if (val <
                                      questions[questionIndex]
                                          .answers[0]
                                          .minValue! ||
                                  val >
                                      questions[questionIndex]
                                          .answers[0]
                                          .maxValue!)
                                return 'Die Eingabe muss zwischen ' +
                                    questions[questionIndex]
                                        .answers[0]
                                        .minValue
                                        .toString() +
                                    ' und ' +
                                    questions[questionIndex]
                                        .answers[0]
                                        .maxValue
                                        .toString() +
                                    ' liegen';
                            }

                            if (value == null || value.isEmpty) {
                              return 'Eine Eingabe ist erforderlich';
                            }

                            return null;
                          },
                          onChanged: (text) {
                            if (text != "")
                              setState(() {
                                questions[questionIndex]
                                    .answers[
                                        0] //only one answer in there anyways
                                    .text = text.replaceAll(r',', '.');

                                answerIdc[identifiers[questionIndex]]!.clear();
                                answerIdc[identifiers[questionIndex]]!.add(0);

                                answerSet[identifiers[questionIndex]]!.clear();
                                answerSet[identifiers[questionIndex]]!.add(
                                    double.parse(text.replaceAll(r',', '.'))
                                        .toInt());
                              });
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: questions[questionIndex]
                                  .answers[0] //only one answer in there anyways
                                  .text),
                        )),
                    Visibility(
                        visible: (questions[questionIndex].questionType ==
                            QuestionType.NumberInput2),
                        child: TextFormField(
                          obscureText: false,
                          controller: controllers[identifiers[questionIndex]],
                          keyboardType: TextInputType.number,
                          enableIMEPersonalizedLearning: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (questions[questionIndex].answers[0].minValue !=
                                    null ||
                                questions[questionIndex].answers[0].maxValue !=
                                    null) {
                              double? val = double.tryParse(value!.replaceAll(
                                  r',',
                                  '.')); //convert , to . and parse to double
                              print(val);
                              if (val == null)
                                return 'Eine Eingabe ist erforderlich. Bei der Eingabe sind nur Zahlen zulässig.';

                              if (val <
                                      questions[questionIndex]
                                          .answers[0]
                                          .minValue! ||
                                  val >
                                      questions[questionIndex]
                                          .answers[0]
                                          .maxValue!)
                                return 'Die Eingabe muss zwischen ' +
                                    questions[questionIndex]
                                        .answers[0]
                                        .minValue
                                        .toString() +
                                    ' und ' +
                                    questions[questionIndex]
                                        .answers[0]
                                        .maxValue
                                        .toString() +
                                    ' liegen';
                            }

                            if (value == null || value.isEmpty) {
                              return 'Eine Eingabe ist erforderlich';
                            }

                            return null;
                          },
                          onChanged: (text) {
                            if (text != "")
                              setState(() {
                                questions[questionIndex]
                                    .answers[
                                        0] //only one answer in there anyways
                                    .text = text.replaceAll(r',', '.');
                                print("number input:");
                                print(text.replaceAll(r',', '.'));
                                print(int.parse(text.replaceAll(r',', '.')));
                                answerIdc[identifiers[questionIndex]]!.clear();
                                answerIdc[identifiers[questionIndex]]!.add(0);

                                answerSet[identifiers[questionIndex]]!.clear();
                                answerSet[identifiers[questionIndex]]!.add(
                                    double.parse(text.replaceAll(r',', '.'))
                                        .toInt());
                              });
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: questions[questionIndex]
                                  .answers[0] //only one answer in there anyways
                                  .text),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            visible: questionIndex != 0,
                            child: Padding(
                                child: Button.accent(
                                  buttonLabel: 'Zurück',
                                  onPressed: onBackButtonPressed,
                                ),
                                padding: EdgeInsets.all(8)),
                          ),
                          Visibility(
                            visible: !userHasAnsweredCurrentQuestion &&
                                currentQuestion.isOptional,
                            child: Padding(
                                child: Button.primary(
                                    buttonLabel: 'Überspringen',
                                    onPressed: userHasAnsweredCurrentQuestion
                                        ? onNextButtonPressed
                                        : skipQuestion),
                                padding: EdgeInsets.all(8)),
                          ),
                          Visibility(
                            visible:
                                userHasAnsweredCurrentQuestion || //show else
                                    !currentQuestion.isOptional,
                            child: Padding(
                                child: Button.primary(
                                    buttonLabel: 'Weiter',
                                    onPressed: userHasAnsweredCurrentQuestion
                                        ? onNextButtonPressed
                                        : () {}),
                                padding: EdgeInsets.all(8)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
            Visibility(
                visible: questions[questionIndex].infoText != "",
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: InfoButton(
                      infoText: questions[questionIndex].infoText,
                      infoURLs: questions[questionIndex].infoURLs),
                )),
            // FittedBox(
            //     child: ColoredBox(
            //       child: Row( children: [ Image(image: AssetImage("assets/images/UKU_Logo_CMYK_schwarz.png")), Image(image: AssetImage("assets/images/Logo_PREVENT_KNPM.jpg")),Image(image: AssetImage("assets/images/Logo_UU_scaled.png")),
            //   ]
            // ),
            // color: AppColors.skyblue))
          ],
        ),
      ),
    ));
  }

  void onNextButtonPressed() {
    //handle image question
    if (questions[questionIndex].questionType == "ImageChoice") {
      answerIdc[identifiers[questionIndex]]!.clear();
      answerIdc[identifiers[questionIndex]]!.add(0);
      answerSet[identifiers[questionIndex]]!.clear();
      //answerSet[identifiers[questionIndex]]!.add(currImage.);
    }

    if (questionIndex < numberOfQuestions) {
      setState(() {
        //save previous question to jump back if needed
        prevQuestionIndex.push(questionIndex);
      });

      //determine next question to come
      var jumpIdx = evalNextState();

      //if done via jump to exit id (id.end) go to results
      if (jumpIdx == numberOfQuestions) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              questionnaireName: widget.questionnaire.name,
              interpretation:
                  widget.questionnaire.name == "Bewertungsbogen der App" ||
                          widget.questionnaire.name ==
                              "Fragebogen zur Anwenderfreundlichkeit der App"
                      ? sendResultToServer()
                      : evaluateResult(),
              additionalRisks: evaluateRisks(),
              fromEval:
                  !(widget.questionnaire.name == "Bewertungsbogen der App" ||
                      widget.questionnaire.name ==
                          "Fragebogen zur Anwenderfreundlichkeit der App"),
            ),
          ),
        );
        return;
      }

      setState(() {
        //jump to next question by setting pointer
        questionIndex = jumpIdx;
      });
    } else {
      //show results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            questionnaireName: widget.questionnaire.name,
            interpretation:
                widget.questionnaire.name == "Bewertungsbogen der App" ||
                        widget.questionnaire.name ==
                            "Fragebogen zur Anwenderfreundlichkeit der App"
                    ? sendResultToServer()
                    : evaluateResult(),
            additionalRisks: evaluateRisks(),
            fromEval:
                !(widget.questionnaire.name == "Bewertungsbogen der App" ||
                    widget.questionnaire.name ==
                        "Fragebogen zur Anwenderfreundlichkeit der App"),
          ),
        ),
      );
    }
  }

  void skipQuestion() {
    if (questionIndex < numberOfQuestions) {
      setState(() {
        //save previous question to jump back if needed
        prevQuestionIndex.push(questionIndex);
      });

      //determine next question to come via jumpSkipped parameter
      var jumpIdx = identifiers.indexOf(currentQuestion.jumpSkipped);
      if (currentQuestion.jumpSkipped == "id.end") jumpIdx = numberOfQuestions;

      //set answer to "non-existing" value -1 -> catch in sendResults
      answerIdc[identifiers[questionIndex]]!.clear();
      answerSet[identifiers[questionIndex]]!.clear();
      answerIdc[identifiers[questionIndex]]!.add(-1);
      answerSet[identifiers[questionIndex]]!.add(-1);

      //if done via jump to exit id (id.end) go to results
      if (jumpIdx == numberOfQuestions) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              questionnaireName: widget.questionnaire.name,
              interpretation:
                  widget.questionnaire.name == "Bewertungsbogen der App" ||
                          widget.questionnaire.name ==
                              "Fragebogen zur Anwenderfreundlichkeit der App"
                      ? sendResultToServer()
                      : evaluateResult(),
              additionalRisks: evaluateRisks(),
              fromEval:
                  !(widget.questionnaire.name == "Bewertungsbogen der App" ||
                      widget.questionnaire.name ==
                          "Fragebogen zur Anwenderfreundlichkeit der App"),
            ),
          ),
        );
        return;
      }

      setState(() {
        //jump to next question by setting pointer
        questionIndex = jumpIdx;
      });
    } else {
      //show results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            questionnaireName: widget.questionnaire.name,
            interpretation:
                widget.questionnaire.name == "Bewertungsbogen der App" ||
                        widget.questionnaire.name ==
                            "Fragebogen zur Anwenderfreundlichkeit der App"
                    ? sendResultToServer()
                    : evaluateResult(),
            additionalRisks: evaluateRisks(),
            fromEval:
                !(widget.questionnaire.name == "Bewertungsbogen der App" ||
                    widget.questionnaire.name ==
                        "Fragebogen zur Anwenderfreundlichkeit der App"),
          ),
        ),
      );
    }
  }

  void onBackButtonPressed() {
    if (prevQuestionIndex.isNotEmpty) {
      setState(() {
        questionIndex = prevQuestionIndex.pop();
      });
    }
  }

  int evalNextState() {
    String jumpID = "";

    final evaluator = const ExpressionEvaluator();
    var context = {'answer': answerIdc};

    var rules = questions[questionIndex]
        .answers[answerIdc[identifiers[questionIndex]]![0]]
        .jumpRules;

    Map<String, String> answerText = {};

    for (var i = 0; i <= questionIndex; i++) {
      answerText.addAll({identifiers[i]: questions[i].answers[0].text});
    }
    print("DEBUG in EVAL: " + answerText.toString());
    print("DEBUG in EVAL: " + answerSet.toString());
    print("DEBUG in EVAL: " + rules.toString());
    //identify valid rule to select jumpIdx accordingly
    for (int i = 0; i < rules.length; i++) {
      var expression = rules[i].evalExpression(answerSet, answerText);
      print(expression);
      var expressionValid = evaluator.eval(expression, context);

      if (expressionValid) {
        jumpID = rules[i].jumpID;
        List<int> score = rules[i].score;
        //add score to add interpretation to results
        if (score != null) {
          this.interpretations.addAll(score);
          this.interpretations.toSet().toList(); //unique list elements
        }

        break;
      }
    }

    //if jumpID = id.end -> jump to end
    if (jumpID == "id.end") return numberOfQuestions;
    //else get correct index
    return getIndexByIdentifier(jumpID);
  }

  //return index of identifier according to questionnaire
  int getIndexByIdentifier(String identifier) {
    //Jump to invalid index, if identifier does not exist
    if (!identifiers.contains(identifier)) {
      print("Error: Invalid Identifier");
      return -1;
    }

    return identifiers.indexOf(identifier);
  }
}

class RadioTile extends StatelessWidget {
  const RadioTile({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.index,
    required this.title,
  }) : super(key: key);

  final String title;
  final int index;
  final int? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      leading: Radio<int>(
        groupValue: selected,
        value: index,
        onChanged: (val) {
          onTap();
        },
      ),
    );
  }
}
