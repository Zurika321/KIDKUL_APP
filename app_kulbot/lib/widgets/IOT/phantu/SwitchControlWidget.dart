import 'package:Kulbot/utils/service/AnimatedToggleSwitch.dart';
import 'package:flutter/material.dart';

//SwitchControlWidget – đèn & công tắc

class SwitchControlWidget extends StatelessWidget {
  final String label;
  final bool currentSwitch;
  final ValueChanged<bool> onChanged;
  final bool isConnected;

  const SwitchControlWidget({
    super.key,
    required this.label,
    required this.currentSwitch,
    required this.onChanged,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Text(label),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  color:
                      isConnected && currentSwitch ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ATSwitch(
              current: currentSwitch,
              first: false,
              second: true,
              spacing: 50,
              onChanged: onChanged,
              titleSwitchTrue: 'ON',
              titleSwitchFalse: 'OFF',
            ),
          ],
        ),
      ),
    );
  }
}

// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   children: [
//     SwitchControlWidget(
//       label: "Light & Switch 1",
//       currentSwitch: switch1,
//       isConnected: _bluetoothService.connection?.isConnected ?? false,
//       onChanged: (valueSwitch) {
//         setState(() {
//           switch1 = valueSwitch;
//           _bluetoothService.sendMessage(
//               switch1 ? _ControllerSwitch1_On : _ControllerSwitch1_Off);
//         });
//       },
//     ),
//     SwitchControlWidget(
//       label: "Light & Switch 2",
//       currentSwitch: switch2,
//       isConnected: _bluetoothService.connection?.isConnected ?? false,
//       onChanged: (valueSwitch) {
//         setState(() {
//           switch2 = valueSwitch;
//           _bluetoothService.sendMessage(
//               switch2 ? _ControllerSwitch2_On : _ControllerSwitch2_Off);
//         });
//       },
//     ),
//   ],
// ),
