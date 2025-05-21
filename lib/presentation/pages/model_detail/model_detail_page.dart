import 'package:flutter/material.dart';
import 'package:chat_me/core/services/llm_loader.dart';
import 'package:chat_me/data/models/llm_models.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // jika belum import
import 'package:dio/dio.dart';

class ModelDetailPage extends StatefulWidget {
  final String modelId;

  const ModelDetailPage({super.key, required this.modelId});

  @override
  State<ModelDetailPage> createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage> {
  late Future<Map<String, dynamic>> _modelFuture;

  @override
  void initState() {
    super.initState();
    _modelFuture = _loadModelAndStatus();
  }

  Future<Map<String, dynamic>> _loadModelAndStatus() async {
    final models = await LlmLoader.loadModels();
    final model = models.firstWhere((m) => m.id == widget.modelId);
    final downloaded = await isModelDownloaded(model);
    return {'model': model, 'downloaded': downloaded};
  }

  Future<bool> isModelDownloaded(LlmModel model) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = model.downloadUrl.split('/').last;
    final file = File('${dir.path}/models/$filename');
    return file.exists();
  }

  Future<void> deleteModelFile(LlmModel model) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = model.downloadUrl.split('/').last;
    final file = File('${dir.path}/models/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> downloadModel(
    LlmModel model,
    void Function(int received, int total) onReceiveProgress,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/models');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    // Ambil nama file asli dari URL
    final filename = model.downloadUrl.split('/').last;
    final savePath = '${modelDir.path}/$filename';

    final dio = Dio();

    int totalSize = 0;
    try {
      final headResponse = await dio.head(
        model.downloadUrl,
        options: Options(followRedirects: true),
      );

      totalSize =
          int.tryParse(headResponse.headers.value('content-length') ?? '0') ??
          0;

      print('Ukuran file: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
    } catch (e) {
      print('Gagal mendapatkan ukuran file: $e');
    }

    await dio.download(
      model.downloadUrl,
      savePath,
      onReceiveProgress: (received, total) {
        int totalToUse = total > 0 ? total : totalSize;

        final percent =
            totalToUse > 0
                ? ((received / totalToUse) * 100).toStringAsFixed(1)
                : "??";

        final receivedMb = (received / 1024 / 1024).toStringAsFixed(2);
        final totalMb = (totalToUse / 1024 / 1024).toStringAsFixed(2);

        print('Progress: $percent% ($receivedMb MB / $totalMb MB)');
        onReceiveProgress(received, totalToUse);
      },
      options: Options(followRedirects: true, responseType: ResponseType.bytes),
    );
  }

  String formatSize(int sizeMb) {
    if (sizeMb < 1024) {
      return '$sizeMb MB';
    } else if (sizeMb < 10240) {
      // kurang dari 10 GB, tampilkan 2 desimal
      return '${(sizeMb / 1024).toStringAsFixed(2)} GB';
    } else {
      return '${(sizeMb / 1024).toStringAsFixed(1)} GB'; // untuk ukuran sangat besar pakai 1 desimal saja
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Model')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _modelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Model tidak ditemukan'));
          }

          final model = snapshot.data!['model'] as LlmModel;
          final isDownloaded = snapshot.data!['downloaded'] as bool;

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
                Text('Ukuran: ${formatSize(model.sizeMb)}'),
                Text('RAM: ${formatSize(model.requiredRamMb)}'),
                Text('Deskripsi: ${model.description}'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed:
                            isDownloaded
                                ? null
                                : () async {
                                  final progressNotifier =
                                      ValueNotifier<Map<String, int>>({
                                        'received': 0,
                                        'total': 0,
                                      });

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: ValueListenableBuilder<
                                          Map<String, int>
                                        >(
                                          valueListenable: progressNotifier,
                                          builder: (context, value, _) {
                                            final received = value['received']!;
                                            final total = value['total']!;
                                            final progressValue =
                                                total > 0
                                                    ? received / total
                                                    : null;

                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Mengunduh model...',
                                                ),
                                                const SizedBox(height: 16),
                                                LinearProgressIndicator(
                                                  value: progressValue,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${(received / 1024 / 1024).toStringAsFixed(2)} MB dari ${(total / 1024 / 1024).toStringAsFixed(2)} MB',
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );

                                  try {
                                    await downloadModel(model, (
                                      received,
                                      total,
                                    ) {
                                      progressNotifier.value = {
                                        'received': received,
                                        'total': total,
                                      };
                                    });

                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Download selesai'),
                                      ),
                                    );
                                    setState(() {
                                      _modelFuture = _loadModelAndStatus();
                                    });
                                  } catch (e) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal mengunduh: $e'),
                                      ),
                                    );
                                  }
                                },
                      ),
                    ),
                    if (isDownloaded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          onPressed: () async {
                            await deleteModelFile(model);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Model dihapus')),
                            );
                            // Refresh UI
                            setState(() {
                              _modelFuture = _loadModelAndStatus();
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
