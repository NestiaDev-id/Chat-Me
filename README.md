# 🤖 AI ChatBot Offline - Flutter

ChatBot berbasis AI yang dapat berjalan **sepenuhnya offline**, terinspirasi oleh ChatGPT dan Apple iPad-style UX. Pengguna dapat memilih dan mengunduh model LLM dari berbagai pilihan (TinyLLaMA, Mistral, LLaMA 2, dll), lalu melakukan percakapan tanpa koneksi internet.

---

## 🚀 Fitur Utama

- ✅ Pilih dan unduh model LLM sesuai kebutuhan & RAM perangkat
- ✅ Deteksi RAM dan storage perangkat (Android/iOS)
- ✅ Chat offline setelah model diunduh (tanpa koneksi internet)
- ✅ UI interaktif dan ringan
- ✅ Support multi-model (.gguf format, quantized)

---

## 📁 Struktur Folder

```bash
lib/
│
├── main.dart
├── app/
│   └── router.dart
│
├── core/
│   ├── constants/
│   ├── utils/
│   └── services/
│       ├── device_info_service.dart       # RAM, storage info
│       ├── llm_downloader.dart            # Download model
│       ├── llm_loader.dart                # Load model from disk
│       └── llm_inference_service.dart     # Inference dari local model
│
├── data/
│   ├── models/
│       └── llm_model.dart
│   ├── repositories/
│   └── data_sources/
│       └── local_model_storage.dart       # Path & file manager
│
├── domain/
│   └── usecases/
│       └── chat_with_model.dart           # Kirim prompt, terima respons
│
├── presentation/
│   ├── pages/
│   │   ├── home/
│   │   ├── model_detail/
│   │   ├── device_info/
│   │   └── chat/
│   ├── widgets/
│   └── state/
│       └── llm_provider.dart              # State current model, chat history
│
└── config/
    └── llm_config.json

```

---

## 📦 Model Support

Model disimpan dalam format `.gguf` dan dapat diunduh dari Hugging Face:

- ✅ TinyLLaMA 1.1B
- ✅ Phi-1.5 (2.7B)
- ✅ Mistral 7B
- ✅ OpenHermes 2.5
- ✅ LLaMA 2 (7B & 13B)
- ✅ Zephyr 7B Beta
- ✅ Mixtral 8x7B MoE

Semua model tersedia dalam versi `quantized (Q4_K_M)` agar ringan dan efisien.

---

## 📥 Contoh `llm_config.json`

```json
[
  {
    "id": "mistral",
    "name": "Mistral 7B",
    "size_mb": 4200,
    "required_ram_mb": 6500,
    "description": "Efficient general-purpose model.",
    "download_url": "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf"
  }
]
```

## 🛠️ Teknologi yang Digunakan

- Flutter (cross-platform)
- Dart
- Riverpod / Provider (state management)
- Dio (unduh model dengan progress)
- Path Provider (akses direktori lokal)
- Device Info Plus (deteksi RAM / storage)

## 🧠 Roadmap Selanjutnya

- Support multiple chat sessions
- Mode suara ke teks (STT)
- UI seperti ChatGPT 4.0 (carousel, prompt suggestion)
- Benchmark skor model di perangkat user

## 👨‍💻 Kontribusi

Pull request dan feedback sangat disambut!
