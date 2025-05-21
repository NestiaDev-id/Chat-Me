import 'package:chat_me/core/services/llm_loader.dart';
import 'package:chat_me/data/models/llm_models.dart';
import 'package:chat_me/presentation/pages/device_info/device_info_page.dart';
import 'package:chat_me/presentation/pages/model_detail/model_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/presentation/pages/chat/chat_page.dart';

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

  @override
  void initState() {
    super.initState();
    _modelsFuture = LlmLoader.loadModels();
  }

  Future<String> runPromptDummy(String prompt) async {
    await Future.delayed(Duration(seconds: 1)); // simulasi loading
    return 'Ini jawaban untuk: "$prompt"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat LLM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline), // icon tanda tanya
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
            return Center(child: Text('Gagal memuat model: ${snapshot.error}'));
          }

          final models = snapshot.data ?? [];
          if (models.isEmpty) {
            return const Center(child: Text('Tidak ada model tersedia'));
          }

          _selectedModel ??= models.first;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<LlmModel>(
                        value: _selectedModel,
                        isExpanded: true,
                        items:
                            models.map((model) {
                              return DropdownMenuItem(
                                value: model,
                                child: Text(
                                  '${model.name} - ${(model.sizeMb / 1024).toStringAsFixed(2)} GB',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (model) {
                          setState(() {
                            _selectedModel = model;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Pilih Model LLM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ModelDetailPage(
                                  modelId: _selectedModel!.id,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    ),
                  ),
                ],
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
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        // TODO: implement file picker
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        // TODO: implement voice recording
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis pertanyaan atau prompt kamu...',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final prompt = _promptController.text.trim();
                        if (prompt.isNotEmpty) {
                          setState(() {
                            _chatMessages.add(
                              ChatMessage(text: prompt, isUser: true),
                            );
                          });

                          _promptController.clear();

                          final response = await runPromptDummy(prompt);

                          setState(() {
                            _chatMessages.add(
                              ChatMessage(text: response, isUser: false),
                            );
                          });
                        }
                      },
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
