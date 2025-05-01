import 'package:Kulbot/widgets/iot_widget.dart';
import 'package:flutter/material.dart';

class Iotscreen extends StatefulWidget {
  const Iotscreen({super.key});

  @override
  State<Iotscreen> createState() => _IotscreenState();
}

class _IotscreenState extends State<Iotscreen> {
  @override
  Widget build(BuildContext context) {
    return IotWidget();
  }
}
