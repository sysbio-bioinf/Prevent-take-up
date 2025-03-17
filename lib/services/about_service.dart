import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:questionnaires/enums/about_type.dart';

class AboutService {
  String? _getAboutAssetPath(AboutType aboutType) {
    switch (aboutType) {
      case AboutType.disclaimer:
        return 'assets/about/disclaimer.json';
      case AboutType.appVersion:
        return 'assets/about/app_version.json';
      default:
        return null;
    }
  }

  Future<Map<String, String>> getAbout(AboutType aboutType) async {
    final assetPath = _getAboutAssetPath(aboutType);
    final jsonData = await rootBundle.loadString(assetPath!);
    final jsonDataDecoded = jsonDecode(jsonData);
    return {jsonDataDecoded['name']: jsonDataDecoded['text']};
  }
}
