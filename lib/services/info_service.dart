import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:questionnaires/enums/info_type.dart';
import 'package:questionnaires/models/infos.dart';

class InfoService {
  String? _getInfoAssetPath(InfoType infoType) {
    switch (infoType) {
      case InfoType.colon:
        return 'assets/infos/colon.json';
      case InfoType.prostate:
        return 'assets/infos/prostate.json';
      case InfoType.breast:
        return 'assets/infos/breast.json';
      default:
        return null;
    }
  }

  Future<Info> getInfo(InfoType infoType) async {
    final assetPath = _getInfoAssetPath(infoType);
    final jsonData = await rootBundle.loadString(assetPath!);
    final jsonDataDecoded = jsonDecode(jsonData);
    return Info.fromJson(jsonDataDecoded);
  }
}
