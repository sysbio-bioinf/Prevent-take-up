import 'package:expressions/expressions.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

class JumpRule {
  final String jumpID;
  final String jumpRule;
  final List<int> score;

  JumpRule({required this.jumpID, required this.jumpRule, required this.score});

  factory JumpRule.fromJson(Map<String, dynamic> json) {
    var jumpRule;

    if (json['jumpRule'] != null) {
      jumpRule = json['jumpRule'];
    } else {
      jumpRule = "true";
    }

    String jumpExpr;
    if (!json['jumpID'].toString().startsWith("id"))
      throw new FormatException();
    else
      jumpExpr = simplifyRule(jumpRule);

    List<int> score;
    if (json['score'] != null)
      score = (json['score'] as List).map((e) => e as int).toList();
    else
      score = List<int>.empty();

    return JumpRule(jumpID: json['jumpID'], score: score, jumpRule: jumpExpr);
  }

  Map<String, dynamic> toJson() =>
      {'jumpID': jumpID, 'score': score.toString(), 'jumpRule': jumpRule};

  /**
   * remove white spaces from given jumpRule
   */
  static String simplifyRule(String jumpRule) {
    List<String> variables = jumpRule.split(r" ");
    return variables.join();
  }

  /**
   * Evaluate 
   */
  Expression evalExpression(
      Map<String, List<int>> answers, Map<String, String> answerTexts) {
    Expression expr;

    if (jumpRule == "true")
      expr = Expression.parse(jumpRule);
    else {
      //reformat expression, pack ids in answer array

      //cut atomic equations "id.name == idx"
      //RegExp exprAtoms = new RegExp(r"id.([a-zA-Z0-9]+)\=\=([0-9]+)");
      RegExp exprAtomsExt =
          new RegExp(r"id.([a-zA-Z0-9]+)(\=\=|<\=|<|>\=|>)([0-9]+)");
      // RegExp exprAtomsExt = new RegExp(
      //     r"\(?id.([a-zA-Z0-9]+)(\+|\*|\/|\-|\=\=|<\=|<|>\=|>)([0-9]+|id.([a-zA-Z0-9]+))\)?");

      RegExp exprCalc = new RegExp(
          r"id.([a-zA-Z0-9]+)(\+|\*|\/|\-)([0-9]+|id.([a-zA-Z0-9]+)|\()");
      //regex to identify all variables in rule
      RegExp ids = RegExp(r"id.([a-zA-Z0-9]+)");
      //go over string and fill in values for each non-logical math operation to simplify equation
      List<String?> toBeSolved = exprCalc
          .allMatches(jumpRule)
          .map((matchingEquation) => matchingEquation[0])
          .toList();
      List<String?> solved = new List<String?>.from(toBeSolved);
      // print("Debug: to be solved : " + toBeSolved.toString());

      String jumpRuleSolved = jumpRule;

      for (var s = 0; s < toBeSolved.length; s++) {
        List<String?> foundIds =
            ids.allMatches(solved[s]!).map((e) => e[0]).toList();

        // print("Found IDs :" + foundIds.toString());
        for (var fI = 0; fI < foundIds.length; fI++) {
          String foundId = foundIds[fI]!;
          // print("Found ID :" + foundId);
          // print("To be Solved :" + solved[s]!);
          if (foundId != null)
            solved[s] = solved[s]!.replaceAll(foundId, answerTexts[foundId]!);
          // print("Solved :" + solved[s]!);
        }

        //do replacement
        jumpRuleSolved = jumpRuleSolved.replaceAll(toBeSolved[s]!, solved[s]!);
      }

      // print("Debug: to be solved after replacement: " + toBeSolved.toString());
      List<String?> atomicEquations =
          exprAtomsExt.allMatches(jumpRuleSolved).map((m) => m[0]).toList();

      // print("DEBUG: Rule: " + jumpRule);

      //iterate over all matches and replace them by respective answer id.xy -> answer given for this question
      // ids.allMatches(jumpRule).map(
      //       (matchingId) {
      //         List<int> answerIdc = answers[matchingId]!;

      //         jumpRule.replaceAll(matchingId, )
      //       },
      //     );

      // print("atomic :" + atomicEquations.toString());
      // atomicEquations =
      //exprAtoms.allMatches(jumpRule).map((m) => m[0]).toList();
      //create eval string for each atomic
      List<String> expandedFormulae = atomicEquations.map((atomic) {
        //cut latter part of equation

        RegExp equationRegEx = new RegExp(r"(\=\=|<\=|<|>\=|>)");

        String res = "";
        //check if it is a logical equation
        if (atomic!.indexOf(ids) != -1) {
          List<String> parts = atomic.split(equationRegEx);
          //List<String> parts = (equationRegEx == null) ? List<String>.empty() : atomic.split(equationRegEx);
          print(parts);
          String equationSign = atomic.substring(
              equationRegEx.firstMatch(atomic)!.start,
              equationRegEx.firstMatch(atomic)!.end);
          String rest = parts[1];
          String id = parts[0];
          List<int> answerIdc = answers[id]!;
          res = res + "(";

          for (var i = 0; i < answerIdc.length; i++) {
            res += answerIdc[i].toString() + equationSign + rest;
            // print(res);
            if (i != (answerIdc.length - 1)) res += "|";
          }

          res += ")";
          // print("DEBUG: Equation for processing :" + res);
        }
        //else if is non-logical operation do simple replacement
        else {
          res += atomic;
        }

        return res;
      }).toList();

      //replace substring one by one
      String evalString = jumpRuleSolved;
      // print("Debug, EVAL STRING: " + evalString);
      atomicEquations.forEachIndexed((index, element) {
        evalString = evalString.replaceAll(
            RegExp(r'' + element!), expandedFormulae[index]);
      });
      // print("Debug, EVAL STRING: " + evalString);
      expr = Expression.parse(evalString);
    }

    return expr;
  }
}
