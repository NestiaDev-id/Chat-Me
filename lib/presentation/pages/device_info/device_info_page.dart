import 'package:flutter/material.dart';
import 'package:chat_me/core/services/device_info_service.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  int? _ramMb;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final ram = await _deviceInfoService.getTotalRamMB();
    setState(() {
      _ramMb = ram;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Perangkat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _ramMb == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RAM tersedia: ${(_ramMb! / 1024).toStringAsFixed(2)} GB'),
                  // Tambahkan info storage jika ada
                  const SizedBox(height: 10),
                  const Text('Storage info akan ditambahkan...'),
                ],
              ),
      ),
    );
  }
}
