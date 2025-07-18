import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

Future<BluetoothDevice?> showBluetoothScanDialog(BuildContext context) async {
  return showDialog<BluetoothDevice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _BluetoothScanDialog(),
  );
}

class _BluetoothScanDialog extends StatefulWidget {
  const _BluetoothScanDialog({super.key});

  @override
  State<_BluetoothScanDialog> createState() => _BluetoothScanDialogState();
}

class _BluetoothScanDialogState extends State<_BluetoothScanDialog> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  final Guid writeCharUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) setState(() => _scanResults = results);
    }, onError: (e) => print("Scan error: $e"));

    _isScanningSubscription = FlutterBluePlus.isScanning.listen(
      (state) => setState(() => _isScanning = state),
    );

    // Gọi xin quyền và quét ngay sau đó
    Future.microtask(() async {
      final ok = await checkBluetoothAndLocation(context);
      if (!ok) return; // Không đủ điều kiện thì dừng

      await _requestBluetoothPermissions(); // xin quyền nếu chưa có
      await _startScan(); // tiến hành quét
    });
  }

  Future<void> _requestBluetoothPermissions() async {
    try {
      // Kiểm tra và bật dịch vụ vị trí (location services)
      bool locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationEnabled) {
        await Geolocator.openLocationSettings(); // mở cài đặt location cho user
        throw Exception("Dịch vụ vị trí (GPS) đang tắt.");
      }

      // Xin quyền BLUETOOTH_SCAN + CONNECT (Android 12+)
      if (await Permission.bluetoothScan.request().isDenied ||
          await Permission.bluetoothConnect.request().isDenied) {
        throw Exception("Không được cấp quyền Bluetooth.");
      }

      // Xin quyền ACCESS_FINE_LOCATION (Android <=11)
      if (await Permission.location.request().isDenied) {
        throw Exception("Không được cấp quyền vị trí.");
      }
    } catch (e) {
      debugPrint("Lỗi khi xin quyền Bluetooth: $e");
    }
  }

  Future<bool> checkBluetoothAndLocation(BuildContext context) async {
    bool isBluetoothOn = await FlutterBluePlus.isOn;
    bool isLocationOn = await Geolocator.isLocationServiceEnabled();

    // Nếu cả 2 đều bật thì OK
    if (isBluetoothOn && isLocationOn) return true;

    // Hiện dialog nếu thiếu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Cần quyền để tiếp tục"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isBluetoothOn)
                    const ListTile(
                      leading: Icon(Icons.bluetooth_disabled),
                      title: Text("Bluetooth chưa bật"),
                    ),
                  if (!isLocationOn)
                    const ListTile(
                      leading: Icon(Icons.location_off),
                      title: Text("Dịch vụ vị trí (GPS) chưa bật"),
                    ),
                ],
              ),
            ),
            actions: [
              if (!isBluetoothOn)
                TextButton(
                  onPressed: () async {
                    await FlutterBluePlus.turnOn(); // Android sẽ mở Bluetooth settings
                  },
                  child: const Text("Bật Bluetooth"),
                ),
              if (!isLocationOn)
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings(); // Mở settings location
                  },
                  child: const Text("Bật Vị trí"),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Đóng"),
              ),
            ],
          ),
    );

    return false;
  }

  Future<void> _startScan() async {
    // Nếu đang quét, phải dừng rồi chờ hẳn dừng
    Future.microtask(() async {
      final ok = await checkBluetoothAndLocation(context);
      if (!ok) return; // Không đủ điều kiện thì dừng

      await _requestBluetoothPermissions(); // xin quyền nếu chưa có
    });

    if (FlutterBluePlus.isScanningNow) {
      debugPrint("Đang dừng scan cũ...");
      await FlutterBluePlus.stopScan();

      // Chờ đến khi scan dừng hẳn
      int retry = 0;
      while (FlutterBluePlus.isScanningNow && retry < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        retry++;
      }

      if (FlutterBluePlus.isScanningNow) {
        debugPrint("Không thể dừng scan cũ.");
        return;
      }
    }

    debugPrint("Bắt đầu quét lại...");
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      webOptionalServices: [
        Guid("180f"),
        Guid("180a"),
        Guid("1800"),
        writeCharUuid,
        notifyCharUuid,
      ],
    );
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  void dispose() {
    _stopScan();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Widget _buildScanResultTile(ScanResult r) {
    return ListTile(
      title: Text(
        r.device.platformName.isNotEmpty
            ? r.device.platformName
            : "Unknown Device",
      ),
      subtitle: Text(r.device.remoteId.str),
      trailing: ElevatedButton(
        onPressed: () => _selectDevice(r.device),
        child: const Text("Chọn"),
      ),
    );
  }

  void _selectDevice(BluetoothDevice device) {
    Navigator.of(context).pop(device); // trả về thiết bị đã chọn
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
      title: Container(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: const Text(
                "Scan Bluetooth",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    // tooltip: "Scan",
                    onPressed: _startScan,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    // tooltip: "Scan",
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            // if (_isScanning)
            //   const Padding(
            //     padding: EdgeInsets.symmetric(vertical: 8),
            //     child: CircularProgressIndicator(),
            //   ),
            const Divider(),
            Expanded(
              child:
                  _scanResults.isEmpty
                      ? const Center(child: Text("Không tìm thấy thiết bị"))
                      : ListView.builder(
                        itemCount: _scanResults.length,
                        itemBuilder:
                            (_, i) => _buildScanResultTile(_scanResults[i]),
                      ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      // actions: [
      //   TextButton(
      //     onPressed: () => Navigator.of(context).pop(),
      //     child: const Text("Đóng", style: TextStyle(fontSize: 10)),
      //   ),
      // ],
    );
  }
}
