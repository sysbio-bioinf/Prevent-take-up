import 'package:meta/meta.dart';
import 'package:questionnaires/models/jumpRule.dart';

class Answer {
  String text;
  final List<JumpRule> jumpRules;
  final int? score;
  final bool clearFlag;
  final int? minValue;
  final int? maxValue;

  Answer(
      {required this.text,
      required this.jumpRules,
      this.score,
      required this.clearFlag,
      this.minValue,
      this.maxValue});

  factory Answer.fromJson(Map<String, dynamic> json) {
    var clearFlag = false;
    if (json['clearFlag'] != null) {
      clearFlag = json['clearFlag'];
    }

    return Answer(
        text: json['text'],
        score: (json['score'] ==null) ? -1 : json['score'] ,
        minValue: json['minValue'],
        maxValue: json['maxValue'],
        clearFlag: clearFlag,
        jumpRules: List<JumpRule>.from(
            json['jumpRules'].map((x) => JumpRule.fromJson(x))));
  }
  Map<String, dynamic> toJson() => {
        'text': text,
        'score': score,
        'minValue': minValue,
        'maxValue': maxValue,
        'jumpRules': List<dynamic>.from(jumpRules.map((x) => x.toJson()))
      };

  @override
  String toString() => toJson().toString();
}
