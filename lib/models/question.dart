import 'package:questionnaires/models/answer.dart';
import 'package:questionnaires/models/questionType.dart';
import 'package:meta/meta.dart';

class Question {
  final String identifier;
  final String text;
  final List<Answer> answers;
  final QuestionType questionType;
  final String infoText;
  final Map<String, String> infoURLs;
  final bool isOptional;
  final String jumpSkipped; //index where to jump, if answer was skipped
  final String image;

  Question(
      {required this.identifier,
      required this.text,
      required this.answers,
      required this.questionType,
      required this.infoText,
      required this.infoURLs,
      required this.isOptional,
      required this.jumpSkipped,
      required this.image});

  factory Question.fromJson(Map<String, dynamic> json) {
    var infoText;
    bool isOptional;
    String jumpSkipped;
    Map<String, String> infoURLs = {};

    print(json);
    if (json['infoText'] != null) {
      infoText = json['infoText'];
    } else
      infoText = "";

    if (json['isOptional'] != null) {
      isOptional = json['isOptional'];

      if (json['jumpSkipped'] == null) {
        throw Exception(
            "If question is optional a jumpSkipped index has to be defined to define which question is next after skipping current.");
      }
    } else
      isOptional = false;

    if (json['jumpSkipped'] != null) {
      jumpSkipped = json['jumpSkipped'];
    } else
      jumpSkipped = "";

    infoURLs = new Map<String, String>();
    if (json['infoURLs'] != null) {
      for (var i = 0; i < json['infoURLs'].length; i++) {
        infoURLs.putIfAbsent(
            json['infoURLs'][i]['text'], () => json['infoURLs'][i]['url']);
      }
    }

    return Question(
        identifier: json['questionID'],
        questionType: getTypeFromString(json['questionType']),
        text: json['text'],
        answers:
            List<Answer>.from(json['answers'].map((x) => Answer.fromJson(x))),
        infoText: infoText,
        infoURLs: infoURLs,
        isOptional: isOptional,
        jumpSkipped: jumpSkipped,
        image: json['image'] != null ? json['image'] : "");
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {
      'identifier': identifier,
      'questionType': questionType.toString().split('.').last,
      'text': text,
      'answers': List<dynamic>.from(answers.map((x) => x.toJson()))
    };

    if (infoText != null) ret.putIfAbsent('infoText', () => this.infoText);
    if (infoURLs != null)
      ret.putIfAbsent(
          'infoURLs',
          () => this
              .infoURLs
              .entries
              .map((e) => "{" + e.key + ":" + e.value + "}"));

    return ret;
  }

  @override
  String toString() => toJson().toString();
}

QuestionType getTypeFromString(String type) {
  type = 'QuestionType.$type';
  return QuestionType.values.firstWhere((f) => f.toString() == type);
}
