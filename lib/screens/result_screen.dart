import 'package:flutter/material.dart';
import 'package:questionnaires/widgets/button.dart';
import 'package:questionnaires/screens/html_screen.dart';
import 'package:easy_actions/easy_actions.dart';
import 'package:questionnaires/configs/constants.dart';
import 'package:questionnaires/services/questionnaire_service.dart';
import 'package:questionnaires/screens/questionnaire_screen.dart';
import 'package:questionnaires/models/questionnaire.dart';

class ResultScreen extends StatelessWidget {
  final String questionnaireName;
  final List<String> interpretation;
  final List<String> additionalRisks;
  final bool fromEval;

  ResultScreen(
      {required this.questionnaireName,
      required this.interpretation,
      required this.additionalRisks,
      required this.fromEval});

  @override
  Widget build(BuildContext context) {
    final questionnaireService = QuestionnaireService();
    Future<Questionnaire> quest = questionnaireService
        .getQuestionnaireByPath('assets/questionnaires/merged_evaluation.json');
    //turn on dialog in evaluation mode
    print("From EVAL");
    print(this.fromEval);
    if (EVAL_MODE && fromEval)
      Future.delayed(Duration.zero, () => showEvalDialog(context));

    this.interpretation.forEach((element) => print(element));

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20, left: 10, right: 10),
                  child: Text(
                    'Vielen Dank für Ihre Teilnahme',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                ),
                for (String recommend in interpretation)
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 10, left: 5, right: 5),
                      child: Text(
                        recommend,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                SizedBox(height: 20),
                additionalRisks.length > 0
                    ? Text(
                        "Ihre Angaben weisen auf bestehende Risikofaktoren hin wie: ",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )
                    : SizedBox(height: 1),
                for (String risk in additionalRisks)
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, bottom: 0, left: 5, right: 5),
                      child: Text(
                        risk,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                SizedBox(
                  height: 15,
                ),
                additionalRisks.length > 0
                    ? additionalRisks.length == 1
                        ? Text(
                            "Dieser Faktor kann zu gesundheitlichen Folgeschäden führen und mit einem erhöhten Krebsrisiko einhergehen. Wir empfehlen Ihnen daher, mit Ihrem Hausarzt/ Ihrer Hausärztin Kontakt aufzunehmen und über Ihr persönliches Risiko zu sprechen. Risikofaktoren wie Übergewicht, Ernährung mit mehrmals pro Woche rotem Fleisch, Bewegungsmangel, Rauchen, erhöhtem Alkoholkonsum, Diabetes mellitus Typ II können das Risiko einer Krebserkrankung erhöhen. Untergewicht stellt ein erhöhtes Risiko für Brustkrebs dar. Eine gesundheitsbewusste Lebensweise mit mediterraner Kost, regelmäßiger körperlicher Bewegung (3 mal 45 Min. pro Woche), Nikotinkarenz und weniger Alkohol kann dazu beitragen, das Risiko einer Krebserkrankung zu verringern.",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )
                        : Text(
                            "Diese Faktoren können zu gesundheitlichen Folgeschäden führen und mit einem erhöhten Krebsrisiko einhergehen. Wir empfehlen Ihnen daher, mit Ihrem Hausarzt/ Ihrer Hausärztin Kontakt aufzunehmen und über Ihr persönliches Risiko zu sprechen. Risikofaktoren wie Übergewicht, Ernährung mit mehrmals pro Woche rotem Fleisch, Bewegungsmangel, Rauchen, erhöhtem Alkoholkonsum, Diabetes mellitus Typ II können das Risiko einer Krebserkrankung erhöhen. Untergewicht stellt ein erhöhtes Risiko für Brustkrebs dar. Eine gesundheitsbewusste Lebensweise mit mediterraner Kost, regelmäßiger körperlicher Bewegung (3 mal 45 Min. pro Woche), Nikotinkarenz und weniger Alkohol kann dazu beitragen, das Risiko einer Krebserkrankung zu verringern.",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )
                    : Text(
                        "Risikofaktoren wie Übergewicht, Ernährung mit mehrmals pro Woche rotem Fleisch, Bewegungsmangel, Rauchen, erhöhter Alkoholkonsum, Diabetes mellitus Typ II können das Risiko einer Krebserkrankung erhöhen. Untergewicht stellt ein erhöhtes Risiko für Brustkrebs dar. Eine gesundheitsbewusste Lebensweise mit mediterraner Kost, regelmäßiger körperlicher Bewegung (3 mal 45 Min. pro Woche), Nikotinkarenz und weniger Alkohol kann dazu beitragen, das Risiko einer Krebserkrankung zu verringern.",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Button.highlighted(
                    buttonLabel: 'Evaluationsfragebogen',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => FutureBuilder(
                                future: quest,
                                builder: (BuildContext context,
                                    AsyncSnapshot<Questionnaire> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData &&
                                      snapshot.data != null) {
                                    return QuestionnaireScreen(
                                        questionnaire: snapshot.data!);
                                  } else {
                                    return Text(
                                        "Fragebogen konnte nicht geladen werden.");
                                  }
                                },
                              )),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Button.primary(
                    buttonLabel: 'Was kann ich selbst tun?',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HTMLScreen(
                            title:
                                "Was kann ich selbst tun, um das Risko einer Krebserkrankung zu minimieren?",
                            file:
                                "<!DOCTYPE html><!--[if lt IE 7]><html class=no-js lt-ie9 lt-ie8 lt-ie7> <![endif]--><!--[if IE 7]> <html class=no-js lt-ie9 lt-ie8> <![endif]--><!--[if IE 8]> <html class=no-js lt-ie9> <![endif]--><!--[if gt IE 8]><html class=no-js> <!--<![endif]--><html><head><meta charset=utf-8><title>Was ist Darmkrebs</title><link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet'><style>body {font-family: Raleway;font-size: larger;}.box {width: 90%;}img {max-width: 100%;height: auto;}</style></head><body><!--[if lt IE 7]><p class=browsehappy>You are using an <strong>outdated</strong> browser. Please <a href=#>upgrade your browser</a> to improve your experience.</p><![endif]--><p>Es gibt einige Dinge, die Sie tun können, um Ihr eigenes Risiko für eine Krebserkrankung zu minimieren:</p><ol><li>Teilnahme an Untersuchungen zur Krebsfrüherkennung</li><li>Gesunde, ausgewogene Ernährung mit Schwerpunkt auf pflanzlichen Produkten (viel Gemüse, Frischobst, Vollkornprodukte, Ballaststoffe, Hülsenfrüchte) und nur wenig rotes Fleisch oder verarbeitete Fleischprodukte (Wurst) unter Beachtung der Empfehlungen der Deutschen Gesellschaft für Ernährung e.V.</li><li>Wenig Alkohol</li><li>Verzicht auf Rauchen</li><li>Regelmäßige körperliche Bewegung</li><li>Normalgewicht (BMI 18,5 - 24,9)</li><li>Bei Frauen: Stillen </li></ol><div class=box><center><img src=assets/assets/infos/BMI.png /> </center></div></body></html>"))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Button.primary(
                    buttonLabel: 'weiterführende Informationen',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HTMLScreen(
                            title: "Weiterführende Informationen",
                            file:
                                "<!DOCTYPE html><!--[if lt IE 7]><html class=no-js lt-ie9 lt-ie8 lt-ie7> <![endif]--><!--[if IE 7]> <html class=no-js lt-ie9 lt-ie8> <![endif]--><!--[if IE 8]> <html class=no-js lt-ie9> <![endif]--><!--[if gt IE 8]><html class=no-js> <!--<![endif]--><html><head><meta charset=utf-8><title>Was ist Darmkrebs</title><link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet'><style>body {font-family: Raleway;font-size: larger;}.box {width: 90%;}img {max-width: 100%;height: auto;}</style></head><body><!--[if lt IE 7]><p class=browsehappy>You are using an <strong>outdated</strong> browser. Please <a href=#>upgrade your browser</a> to improve your experience.</p><![endif]--><p>Weitere Informationen zur Krebsvorsorge, können Sie unter folgenden Links finden:</p><h3>Darmkrebs</h3><a href=https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/darmkrebs/frueherkennung.html target=_blank>https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/darmkrebs/frueherkennung.html</a><h3>Brustkrebs</h3><a href=https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/brustkrebs/frueherkennung.html target=_blank>https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/brustkrebs/frueherkennung.html</a><h3>Prostatakrebs</h3><a href=https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/prostatakrebs/frueherkennung.html target=_blank>https://www.krebsgesellschaft.de/onko-internetportal/basis-informationen-krebs/krebsarten/prostatakrebs/frueherkennung.html </a></body></html>"))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Button.primary(
                    buttonLabel: '(Sucht-)Beratung',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HTMLScreen(
                            title: "Beratung",
                            file:
                                "<!DOCTYPE html><!--[if lt IE 7]><html class=no-js lt-ie9 lt-ie8 lt-ie7> <![endif]--><!--[if IE 7]> <html class=no-js lt-ie9 lt-ie8> <![endif]--><!--[if IE 8]> <html class=no-js lt-ie9> <![endif]--><!--[if gt IE 8]><html class=no-js> <!--<![endif]--><html><head><meta charset=utf-8><title>Was ist Darmkrebs</title><link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet'><style>body {font-family: Raleway;font-size: larger;}.box {width: 90%;}img {max-width: 100%;height: auto;}</style></head><body><!--[if lt IE 7]><p class=browsehappy>You are using an <strong>outdated</strong> browser. Please <a href=#>upgrade your browser</a> to improve your experience.</p><![endif]--><p>Unter folgenden Links können Sie hilfreiche Informationen über Beratungsstellen finden:</p><p>Deutsches Krebsforschungszentrum, Krebsinformationsdienst (KID), <a href=https://www.krebsinformationsdienst.de target=_blank>www.krebsinformationsdienst.de</a>, Im Neuenheimer Feld 280, 69120 Heidelberg, Telefon: 0800 - 420 30 40 (täglich von 8 bis 20 Uhr; der Anruf ist kostenfrei), E-Mail: <a href=mailto:krebsinformationsdienst@dkfz.de target=_blank>krebsinformationsdienst@dkfz.de</a> </p><a href=https://www.kenn-dein-limit.de/alkoholberatung/ target=_blank>Alkoholberatung: Alkohol? Kenn dein Limit. (kenn-dein-limit.de)</a><br><a href=https://www.caritas.de/hilfeundberatung/ratgeber/sucht/adressen-suchtberatung target=_blank>Caritas-Sucht- und Drogenberatungsstellen</a><br><a href=https://www.bzga.de/service/beratungsstellen/suchtprobleme/ target=_blank>BZgA: Suchtprobleme</a> <br> <a href=https://www.dhs.de/suchthilfe/suchtberatung target=_blank>Suchtberatung - DHS</a></body></html>"))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Button.primary(
                    buttonLabel: 'Zurück zum Hauptmenü',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
              //
            ),
          ),
        ),
      ),
    );
  }

  void showEvalDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: new Text("Unterstützung unserer App"),
        content: new Text(
            "Zur Beurteilung unserer App brauchen wir Ihre Unterstützung und möchten Sie bitten, den Evaluationsfragebogen zur App sowie Fragen zu Lebensstilfaktoren auszufüllen. Die Übermittlung dieser Daten erfolgt anonym ohne Personenbezug und auf freiwilliger Basis. Mit Klick auf den Evaluationsfragebogen erklären Sie dafür Ihr Einverständnis. Vielen Dank."),
        actions: <Widget>[
          new EasyElevatedButton(
            label: "Weiter",
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
