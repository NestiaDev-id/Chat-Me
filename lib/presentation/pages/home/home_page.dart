import 'package:chat_me/core/services/llm_loader.dart';
import 'package:chat_me/data/models/llm_models.dart';
import 'package:chat_me/presentation/pages/device_info/device_info_page.dart';
import 'package:chat_me/presentation/pages/model_detail/model_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/presentation/pages/chat/chat_page.dart';
import 'package:chat_me/core/services/llm_executor.dart'; // Import LlmExecutor
import 'package:path_provider/path_provider.dart'; // For getting model file path
import 'dart:io'; // For checking file existence

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _promptController = TextEditingController();
  late Future<List<LlmModel>> _modelsFuture;
  LlmModel? _selectedModel;
  final List<ChatMessage> _chatMessages = [];
  bool _isLoadingModel = false; // New state to manage model loading
  String _modelLoadingMessage = ''; // Message for model loading status

  @override
  void initState() {
    super.initState();
    _modelsFuture = LlmLoader.loadModels().then((models) {
      if (models.isNotEmpty) {
        _selectedModel = models.first;
        _checkAndLoadModel(_selectedModel!); // Attempt to load default model
      }
      return models;
    });
  }

  // Function to check if model is downloaded and load it
  Future<void> _checkAndLoadModel(LlmModel model) async {
    setState(() {
      _isLoadingModel = true;
      _modelLoadingMessage = 'Checking model status...';
    });
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final modelFileName = model.downloadUrl.split('/').last;
      final modelPath = '${appDocDir.path}/models/$modelFileName';
      final fileExists = await File(modelPath).exists();

      if (fileExists) {
        setState(() {
          _modelLoadingMessage = 'Loading model...';
        });
        await LlmExecutor.loadModel(model.id, modelFileName);
        setState(() {
          _isLoadingModel = false;
          _modelLoadingMessage = 'Model loaded successfully!';
        });
      } else {
        setState(() {
          _isLoadingModel = false;
          _modelLoadingMessage = 'Model not downloaded. Please download it.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingModel = false;
        _modelLoadingMessage = 'Error loading model: $e';
      });
      print('Error checking/loading model: $e');
    }
  }

  String formatSize(int sizeMb) {
    if (sizeMb < 1024) {
      return '$sizeMb MB';
    } else if (sizeMb < 10240) {
      return '${(sizeMb / 1024).toStringAsFixed(2)} GB';
    } else {
      return '${(sizeMb / 1024).toStringAsFixed(1)} GB';
    }
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      return;
    }

    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a model first.')),
      );
      return;
    }

    if (_isLoadingModel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is still loading. Please wait.')),
      );
      return;
    }

    setState(() {
      _chatMessages.add(ChatMessage(text: prompt, isUser: true));
    });

    _promptController.clear();

    // Call the LLM executor
    try {
      final response = await LlmExecutor.sendPrompt(prompt);
      setState(() {
        _chatMessages.add(ChatMessage(text: response, isUser: false));
      });
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(text: 'Error: $e', isUser: false));
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating response: $e')));
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    LlmExecutor.dispose(); // Dispose LLM context when Home page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat LLM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeviceInfoPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<LlmModel>>(
        future: _modelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load models: ${snapshot.error}'),
            );
          }

          final models = snapshot.data ?? [];
          if (models.isEmpty) {
            return const Center(child: Text('No models available'));
          }

          _selectedModel ??= models.first;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<LlmModel>(
                      value: _selectedModel,
                      isExpanded: true,
                      items:
                          models.map((model) {
                            return DropdownMenuItem(
                              value: model,
                              child: Text(
                                '${model.name} - ${formatSize(model.sizeMb)} | RAM: ${formatSize(model.requiredRamMb)}',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (model) {
                        setState(() {
                          _selectedModel = model;
                          _chatMessages
                              .clear(); // Clear chat when model changes
                          _checkAndLoadModel(
                            model!,
                          ); // Load the newly selected model
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select LLM Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingModel || _modelLoadingMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child:
                            _isLoadingModel
                                ? const LinearProgressIndicator()
                                : const SizedBox.shrink(), // Hide if not loading
                      ),
                    Text(
                      _modelLoadingMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _modelLoadingMessage.contains('Error')
                                ? Colors.red
                                : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          // Pass the selected model ID to the detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ModelDetailPage(
                                    modelId: _selectedModel!.id,
                                  ),
                            ),
                          ).then((_) {
                            // After returning from ModelDetailPage, re-check and load the model
                            if (_selectedModel != null) {
                              _checkAndLoadModel(_selectedModel!);
                            }
                          });
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download / Manage Model'),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: ChatMessagesWidget(messages: _chatMessages),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.attach_file),
                    //   onPressed: () {
                    //     // TODO: implement file picker
                    //   },
                    // ),
                    // IconButton(
                    //   icon: const Icon(Icons.mic),
                    //   onPressed: () {
                    //     // TODO: implement voice recording
                    //   },
                    // ),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          hintText: 'Type your question or prompt...',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed:
                          _isLoadingModel
                              ? null
                              : _sendPrompt, // Disable send button while loading model
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
