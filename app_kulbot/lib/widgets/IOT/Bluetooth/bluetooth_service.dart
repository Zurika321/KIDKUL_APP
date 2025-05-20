import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBluetoothService {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _characteristic;

  final List<ScanResult> scanResults = [];
  final StreamController<Map<String, String>> _dataController =
      StreamController.broadcast();

  Stream<Map<String, String>> get dataStream => _dataController.stream;

  static Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void initializeScanListener() {
    FlutterBluePlus.scanResults.listen((results) {
      scanResults
        ..clear()
        ..addAll(results);
    });
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    scanResults.clear();
    FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await stopScan();
    connectedDevice = device;

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      debugPrint("Connection failed: $e");
    }

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          _characteristic = characteristic;
          await _characteristic!.setNotifyValue(true);
          _characteristic!.lastValueStream.listen(_onDataReceived);

          // Lưu thiết bị đã kết nối
          _saveLastConnectedDevice(device.id.id);
          return;
        }
      }
    }
  }

  void _onDataReceived(List<int> data) {
    try {
      final text = utf8.decode(data);
      final items = text.split(';');

      Map<String, String> parsed = {};
      for (var item in items) {
        if (item.contains(':')) {
          final parts = item.split(':');
          if (parts.length == 2) {
            parsed[parts[0]] = parts[1];
            debugPrint("Received: ${parts[0]} = ${parts[1]}");
          }
        }
      }

      _dataController.add(parsed);
    } catch (e) {
      debugPrint("Parse error: $e");
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      _characteristic = null;
    }
  }

  Future<void> sendMessage(String message) async {
    if (_characteristic != null && _characteristic!.properties.write) {
      await _characteristic!.write(utf8.encode(message));
    }
  }

  Future<bool> isBluetoothOn() async {
    return await FlutterBluePlus.isOn;
  }

  /// Ghi nhớ thiết bị
  Future<void> _saveLastConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_device_id', deviceId);
  }

  /// Lấy thiết bị đã kết nối gần nhất
  Future<String?> getLastConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_device_id');
  }

  /// Xoá thiết bị đã lưu
  Future<void> clearLastConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_device_id');
  }
}
