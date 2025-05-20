import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

enum _DeviceAvailability { no, maybe, yes }

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class BluetoothService with ChangeNotifier {
  double? receivedValue1;
  double? receivedValue2;
  double? receivedValue3;
  double? receivedValue4;

  BluetoothState _bluetoothState = BluetoothState.STATE_ON;
  String _address = "...";
  String _name = "...";

  Function(String)? onDeviceConnected;
  Function()? onDeviceDisconnected;

  bool isDisconnecting = false;
  FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  List<_DeviceWithAvailability> devices = [];

  // Getters
  BluetoothState get bluetoothState => _bluetoothState;
  String get address => _address;
  String get name => _name;

  // Callback for when data values change
  Function(double)? onValueReceiveChanged;

  // Setters
  set bluetoothState(BluetoothState state) {
    _bluetoothState = state;
  }

  set address(String addr) {
    _address = addr;
  }

  set name(String name) {
    _name = name;
  }

  final StreamController<Map<String, double?>> _streamController =
      StreamController.broadcast();
  Stream<Map<String, double?>> get stream => _streamController.stream;

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.location.isDenied) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    }
  }

  Future<void> startDiscoverySafely() async {
    if (await Permission.location.isGranted) {
      startDiscoveryWithTimeout();
    } else {
      await requestBluetoothPermissions();
    }
  }

  void startDiscoveryWithTimeout() {
    Timer(Duration(seconds: 10), () {
      flutterBluetoothSerial.cancelDiscovery();
    });

    flutterBluetoothSerial.startDiscovery().listen((r) {
      bool isNewDevice = devices.every((device) => device.device != r.device);
      if (isNewDevice) {
        devices.add(
          _DeviceWithAvailability(r.device, _DeviceAvailability.yes, r.rssi),
        );
        notifyListeners();
      }
    });
  }

  void getBondedDevices() async {
    List<BluetoothDevice> bondedDevices =
        await flutterBluetoothSerial.getBondedDevices();
    devices =
        bondedDevices
            .map(
              (device) =>
                  _DeviceWithAvailability(device, _DeviceAvailability.maybe),
            )
            .toList();
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      if (connection != null && connection!.isConnected) {
        onDeviceConnected?.call(device.name ?? "Unknown");
        connection!.input?.listen(_onDataReceived).onDone(() {
          if (isDisconnecting) {
            print('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
            onDeviceDisconnected?.call();
          }
        });
      } else {
        print('Connection failed or connection is null.');
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  void _onDataReceived(Uint8List data) {
    String dataString = utf8.decode(data);
    _parseAndStoreData(dataString);

    _streamController.add({
      "receivedValue1": receivedValue1,
      "receivedValue2": receivedValue2,
      "receivedValue3": receivedValue3,
      "receivedValue4": receivedValue4,
    });
  }

  void _parseAndStoreData(String dataString) {
    dataString = dataString.replaceAll(RegExp(r'[\$]'), '');
    List<String> parts = dataString.split(';');

    for (var part in parts) {
      if (part.contains(':')) {
        List<String> subParts = part.split(':');
        int? id = int.tryParse(
          subParts[0].trim().replaceAll(RegExp(r'[a-zA-Z ]'), ''),
        );
        double? value = double.tryParse(subParts[1].trim());

        if (id != null && value != null) {
          switch (id) {
            case 1:
              receivedValue1 = value;
              break;
            case 2:
              receivedValue2 = value;
              break;
            case 3:
              receivedValue3 = value;
              break;
            case 4:
              receivedValue4 = value;
              break;
          }
          notifyListeners();
        }
      }
    }
  }

  void sendMessage(String text) async {
    if (text.isNotEmpty && connection != null && connection!.isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  Future<void> connectBluetoothDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start discovery only once when dialog is opened
            if (_bluetoothState.isEnabled && devices.isEmpty) {
              startDiscoverySafely(); // Pass setState
            }

            return AlertDialog(
              alignment: Alignment.center,
              title: const Text(
                'Bluetooth',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              content:
                  _bluetoothState.isEnabled
                      ? buildDevicesListView(context, setState)
                      : const Text(
                        "Không tìm thấy thiết bị hoặc chưa bật bluetooth",
                      ),
            );
          },
        );
      },
    );
  }

  /// Build the list of available devices
  Widget buildDevicesListView(BuildContext context, setState) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.grey[50],
      width: screenWidth * 0.5,
      height: screenHeight * 0.50,
      child: ListView(
        children:
            devices.map((_device) {
              Color iconColor = Colors.green;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    await connectToDevice(_device.device);
                    Navigator.of(context).pop(); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(10, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _device.device.name ?? "Unknown",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _device.device.address,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.android, color: iconColor),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    flutterBluetoothSerial.cancelDiscovery();
    if (connection != null && connection!.isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    _streamController.close();
    super.dispose();
  }
}
