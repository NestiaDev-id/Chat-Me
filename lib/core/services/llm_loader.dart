import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:chat_me/data/models/llm_model.dart';

class LlmLoader {
  static Future<List<LlmModel>> loadModels() async {
    final String jsonString = await rootBundle.loadString('config/llm_config.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((e) => LlmModel.fromJson(e)).toList();
  }
}
