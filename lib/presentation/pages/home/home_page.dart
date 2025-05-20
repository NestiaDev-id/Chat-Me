import 'package:flutter/material.dart';
import 'package:chat_me/core/services/llm_loader.dart';
import 'package:chat_me/data/models/llm_model.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<LlmModel>> _modelsFuture;

  @override
  void initState() {
    super.initState();
    _modelsFuture = LlmLoader.loadModels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Model LLM'),
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

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(model.name),
                  subtitle: Text(
                    '${(model.sizeMb / 1024).toStringAsFixed(2)} GB - RAM req: ${(model.requiredRamMb / 1024).toStringAsFixed(2)} GB',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigasi ke halaman model detail, kirim id model sebagai param
                    // context.goNamed('model_detail', queryParams: {'id': model.id});
                    context.goNamed('model_detail', extra: model.id);

                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
