import 'package:llama_cpp/llama_cpp.dart';

class LlmExecutor {
  static LlamaContext? _context;

  static Future<void> loadModel(String modelPath) async {
    final model = await LlamaModel.fromFile(path: modelPath);
    _context = await LlamaContext.create(model: model);
  }

  static Future<String> sendPrompt(String prompt) async {
    if (_context == null) {
      throw Exception('Model belum diload');
    }

    final response = await _context!.complete(
      prompt: prompt,
      maxTokens: 200,
      temperature: 0.7,
      topP: 0.9,
    );
    return response.text;
  }
}
