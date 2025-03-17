import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:questionnaires/enums/info_type.dart';
import 'package:questionnaires/models/info_topic.dart';
import 'package:questionnaires/models/infos.dart';
import 'package:questionnaires/screens/html_screen.dart';
import 'package:questionnaires/screens/info_screen.dart';
import 'package:questionnaires/services/info_service.dart';
import 'package:questionnaires/widgets/button.dart';
import 'package:easy_actions/easy_actions.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecInfoScreen extends StatefulWidget {
  final Info info;

  SpecInfoScreen({required this.info});

  @override
  _SpecInfoScreenState createState() => _SpecInfoScreenState();
}

class _SpecInfoScreenState extends State<SpecInfoScreen> {
  Info get info => widget.info;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            info.name,
          ),
        ),
        body: Center(
            child: Column(children: <Widget>[
          for (InfoTopic topic in info.infoTopics)
            Container(
                margin: EdgeInsets.all(15.0),
                child: EasyElevatedButton(
                    label: topic.name,
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HTMLScreen(
                                title: topic.name, file: topic.file)))))
        ])));
  }
}
