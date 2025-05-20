import 'package:flutter/material.dart';
import 'package:chat_me/core/services/llm_loader.dart';
import 'package:chat_me/data/models/llm_models.dart';
import 'package:go_router/go_router.dart';

class ModelDetailPage extends StatefulWidget {
  final String modelId;

  const ModelDetailPage({super.key, required this.modelId});

  @override
  State<ModelDetailPage> createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage> {
  late Future<LlmModel?> _modelFuture;

  @override
  void initState() {
    super.initState();
    _modelFuture = _loadSelectedModel();
  }

  Future<LlmModel?> _loadSelectedModel() async {
    final models = await LlmLoader.loadModels();
    try {
      return models.firstWhere((model) => model.id == widget.modelId);
    } catch (e) {
      return null; // Model tidak ditemukan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Model')),
      body: FutureBuilder<LlmModel?>(
        future: _modelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Model tidak ditemukan'));
          }

          final model = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ukuran model: ${(model.sizeMb / 1024).toStringAsFixed(2)} GB',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'RAM diperlukan: ${(model.requiredRamMb / 1024).toStringAsFixed(2)} GB',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  model.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Model'),
                    onPressed: () {
                      // TODO: Panggil fungsi download model (llm_downloader)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fungsi download belum tersedia'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
