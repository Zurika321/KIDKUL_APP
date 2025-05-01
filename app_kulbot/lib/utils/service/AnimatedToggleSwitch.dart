import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class ATSwitch extends StatefulWidget {
  final bool current;
  final bool first;
  final bool second;
  final double spacing;
  final void Function(bool) onChanged;
  final String titleSwitchTrue;
  final String titleSwitchFalse;
  final Icon? iconSwitchTrue;
  final Icon? iconSwitchFalse;

  const ATSwitch({
    super.key,
    required this.current,
    required this.first,
    required this.second,
    required this.spacing,
    required this.onChanged,
    required this.titleSwitchTrue,
    required this.titleSwitchFalse,
     this.iconSwitchTrue,
     this.iconSwitchFalse,
  });
  @override
  State<ATSwitch> createState() => _ATSwitchState();
}

class _ATSwitchState extends State<ATSwitch> {
  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: AnimatedToggleSwitch<bool>.dual(
                    current: widget.current,
                    first:  widget.first,
                    second: widget.second,
                    spacing: widget.spacing,
                    style: const ToggleStyle(
                      borderColor: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                    borderWidth: 5.0,
                    height: 55,
                    onChanged: widget.onChanged,
                    styleBuilder: (valueSwitch) => ToggleStyle(
                        indicatorColor: valueSwitch == true ? Colors.green : Colors.red),
                    iconBuilder: (valueSwitch) => valueSwitch == true 
                        ?  widget.iconSwitchTrue ?? SizedBox.shrink()
                        : widget.iconSwitchFalse ?? SizedBox.shrink(),
                    textBuilder: (valueSwitch) => valueSwitch == true
                        ?  Center(child: Text(widget.titleSwitchTrue))
                        :  Center(child: Text(widget.titleSwitchFalse)),
                  ),
          );
  }
}