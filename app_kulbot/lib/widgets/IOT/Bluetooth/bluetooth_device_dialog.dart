import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'bluetooth_service.dart';
import 'dart:convert';
import 'dart:async';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service xử lý logic Bluetooth: scan, connect, gửi/nhận dữ liệu.
class AppBluetoothService {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _characteristic;

  final List<ScanResult> scanResults = [];
  final StreamController<Map<String, String>> _dataController =
      StreamController.broadcast();
  Stream<Map<String, String>> get dataStream => _dataController.stream;

  /// Gọi một lần duy nhất để xin quyền truy cập.
  static Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  /// Kiểm tra Bluetooth đã bật chưa.
  Future<bool> isBluetoothOn() async {
    return await FlutterBluePlus.isOn;
  }

  /// Bắt đầu quét thiết bị
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    scanResults.clear();
    FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Dừng quét
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Lắng nghe kết quả quét
  void initializeScanListener() {
    FlutterBluePlus.scanResults.listen((results) {
      scanResults
        ..clear()
        ..addAll(results);
    });
  }

  /// Kết nối tới thiết bị và nhận dữ liệu notify
  Future<void> connectToDevice(BluetoothDevice device) async {
    await stopScan();
    connectedDevice = device;

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      debugPrint("Kết nối thất bại: $e");
    }

    final services = await device.discoverServices();
    for (var service in services) {
      for (var c in service.characteristics) {
        if (c.properties.notify) {
          _characteristic = c;
          await c.setNotifyValue(true);
          c.lastValueStream.listen(_onDataReceived);
          return;
        }
      }
    }
  }

  void _onDataReceived(List<int> data) {
    try {
      final text = utf8.decode(data);
      final items = text.split(';');

      final Map<String, String> parsed = {};
      for (var item in items) {
        final parts = item.split(':');
        if (parts.length == 2) {
          parsed[parts[0]] = parts[1];
          debugPrint("Data: ${parts[0]} => ${parts[1]}");
        }
      }
      _dataController.add(parsed);
    } catch (e) {
      debugPrint("Lỗi phân tích dữ liệu: $e");
    }
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    _characteristic = null;
  }

  Future<void> sendMessage(String message) async {
    if (_characteristic?.properties.write ?? false) {
      await _characteristic!.write(utf8.encode(message));
    }
  }

  /// Ghi nhớ thiết bị đã kết nối (option mở rộng)
  Future<void> saveLastDeviceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_device_id", id);
  }

  Future<String?> getLastDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_device_id");
  }
}

class BluetoothDeviceDialog extends StatefulWidget {
  final AppBluetoothService bluetoothService;
  final VoidCallback? onConnected;

  const BluetoothDeviceDialog({
    super.key,
    required this.bluetoothService,
    this.onConnected,
  });

  @override
  State<BluetoothDeviceDialog> createState() => _BluetoothDeviceDialogState();
}

class _BluetoothDeviceDialogState extends State<BluetoothDeviceDialog> {
  bool isScanning = false;
  String statusMessage = "Đang khởi tạo Bluetooth...";

  @override
  void initState() {
    super.initState();
    _handleBluetoothSetup();
  }

  /// Xử lý xin quyền và kiểm tra Bluetooth
  Future<void> _handleBluetoothSetup() async {
    await AppBluetoothService.requestPermissions();
    final isOn = await widget.bluetoothService.isBluetoothOn();

    if (!isOn) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Bluetooth chưa bật"),
              content: Text("Vui lòng bật Bluetooth và thử lại."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      if (mounted) Navigator.of(context).pop(); // Thoát khỏi dialog luôn
      return;
    }

    widget.bluetoothService.initializeScanListener();
    await _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      isScanning = true;
      statusMessage = "Đang tìm thiết bị...";
    });
    await widget.bluetoothService.startScan(timeout: Duration(seconds: 5));
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      isScanning = false;
      statusMessage = "Chọn thiết bị để kết nối";
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => statusMessage = "Đang kết nối tới ${device.name}...");
    await widget.bluetoothService.connectToDevice(device);
    await widget.bluetoothService.saveLastDeviceId(device.id.toString());

    widget.onConnected?.call();
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _resetConnection() async {
    await widget.bluetoothService.disconnect();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đã ngắt kết nối")));
    setState(() => statusMessage = "Đã reset. Bạn có thể kết nối lại.");
  }

  @override
  Widget build(BuildContext context) {
    final devices = widget.bluetoothService.scanResults;

    return AlertDialog(
      title: Text("Thiết bị Bluetooth"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(statusMessage),
          SizedBox(height: 12),
          if (devices.isEmpty)
            Text("Không tìm thấy thiết bị nào.")
          else
            ...devices.map(
              (result) => ListTile(
                title: Text(
                  result.device.name.isNotEmpty
                      ? result.device.name
                      : result.device.id.toString(),
                ),
                subtitle: Text(result.device.id.toString()),
                onTap: () => _connectToDevice(result.device),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: _resetConnection, child: Text("Reset")),
        TextButton(
          onPressed: isScanning ? null : _startScan,
          child: Text("Tìm lại"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Đóng"),
        ),
      ],
    );
  }
}
