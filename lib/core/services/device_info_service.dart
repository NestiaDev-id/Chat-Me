import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<int> getTotalRamMB() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // Pastikan pakai totalRam bukan totalMemory
      return (androidInfo.systemFeatures.length * 100) ~/ (1024); // dummy logic
    } catch (e) {
      return 0; // fallback
    }
  }

  // Tambahkan fungsi lain misal getFreeStorageMB, dll (pakai package lain)
}
