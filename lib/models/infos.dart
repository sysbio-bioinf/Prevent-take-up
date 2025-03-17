import 'package:meta/meta.dart';

import 'info_topic.dart';

class Info {
  final String name;
  final List<InfoTopic> infoTopics;

  Info({required this.name, required this.infoTopics});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
        name: json['name'],
        infoTopics: List<InfoTopic>.from(
            json['topics'].map((x) => InfoTopic.fromJson(x))));
  }
}
