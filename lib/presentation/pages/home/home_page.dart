import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedModel = 'Model A'; // Contoh default
  List<String> _models = ['Model A', 'Model B', 'Model C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat LLM'),
        actions: [
          // Dropdown untuk ganti model
          DropdownButton<String>(
            value: _selectedModel,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            dropdownColor: Colors.blue[800], // warna biru lebih gelap
            underline: Container(), // hilangkan garis bawah
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedModel = value;
                });
              }
            },
            items:
                _models.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(
                      model,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              // Nanti bisa tambahkan chat messages di sini
              color: Colors.grey[200],
              child: Center(child: Text('Chat messages appear here')),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Tombol upload
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
                  onPressed: () {
                    final prompt = _promptController.text.trim();
                    if (prompt.isNotEmpty) {
                      // TODO: kirim prompt ke backend / LLM
                      _promptController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
