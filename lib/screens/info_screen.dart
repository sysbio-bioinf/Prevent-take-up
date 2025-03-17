import 'package:flutter/material.dart';
import 'package:questionnaires/enums/info_type.dart';
import 'package:questionnaires/models/infos.dart';
import 'package:questionnaires/screens/info_screen.dart';
import 'package:questionnaires/screens/spec_info_screen.dart';
import 'package:questionnaires/services/info_service.dart';
import 'package:questionnaires/widgets/button.dart';
import 'package:easy_actions/easy_actions.dart';

class InfoScreen extends StatefulWidget {
  final List<Info> infos;

  InfoScreen({required this.infos});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<Info> get infos => widget.infos;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(infos);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informationen zur Vorsorge',
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Column(
              children: <Widget>[
                for (Info info in infos)
                  Container(
                      margin: EdgeInsets.all(15.0),
                      child: EasyElevatedButton(
                        label: info.name,
                        isRounded: true,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SpecInfoScreen(
                              info: info,
                            ),
                          ),
                        ),
                      ))
              ],
            ),
          );
        },
      ),
    );
  }
}
