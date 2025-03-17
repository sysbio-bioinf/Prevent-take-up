import 'package:questionnaires/configs/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> sendPostRequest(Map<String, dynamic> answers) {
  Map<String, dynamic> dat = {'data': answers};

  print(jsonEncode(dat));

  return http.post(Uri.parse(Constants.BACKEND_URL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': '*'
      },
      body: jsonEncode(dat));
}
