import 'package:llama_cpp/llama_cpp.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LlmExecutor {
  static LlamaCpp? _llamaCppInstance; // Change from LlamaContext to LlamaCpp
  static String? _loadedModelId; // To keep track of the currently loaded model

  // Load the model from the local path
  static Future<void> loadModel(String modelId, String modelFileName) async {
    if (_loadedModelId == modelId && _llamaCppInstance != null) {
      print('Model $modelId already loaded.');
      return; // Model is already loaded, no need to load again
    }

    // Dispose of the previous context if a different model was loaded
    if (_llamaCppInstance != null) {
      await _llamaCppInstance!.dispose(); // Use await for dispose
      _llamaCppInstance = null;
      _loadedModelId = null;
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDocDir.path}/models/$modelFileName';
      print('Attempting to load model from: $modelPath');

      if (!await File(modelPath).exists()) {
        throw Exception('Model file not found at $modelPath');
      }

      // Use LlamaCpp.load instead of LlamaModel.fromFile and LlamaContext.create
      _llamaCppInstance = await LlamaCpp.load(modelPath); // Removed 'path:'
      _loadedModelId = modelId;
      print('Model $modelId loaded successfully!');
    } catch (e) {
      print('Error loading model: $e');
      rethrow; // Rethrow the exception so the UI can handle it
    }
  }

  // Send a prompt to the loaded model
  static Future<String> sendPrompt(String prompt) async {
    if (_llamaCppInstance == null) {
      throw Exception('Model has not been loaded. Please load a model first.');
    }

    try {
      // Use _llamaCppInstance.answer to get the response
      final responseStream = _llamaCppInstance!.answer(
        prompt,
        temperature: 0.7,
        topP: 0.9,
      );
      String fullResponse = '';
      await for (final chunk in responseStream) {
        fullResponse += chunk;
      }
      return fullResponse;
    } catch (e) {
      print('Error during inference: $e');
      return 'Error generating response: $e';
    }
  }

  // Dispose of the context when no longer needed (e.g., when app closes or model changes)
  static void dispose() {
    _llamaCppInstance?.dispose();
    _llamaCppInstance = null;
    _loadedModelId = null;
    print('LlamaCpp instance disposed.');
  }
}
