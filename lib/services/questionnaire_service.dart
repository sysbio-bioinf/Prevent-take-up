import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:questionnaires/enums/questionnaire_type.dart';
import 'package:questionnaires/models/questionnaire.dart';

class QuestionnaireService {
  String? _getQuestionnaireAssetPath(QuestionnaireType questionnaireType) {
    switch (questionnaireType) {
      case QuestionnaireType.prevent:
        return 'assets/questionnaires/prevent_questions.json';
      // case QuestionnaireType.pain:
      //   return 'assets/questionnaires/pain.json';
      // case QuestionnaireType.evaluation_focus:
      //   return 'assets/questionnaires/evaluation_app_focus.json';
      default:
        return null;
    }
  }

  Future<Questionnaire> getQuestionnaire(
      QuestionnaireType questionnaireType) async {
    final assetPath = _getQuestionnaireAssetPath(questionnaireType);
    final jsonData = await rootBundle.loadString(assetPath!);
    final jsonDataDecoded = jsonDecode(jsonData);
    return Questionnaire.fromJson(jsonDataDecoded);
  }

  Future<Questionnaire> getQuestionnaireByPath(String questionnairePath) async {
    final assetPath = questionnairePath;
    final jsonData = await rootBundle.loadString(assetPath);
    final jsonDataDecoded = jsonDecode(jsonData);
    return Questionnaire.fromJson(jsonDataDecoded);
  }
}
