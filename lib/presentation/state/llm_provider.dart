import 'package:flutter/foundation.dart';
import 'package:chat_me/data/models/llm_model.dart';

class LlmProvider with ChangeNotifier {
  List<LlmModel> _availableModels = [];
  LlmModel? _selectedModel;

  List<LlmModel> get availableModels => _availableModels;
  LlmModel? get selectedModel => _selectedModel;

  void setModels(List<LlmModel> models) {
    _availableModels = models;
    notifyListeners();
  }

  void selectModel(LlmModel model) {
    _selectedModel = model;
    notifyListeners();
  }
}
