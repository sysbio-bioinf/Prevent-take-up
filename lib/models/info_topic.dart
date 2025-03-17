import 'package:meta/meta.dart';

class InfoTopic {
  final String name;
  final String text;
  final String file;
  final Map<String, String> urls;

  InfoTopic(
      {required this.name,
      required this.text,
      required this.file,
      required this.urls});

  factory InfoTopic.fromJson(Map<String, dynamic> json) {
    Map<String, String> collectedLinkNames = Map<String, String>();

    if (json['links'] != null)
      for (int i = 0; i < json['links'].length; i++) {
        collectedLinkNames
            .addAll({json['links'][i]['display']: json['links'][i]['url']});
      }

    return InfoTopic(
        name: json['name'],
        text: json['text'],
        file: json['file'],
        urls: collectedLinkNames);
  }
}
