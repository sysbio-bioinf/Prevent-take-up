import 'package:flutter/material.dart';
import 'package:easy_actions/easy_actions.dart';

class AboutScreen extends StatefulWidget {
  final Map<String, String> abouts;

  AboutScreen({required this.abouts});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Map<String, String> get abouts => widget.abouts;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Über diese App',
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
              child: Column(
            children: <Widget>[
              for (MapEntry<String, String> entry in abouts.entries)
                Container(
                    margin: EdgeInsets.all(10),
                    child: EasyElevatedButton(
                        label: entry.key,
                        isRounded: true,
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(
                                        entry.key,
                                      ),
                                    ),
                                    body: Center(
                                        child: Container(
                                            padding: EdgeInsets.all(15),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 10,
                                                    right: 10,
                                                    bottom: 10),
                                                child:
                                                    Column(children: <Widget>[
                                                  Container(
                                                    child: RichText(
                                                        text: TextSpan(
                                                            text: entry.value)),
                                                  )
                                                ]))))))))),
              Image(image: AssetImage("assets/images/ce-zei.png"), width: 40)
            ],
          ));
        }));
  }
}
