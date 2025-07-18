import 'dart:async';

import 'package:Kulbot/utils/extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'Terminal.dart';

class ScanScreen extends StatefulWidget {
  final String generatedCode;

  const ScanScreen({super.key, required this.generatedCode});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  // 👇 Thay bằng UUID của bạn nếu khác
  final Guid writeCharUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        if (mounted) {
          setState(() => _scanResults = results);
        }
      },
      onError: (e) {
        print("Scan Error: $e");
      },
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() => _isScanning = state);
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> onScanPressed() async {
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

  Future<void> onStopPressed() async {
    await FlutterBluePlus.stopScan();
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      print("Connect error: $e");
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BleTerminal(
              device: device,
              writeCharacteristicUuid: writeCharUuid,
              notifyCharacteristicUuid: notifyCharUuid,
              generatedCode: widget.generatedCode, // 👈 truyền code Blockly
            ),
        settings: const RouteSettings(name: '/BleTerminal'),
      ),
    );
  }

  Future<void> onRefresh() async {
    if (!_isScanning) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton() {
    return _isScanning
        ? CircularProgressIndicator()
        : ElevatedButton(onPressed: onScanPressed, child: const Text("SCAN"));
  }

  Iterable<Widget> _buildScanResultTiles() {
    return _scanResults.map(
      (r) => ListTile(
        title: Text(r.device.platformName),
        subtitle: Text(r.device.remoteId.str),
        trailing: ElevatedButton(
          onPressed: () => onConnectPressed(r.device),
          child: const Text("Connect"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
        actions: [buildScanButton(), const SizedBox(width: 15)],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(children: _buildScanResultTiles().toList()),
      ),
    );
  }
}
