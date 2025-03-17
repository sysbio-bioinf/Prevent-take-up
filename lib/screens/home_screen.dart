import 'package:flutter/material.dart';
import 'package:questionnaires/configs/styles.dart';
import 'package:questionnaires/enums/about_type.dart';
import 'package:questionnaires/enums/questionnaire_type.dart';
import 'package:questionnaires/enums/info_type.dart';
import 'package:questionnaires/models/questionnaire.dart';
import 'package:questionnaires/models/infos.dart';
import 'package:questionnaires/screens/questionnaire_screen.dart';
import 'package:questionnaires/services/about_service.dart';
import 'package:questionnaires/services/questionnaire_service.dart';
import 'package:questionnaires/screens/info_screen.dart';
import 'package:questionnaires/screens/about_screen.dart';
import 'package:questionnaires/services/info_service.dart';
import 'package:questionnaires/widgets/slider_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_actions/easy_actions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:questionnaires/screens/html_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen() : super();
  //const HomeScreen({required Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Questionnaire> questionnaires = List<Questionnaire>.empty();
  List<Info> infos = List<Info>.empty();
  Map<String, String> abouts = {};
  Future<bool>? loadAllDataFuture;
  Future<bool>? loadAllInfosFuture;

  Future<bool>? loadAllInfo;

  @override
  void initState() {
    super.initState();
    //load json files with questionnaires and infos
    loadAllDataFuture = loadAllData();

    getFirstStartFlag().then((firstStartFlag) => {
          //check if app was started for the first time -> show mission statement dialog
          if (!firstStartFlag)
            {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => new AlertDialog(
                    title: new Text("Mission Statement"),
                    content: new Text(
                        "Vorsorge- und Früherkennungsmaßnahmen haben eine große Bedeutung bei Krebserkrankungen. Durch auf Sie persönlich zugeschnittene Vorsorgeuntersuchungen können Krebserkrankungen verhindert und durch Früherkennung oftmals früher mit hoher Aussicht auf Heilung festgestellt werden. Die Vorsorge- und Früherkennungs-App PREVENT-TAKE-UP hilft Ihnen, Ihr persönliches Risiko für Brustkrebs, Darmkrebs und Prostatakrebs zu ermitteln. Bei einem auffälligen Ergebnis wird Ihnen zum besseren Einschätzen Ihres persönlichen Risikos ein Beratungsgespräch über sinnvolle Vorsorgemaßnahmen bei Ihrem Arzt/ Ihrer Ärztin empfohlen."),
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
              })
            }
        });

    setFirstStartFlag();
  }

  Future<bool> loadAllInfos() async {
    final infoService = InfoService();
    infos = [];
    for (InfoType infoType in InfoType.values) {
      final info = await infoService.getInfo(infoType);

      // if something went wrong, stop loading questionnaires
      if (info == null) {
        return false;
      }

      infos.add(info);
    }

    return true;
  }

  Future<bool> loadAllData() async {
    final questionnaireService = QuestionnaireService();
    questionnaires = [];
    for (QuestionnaireType questionnaireType in QuestionnaireType.values) {
      final questionnaire =
          await questionnaireService.getQuestionnaire(questionnaireType);

      // if something went wrong, stop loading questionnaires
      if (questionnaire == null) {
        return false;
      }

      questionnaires.add(questionnaire);
    }

    final infoService = InfoService();
    infos = [];
    for (InfoType infoType in InfoType.values) {
      final info = await infoService.getInfo(infoType);

      // if something went wrong, stop loading questionnaires
      if (info == null) {
        return false;
      }

      infos.add(info);
    }

    final aboutService = AboutService();
    abouts = {};
    for (AboutType aboutType in AboutType.values) {
      final about = await aboutService.getAbout(aboutType);

      abouts.addAll(about);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ScalingWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Prevent Take-Up ',
        ),
      ),
      body: FutureBuilder(
        future: loadAllDataFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return Center(
              child: Column(
                children: <Widget>[
                  for (Questionnaire questionnaire in questionnaires)
                    Container(
                        margin: EdgeInsets.all(15.0),
                        child: EasyElevatedButton(
                          label: questionnaire.name,
                          isRounded: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuestionnaireScreen(
                                questionnaire: questionnaire,
                              ),
                            ),
                          ),
                        )),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: EasyElevatedButton(
                        label: 'Informationen Darm-/Brust-/Prostatakrebs',
                        isRounded: true,
                        onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InfoScreen(
                                  infos: infos,
                                ),
                              ),
                            )),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child:
                        //Row(
                        //    mainAxisAlignment: MainAxisAlignment.center,
                        //    children: [
                        EasyElevatedButton(
                      onPressed: () {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return SliderDialog();
                            });
                      },
                      icon: Icon(
                        Icons.text_fields,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: "Textgröße anpassen",
                      labelColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).bottomAppBarColor,
                    ),
                  )
                  //]),
                  ,
                  Container(
                    margin: EdgeInsets.all(15),
                    child: EasyElevatedButton(
                        label: 'Über diese App',
                        labelColor: Theme.of(context).colorScheme.primary,
                        color: Theme.of(context).bottomAppBarColor,
                        isRounded: true,
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AboutScreen(
                                abouts: abouts,
                              ),
                            ))),
                  ),
                  Container(
                      margin: EdgeInsets.all(15),
                      child: EasyElevatedButton(
                          label: 'Datenschutz',
                          isRounded: true,
                          labelColor: Theme.of(context).colorScheme.primary,
                          color: Theme.of(context).bottomAppBarColor,
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => HTMLScreen(
                                      title: "Datenschutz",
                                      file:
                                          "<html><head><meta http-equiv=Content-Type content='text/html; charset=utf-8'><meta name=Generator content='Microsoft Word 15 (filtered)'><style><!-- /* Font Definitions */ @font-face	{font-family:Wingdings;	panose-1:5 0 0 0 0 0 0 0 0 0;}@font-face	{font-family:'Cambria Math';	panose-1:2 4 5 3 5 4 6 3 2 4;}@font-face	{font-family:Calibri;	panose-1:2 15 5 2 2 2 4 3 2 4;}@font-face	{font-family:Tahoma;	panose-1:2 11 6 4 3 5 4 4 2 4;}@font-face	{font-family:Corbel;	panose-1:2 11 5 3 2 2 4 2 2 4;}@font-face	{font-family:'Segoe UI';	panose-1:2 11 5 2 4 2 4 2 2 3;} /* Style Definitions */ p.MsoNormal, li.MsoNormal, div.MsoNormal	{margin:0cm;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}p.MsoHeader, li.MsoHeader, div.MsoHeader	{mso-style-link:'Kopfzeile Zchn';	margin:0cm;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph	{margin-top:0cm;	margin-right:0cm;	margin-bottom:0cm;	margin-left:36.0pt;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}p.MsoListParagraphCxSpFirst, li.MsoListParagraphCxSpFirst, div.MsoListParagraphCxSpFirst	{margin-top:0cm;	margin-right:0cm;	margin-bottom:0cm;	margin-left:36.0pt;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}p.MsoListParagraphCxSpMiddle, li.MsoListParagraphCxSpMiddle, div.MsoListParagraphCxSpMiddle	{margin-top:0cm;	margin-right:0cm;	margin-bottom:0cm;	margin-left:36.0pt;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}p.MsoListParagraphCxSpLast, li.MsoListParagraphCxSpLast, div.MsoListParagraphCxSpLast	{margin-top:0cm;	margin-right:0cm;	margin-bottom:0cm;	margin-left:36.0pt;	font-size:12.0pt;	font-family:'Calibri',sans-serif;}span.KopfzeileZchn	{mso-style-name:'Kopfzeile Zchn';	mso-style-link:Kopfzeile;}.MsoChpDefault	{font-family:'Calibri',sans-serif;} /* Page Definitions */ @page WordSection1	{size:595.0pt 842.0pt;	margin:143.75pt 87.3pt 93.85pt 70.9pt;}div.WordSection1	{page:WordSection1;} /* List Definitions */ ol	{margin-bottom:0cm;}ul	{margin-bottom:0cm;}--></style></head><body lang=DE link='#0563C1' vlink='#954F72' style='word-wrap:break-word'><div class=WordSection1><p class=MsoNormal><span style='position:relative;z-index:251668480'><spanstyle='position:absolute;left:-48px;top:-55px;width:459px;height:80px'><p class=MsoNormal><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoHeader style='margin-right:-15.65pt'><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoHeader style='margin-right:-15.65pt'><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal><b><span style='font-size:11.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></b></p><p class=MsoNormal align=center style='text-align:center;text-indent:14.2pt;page-break-after:avoid;text-autospace:none'><a name='_Toc98516470'></a><aname='_Toc98770616'></a><a name='_Toc98772259'><b><span style='font-size:14.0pt;font-family:'Corbel',sans-serif'>&nbsp;</span></b></a></p><br clear=ALL><p class=MsoNormal><span style='position:relative;z-index:-1895804928'><spanstyle='position:absolute;left:0px;top:-41px;width:595px;height:91px'><imgwidth=595 height=91 src='Datenschutz_PREVENT.fld/image003.png'></span></span><aname='_Hlk98347254'></a></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:15.0pt;margin-left:0cm;background:white'><span style='font-size:16.5pt;font-family:'Corbel',sans-serif;color:black;letter-spacing:.75pt'>PREVENT-TAKE-UP Datenschutz</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Sie bleiben unerkannt.</span></b></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Ihre Daten werden komplett anonymgespeichert. Die Zuordnung der Daten zu einer konkreten Person ist nichtmöglich und eine Nachverfolgung ist ausgeschlossen. </span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Das bedeutet, dass wir zu keinem Zeitpunktwissen, wer Sie sind.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Bitte lesen Sie unsereDatenschutzbestimmungen und stimmen Sie der Verarbeitung zu:</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Datenschutzhinweise der PREVENT-TAKE-UP-App</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Verantwortliche Stelle im Sinnedes Art. 4 Abs. 7 DSGVO:</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Klinik für Innere Medizin I,Universitätsklinikum Ulm</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Albert-Einstein-Allee 23,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>89081 Ulm</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Ansprechpartner:</span></b></p><p class=MsoNormal style='background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Direktionssekretariat.Innere1@uniklinik-ulm.de</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif'>&nbsp;</span></b></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Datenschutzbeauftragter:</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Universitätsklinikum Ulm,Datenschutzbeauftragter</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Albert-Einstein-Allee 11</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>89081 Ulm</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Tel.: +49 731 500 69290</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>E-Mail: datenschutz@uniklinik-ulm.de</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Diese Datenschutzhinweise informieren Sie überZweck, Art und Umfang der durch uns im Rahmen der PREVENT-TAKE-UP-App erhobenenund verarbeiteten Daten. Das Gesamtsystem PREVENT umfasst die PREVENT-TAKE-UP-App(im Folgenden „App“) sowie den Backend-Server des Instituts für MedizinischeSystembiologie der Universität Ulm, auf dem die freiwillig und anonym ohne Personenbezugübermittelten Daten aller Teilnehmenden analysiert werden. Das bedeutet, dasseine Verarbeitung der übermittelten Daten nicht nur mittels der App, sondernauch durch den Backend-Server erfolgt.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Wir nehmen den Schutz Ihrer Daten sehr ernstund arbeiten in voller Übereinstimmung mit den geltendenDatenschutzbestimmungen. Die folgenden Absätze informieren Sie darüber:</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(1) für welchen Zweck die Daten erhobenwerden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(2) was die rechtliche Grundlage für dieVerarbeitung ist,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(3) wie lange wir die Daten aufbewahren und wosie gespeichert werden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(4) welche Daten erhoben werden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(5) warum Alter, Geschlecht,Lebensstil-Faktoren erfasst und gespeichert werden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(6) dass keine Daten an Dritte weiter gegebenwerden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>(7) welche Rechte Sie als Nutzer haben und wieSie diese ausüben können.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>1. Zweck der Datenerhebung und-verarbeitung</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Das freiwillige und anonyme Zurverfügungstellender Daten aus 4.2, die über Ihr mobiles Endgerät, Personal Computer oder Laptoperfasst werden, dokumentiert die Nutzerschaft der App und ermöglicht einenÜberblick über Informationsgehalt, Verständlichkeit und Nutzerfreundlichkeitder App und dient der Verbesserung und Weiterentwicklung der App. Ihre freiwilligübermittelten und anonymen Daten ohne Personenbezug aus 4.2 werden zusammen mitden Daten aller anderen App-Nutzer ausgewertet (im Folgenden „Zweck‘). DieDaten werden nicht für Werbezwecke verwendet. Ihre Angaben zu 4.1 werden nachAnzeige der Empfehlung weder auf ihrem Endgerät gespeichert noch übermittelt.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Es wird ausdrücklich daraufhingewiesen, dass die App einen Arztbesuch bzgl. Vorsorgemaßnahmen empfehlenkann und weder eine medizinische Beratung noch eine individuelle Diagnostik oderTherapie durchführt. </span></b></p><p class=MsoNormal style='background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>2. Einwilligung in die Datenverarbeitung</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Die Verarbeitung von Daten erfolgt aufGrundlage Ihrer freiwilligen Einwilligung in die Verarbeitung der Daten zu demoben genannten Zweck. Rechtsgrundlage für die Datenverarbeitung ist Art. 6Abs.1c) DSGVO. </span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Die Übermittlung der Daten ist freiwillig underfolgt anonym ohne Personenbezug an das Institut zum Zweck derwissenschaftlichen Auswertung. Personenbezogene Daten werden nicht erhoben. DieZuordnung der Daten zu einer konkreten Person ist nicht möglich und eineNachverfolgung ist ausgeschlossen. </span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3. Umfang der erhobenen Daten,Speicherort und -dauer</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.1 Die Verarbeitung der in Ziff. 4 genanntenDaten der Nutzer der PREVENT-TAKE-UP-App ist zweckgebunden und gemäß dengesetzlichen Bestimmungen. Zu dem oben genannten Zweck werden die freiwilligund anonym übermittelten Angaben unter 4.2 erfasst. </span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.2 Welche Daten für den Zweck gespeichertwerden, wird in Ziff. 4 genannt. Zu keinem Zeitpunkt werden unmittelbaridentifizierende Informationen wie Namen oder Adresse gespeichert. Ausschließlichdie in Ziff. 4.2 genannten freiwillig und anonym übermittelten Daten werdengespeichert.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.3 Durch Ihre Zustimmung zur Datenverarbeitung,übersenden Sie Ihre freiwillig und anonym übermittelten Daten und erlauben, dieunter Ziff. 4.2 genannten Daten zum o.g. Zweck zu speichern und zu verarbeiten.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.4 Der Abruf der von Ihnen freiwillig protokolliertenDaten erfolgt zwischen Ihrem Endgerät und dem Server des Instituts fürMedizinische Systembiologie der Universität Ulm. Diese Daten werden anonym zudem von uns ausschließlich in Deutschland betriebenen Server übertragen, dortverarbeitet und die unter Ziff. 4.2 genannten Daten gespeichert.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.5 Ihre Daten werden gelöscht, sobald der inZiff. 1 genannte Zweck der Datenerhebung und -verarbeitung entfällt, spätestensjedoch nach 10 Jahren. Bis zu diesem Zeitpunkt werden Ihre freiwilligübermittelten Daten anonym ohne Personenbezug auf einem Server des Institutsfür Medizinische Systembiologie der Universität Ulm gespeichert. Entsprechendder Leitlinie 17 der „Leitlinien zur Sicherung guter wissenschaftlicher Praxis“der Deutschen Forschungsgemeinschaft (Stand: September 2019) ist dieSpeicherung der Daten für 10 Jahre erforderlich. Lediglich dieAuswertungsergebnisse werden zu Forschungszwecken in aggregierter undanonymisierter Form, die keinen Rückschluss auf Ihre Person zulässt,veröffentlicht und möglicherweise dauerhaft in einer wissenschaftlichenForschungsdatenbank gespeichert. </span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>3.6 Wenn Sie die App nicht mehr nutzen wollen,können Sie die App löschen. Daten, die zu diesem Zeitpunkt bereits inAuswertungen eingeflossen sind und veröffentlicht wurden, können aus diesennicht mehr rückwirkend entfernt werden, da sie ausschließlich in anonymisierterForm in die Auswertungen eingegangen sind. </span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>4. Erhebung und Speicherung vonDaten</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>4.1 Die Antworten zu den Fragen der App wie zuVorerkrankungen und zur Familienanamnese sowie zu tumorspezifischen Fragen,dienen zur individuellen Empfehlungsermittlung und werden weder gespeichertnoch weitergeleitet. Nach Schließen der Anwendung werden diese nicht auf demmobilen Endgerät oder Personal Computer oder Laptop gespeichert.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>4.2 Folgende Daten können auf freiwilligerBasis nach Ihrer Bestätigung anonym ohne Personenbezug an den Server desInstituts für Medizinische Systembiologie der Universität Ulm übermittelt unddort gespeichert werden.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Allgemeine Daten / Lebensstil-Faktoren:</span></b></p><p class=MsoListParagraphCxSpFirst style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Alter</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Geschlecht</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Körpergewicht</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Fleischkonsum</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>KörperlicheAktivität</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Tabakkonsum</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Alkoholkonsum</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Diabetesmellitus</span></p><p class=MsoListParagraphCxSpLast style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>&nbsp;</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Fragen zur Anwenderfreundlichkeitder App</span></b></p><p class=MsoListParagraphCxSpFirst style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichdenke, ich würde die Website/ App regelmäßig nutzen.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>DieWebsite/ App erscheint mir unnötig kompliziert.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Website/ App ist einfach zu benutzen.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichdenke, ich bräuchte technische Unterstützung um die Website/ App nutzen zukönnen.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, dass die verschiedenen Funktionen der Website/ App gut integriert sind.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>DieWebsite/ App erscheint mir zu uneinheitlich.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichglaube, dass die meisten Leute die Benutzung der Website/ App schnell erlernenkönnen.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>DieWebsite/ App erscheint mir sehr umständlich zu benutzen.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfühle mich bei der Benutzung der Website/ App sehr sicher.</span></p><p class=MsoListParagraphCxSpLast style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-align:justify;text-indent:-17.85pt;line-height:150%;text-autospace:none'><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<spanstyle='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichmusste einiges lernen, um mit der Website/ App zurecht zu kommen.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Bewertung der App</span></b></p><p class=MsoListParagraphCxSpFirst style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>HabenSie von der Prevent-Take-Up-Anwendung die Empfehlung erhalten, eine/n Ärztin/Arzt aufzusuchen?      </span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Fragen der App sind verständlich.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:0cm;margin-left:17.85pt;margin-bottom:.0001pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Anzahl der Fragen ist zu hoch</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Anzahl der Fragen ist zu niedrig.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Ergebnisse der App sind verständlich.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Ichfinde, die Informationen der App sind verständlich.<a name='_Hlk111533553'></a></span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>DieApp „Prevent-Take-Up“ hat meinen Kenntnisstand </span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>bei der Krebsvorsorgebzw. -früherkennung von Brust-, Darm- und Prostatakrebs verbessert.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>NachNutzung der App „Prevent-Take-Up“ fühle ich mich <br>gut über Krebsvorsorge bzw. -früherkennung von Brust-, Darm- und Prostatakrebsinformiert.</span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Durchdie Anwendung der „Prevent-Take-Up“-App möchte ich mehr über die Früherkennungund Vorsorge von Krebserkrankungen erfahren.<a name='_Hlk111533772'></a></span></p><p class=MsoListParagraphCxSpMiddle style='margin-top:2.9pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>Fallsdie „Prevent-Take-Up”-App Ihnen einen Arztbesuch empfohlen hat, werden Siedieser Empfehlung folgen und Ihre Ärztin/ Ihren Arzt zu einem Beratungsgesprächaufsuchen?</span></p><p class=MsoListParagraphCxSpLast style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:17.85pt;text-indent:-17.85pt;line-height:150%;background:white;text-autospace:none'><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>-<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif;color:black'>Offenes<b> </b>Feedback</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;line-height:150%;background:white;text-autospace:none'><b><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif'>&nbsp;</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;line-height:150%;background:white;text-autospace:none'><b><spanstyle='font-size:10.5pt;line-height:150%;font-family:'Corbel',sans-serif;color:black'>5. Speicherung von Alter, Geschlecht, Lebensstil-Faktoren</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Für die freiwillige Übermittlung der Daten aus4.2 ist die Eingabe von Alter, Geschlecht und Lebensstil-Faktoren erforderlich,da diese in die Auswertung mit einfließen, um ein exakteres Bild über die Nutzerschaftder App zu erhalten und zu erfahren, ob die Zielgruppe der App erreicht wurde.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>6. Datenweitergabe an Dritte</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>6.1 Die freiwillig und anonym übermitteltenDaten aus 4.2 werden von uns streng vertraulich behandelt und nicht an Dritteweitergegeben.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>6.2 Es werden keinerlei Daten anAnalysedienste wie Google Analytics oder soziale Plattformen wie z.B. Facebookübermittelt.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>7. Datensicherheit</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>7.1 Wir beschränken den Zugriff auf an uns freiwilligübermittelte anonyme Daten auf diejenigen Mitarbeiter, die den Zugriff für dieDienstleistungserbringung benötigen. Diese sind vertraglich auf die Einhaltungder gesetzlichen Datenschutzbestimmungen verpflichtet.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>7.2 Die App wurde vom Institut fürMedizinische Systembiologie der Universität Ulm, Albert-Einstein-Allee 11,89081 Ulm, entwickelt.</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>7.3 Um Ihre Daten zu schützen, wurdenumfangreiche technische und organisatorische Maßnahmen umgesetzt (z.B.Firewalls, Verschlüsselungs- und Authentifizierungstechniken,Verfahrensanweisungen).</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Das Recht, sich beim Datenschutzbeauftragtender Verantwortlichen (s.o.) oder bei der jeweiligen Aufsichtsbehörde (DerBundesbeauftragte für den Datenschutz und die Informationsfreiheit (BfDI),Graurheindorfer Str. 153 - 53117 Bonn, +49 (0)228-997799-0) zu beschweren.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Ich willige darin ein,</span></b></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>1. dass meine für den Zweck der Nutzung der PREVENT-TAKE-UP-Apperforderlichen, oben beschriebenen unter 4.2 freiwillig übermittelten anonymen Daten,erhoben, gespeichert, in der oben beschriebenen Form verarbeitet und mit denDaten der anderen App-Nutzer zusammen ausgewertet werden,</span></p><p class=MsoNormal style='margin-top:7.5pt;margin-right:0cm;margin-bottom:7.5pt;margin-left:0cm;background:white'><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>2. dass die Auswertungsergebnisse in anonymerForm, die keinen Rückschluss auf meine Person zulässt, veröffentlicht unddauerhaft in einer wissenschaftlichen Forschungsdatenbank gespeichert werden.</span></p><p class=MsoNormal style='background:white'><b><span style='font-size:10.5pt;font-family:'Corbel',sans-serif;color:black'>Hiermit willige ich die Nutzungmeiner Daten durch die Universität Ulm ein&nbsp;und, dass ich 18 Jahre oderälter bin.</span></b></p></div></body></html>"))))),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: EasyElevatedButton(
                        label: 'Impressum',
                        isRounded: true,
                        labelColor: Theme.of(context).colorScheme.primary,
                        color: Theme.of(context).bottomAppBarColor,
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => HTMLScreen(
                                    title: "Impressum",
                                    file:
                                        "<!DOCTYPE html><!--[if lt IE 7]><html class=no-js lt-ie9 lt-ie8 lt-ie7> <![endif]--><!--[if IE 7]> <html class=no-js lt-ie9 lt-ie8> <![endif]--><!--[if IE 8]> <html class=no-js lt-ie9> <![endif]--><!--[if gt IE 8]><html class=no-js> <!--<![endif]--><html><head><meta charset=utf-8><title>Impressum</title><link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet'><style>body {font-family: Raleway;font-size: larger;}.box {width: 90%;}img {max-width: 100%;height: auto;}</style></head><body><!--[if lt IE 7]><p class=browsehappy>You are using an <strong>outdated</strong> browser. Please <a href=#>upgrade your browser</a> to improve your experience.</p><![endif]--><p><b>Für den Inhalt und die Gestaltung ist verantwortlich:</b></p><p>Universität Ulm, KdöR, Helmholtzstr. 16, 89081 Ulm	Vertreten durch den Präsidenten Prof. Dr.-Ing. Michael Weber oder durch den Kanzler Dieter Kaufmann	<p>Telefon: +49 (0)731/50-10, Telefax: +49 (0)731/50-22038, Website: <a href= www.uni-ulm.de target=_blank> www.uni-ulm.de</a> Umsatzsteueridentifikationsnummer: DE173703203</p></&p><p><b>Zuständige Aufsichtsbehörde</b></p><p>Ministerium für Wissenschaft, Forschung und Kunst Baden-Württemberg</p><p>Königstraße 46, 70173 Stuttgart</p>	</body></html>")))),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          EasyElevatedButton(
                              label: 'WhatsApp',
                              labelColor: Theme.of(context).colorScheme.primary,
                              color: Theme.of(context).bottomAppBarColor,
                              icon: Image.asset(
                                "assets/icons/WhatsApp.png",
                                width: 20,
                                height: 20,
                              ),
                              isRounded: true,
                              onPressed: () => _launchURL(
                                  "https://api.whatsapp.com/send?text=Schau%20dir%20diese%20coole%20App%20an:%20https://wallis.informatik.uni-ulm.de/web/#/")),
                          EasyElevatedButton(
                              label: 'Twitter',
                              labelColor: Theme.of(context).colorScheme.primary,
                              color: Theme.of(context).bottomAppBarColor,
                              icon: Image.asset(
                                "assets/icons/Twitter.png",
                                width: 20,
                                height: 20,
                              ),
                              isRounded: true,
                              onPressed: () => _launchURL(
                                  "https://twitter.com/intent/tweet?text=Schau%20dir%20diese%20coole%20App%20an:%20https://wallis.informatik.uni-ulm.de/web/#/")),
                          EasyElevatedButton(
                              label: 'Mail',
                              labelColor: Theme.of(context).colorScheme.primary,
                              color: Theme.of(context).bottomAppBarColor,
                              icon: Image.asset("assets/icons/email.png",
                                  width: 20,
                                  height: 20,
                                  color: Theme.of(context).colorScheme.primary),
                              isRounded: true,
                              onPressed: () => _launchURL(
                                  "mailto:?subject=Schau%20dir%20diese%20coole%20App%20an;body=https://wallis.informatik.uni-ulm.de/web/#/")),
                        ])),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError ||
              (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == false)) {
            return AlertDialog(
              title: Text('Ooops something went wrong!'),
              actions: <Widget>[
                EasyElevatedButton(
                  label: 'Try Again',
                  onPressed: () => setState(() {
                    loadAllDataFuture = loadAllData();
                  }),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }
}

//add flag to determine if app was started for the first time or not
//if first time -> show mission statement
void setFirstStartFlag() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool('afterFirstStart', true);
}

Future<bool> getFirstStartFlag() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  //check if app was opened before via persistent settings
  bool boolValue = pref.getBool('afterFirstStart') ??
      false; //if value is not present -> set false
  return boolValue;
}

_launchURL(String launchURL) async {
  final uri = Uri.parse(launchURL);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $launchURL';
  }
}
