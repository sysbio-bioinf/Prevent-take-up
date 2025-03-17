import 'package:meta/meta.dart';
import 'package:questionnaires/models/interpretation.dart';
import 'package:questionnaires/models/question.dart';
import 'package:collection/collection.dart';

class Questionnaire {
  final String name;
  final String instructions;
  final List<Question> questions;
  final List<Interpretation> interpretations;
  final List<String> questionIDs;

  Questionnaire({
    required this.name,
    required this.instructions,
    required this.questions,
    required this.interpretations,
    required this.questionIDs,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) => Questionnaire(
        name: json['name'],
        instructions: json['instructions'],
        questions: List<Question>.from(
            json['questions'].map((x) => Question.fromJson(x))),
        questionIDs:
            List<String>.from(json['questions'].map((x) => x['questionID'])),
        interpretations: List<Interpretation>.from(
            json['interpretations'].map((x) => Interpretation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'instructions': instructions,
        'questions': List<dynamic>.from(questions.map((x) => x.toJson())),
        'interpretations':
            List<dynamic>.from(interpretations.map((x) => x.toJson())),
      };

  /**
   * Convert set of given answers to nested JSON object for transfer
   */
  Map<String, dynamic> answersToJson(Map<String, List<int>> givenAnswers) {
    Map<String, dynamic> res = new Map<String, dynamic>();
    res['answers'] = new List<Map<String, String>>.empty(growable: true);
    res['collectedAt'] = DateTime.now().toIso8601String();

    givenAnswers.forEach((key, answerSet) {
      answerSet.forEach((answerIdx) {
        res['answers'].add({
          'key': key,
          'value': answerIdx != -1
              ? questions[questionIDs.indexOf(key)].answers[answerIdx].text
              : "question was skipped"
        });
      });
    });

    return res;
  }

  @override
  String toString() => toJson().toString();
}
