import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../utils/snackbar.dart';
import '../../../utils/extra.dart';
import 'Terminal.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isDiscovering = false;
  List<BluetoothService> _services = [];

  // UUIDs của Nordic UART
  final Guid txUuid = Guid('6e400003-b5a3-f393-e0a9-e50e24dcca9e'); // Notify
  final Guid rxUuid = Guid('6e400002-b5a3-f393-e0a9-e50e24dcca9e'); // Write

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      await widget.device.connectAndUpdateStream();
    } catch (_) {}
  }

  Future<void> _discoverServices() async {
    setState(() => _isDiscovering = true);
    try {
      _services = await widget.device.discoverServices();
      Snackbar.show(ABC.c, "Services discovered", success: true);
      _navigateToChatPage();
    } catch (e) {
      Snackbar.show(ABC.c, "Discover failed: $e", success: false);
    } finally {
      setState(() => _isDiscovering = false);
    }
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BleTerminal(
              device: widget.device,
              writeCharacteristicUuid: rxUuid,
              notifyCharacteristicUuid: txUuid,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.device.platformName)),
        body: Center(
          child:
              _isDiscovering
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _discoverServices,
                    child: const Text('Get Services & Go to Chat'),
                  ),
        ),
      ),
    );
  }
}
