import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:showcaseview/showcaseview.dart';
import '../../service/bluetooth_service.dart';

class DogWidget extends StatefulWidget {
  const DogWidget({super.key});

  @override
  State<DogWidget> createState() => _DogWidgetState();
}

class _DogWidgetState extends State<DogWidget> {
  final BluetoothService _bluetoothService = BluetoothService();
  bool isConnected = false;
  bool isPressedSound = false;
  bool isPressedLight = false;

  static const String _moveForwardCommand = 'FF';
  static const String _moveBackwardCommand = 'BB';
  static const String _moveTurnLeftCommand = 'LL';
  static const String _moveTurnRightCommand = 'RR';
  static const String _moveStopCommand = 'SS';

  void _sendCommand(String command) {
    if (isConnected) {
      _bluetoothService.sendMessage(command);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Chưa kết nối với robot")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // D-padbody: SingleChildScrollView(
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _bluetoothService.bluetoothState.isEnabled
                          ? (isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth)
                          : Icons.bluetooth_disabled,
                      color:
                          isConnected ? Colors.greenAccent : Colors.redAccent,
                      size: 45,
                    ),
                    onPressed: () {
                      _bluetoothService.startDiscoveryWithTimeout();
                      isConnected
                          ? _bluetoothService.connection?.dispose()
                          : _bluetoothService.connectBluetoothDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 80),

                onPressed: () => _sendCommand(_moveForwardCommand),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 80),
                onPressed: () => _sendCommand(_moveTurnLeftCommand),
              ),
              const SizedBox(width: 80),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 80),
                onPressed: () => _sendCommand(_moveTurnRightCommand),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 80),
                onPressed: () => _sendCommand(_moveBackwardCommand),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => isPressedSound = !isPressedSound);
                  _sendCommand(isPressedSound ? 'COI_ON' : 'COI_OFF');
                },
                icon: const Icon(Icons.volume_up, size: 45),
                label: const Text("Sủa", style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => isPressedLight = !isPressedLight);
                  _sendCommand(isPressedLight ? 'LIGHT_ON' : 'LIGHT_OFF');
                },
                icon: const Icon(Icons.lightbulb, size: 45),
                label: const Text("Đèn", style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton.icon(
                onPressed: () => _sendCommand('FACE'),
                icon: const Icon(Icons.face_retouching_natural, size: 45),
                label: const Text("Nhận diện", style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton.icon(
                onPressed: () => _sendCommand('SIT'),
                icon: const Icon(Icons.event_seat, size: 45),
                label: const Text("Ngồi", style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton.icon(
                onPressed: () => _sendCommand('STAND'),
                icon: const Icon(Icons.accessibility, size: 45),
                label: const Text("Đứng", style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton.icon(
                onPressed: () => _sendCommand(_moveStopCommand),
                icon: const Icon(Icons.stop_circle, size: 45),
                label: const Text("Dừng", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
