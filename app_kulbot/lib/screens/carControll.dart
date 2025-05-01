import 'package:Kulbot/widgets/control_widget.dart';
import 'package:flutter/material.dart';

class CarControl extends StatefulWidget {
   const CarControl({super.key});

  @override
  State<CarControl> createState() => _CarControlState();
}

class _CarControlState extends State<CarControl> {
  @override
  Widget build(BuildContext context) {
    return ControlWidget();
  }
}
