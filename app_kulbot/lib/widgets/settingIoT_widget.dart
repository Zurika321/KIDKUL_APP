import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingiotWidget extends StatefulWidget {
  const SettingiotWidget({super.key});

  @override
  State<SettingiotWidget> createState() => _SettingiotWidgetState();
}

class _SettingiotWidgetState extends State<SettingiotWidget> {
  final TextEditingController _editingControllerSwitch1_On = TextEditingController();
  final TextEditingController _editingControllerSwitch1_Off = TextEditingController();

  final TextEditingController _editingControllerSwitch2_On = TextEditingController();
  final TextEditingController _editingControllerSwitch2_Off = TextEditingController();

  // final TextEditingController _editingControllerLight1_On = TextEditingController();
  // final TextEditingController _editingControllerLight1_Off = TextEditingController();

  // final TextEditingController _editingControllerLight2_On = TextEditingController();
  // final TextEditingController _editingControllerLight2_Off = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '_editingControllerSwitch1_On', _editingControllerSwitch1_On.text);
    await prefs.setString(
        '_editingControllerSwitch1_Off', _editingControllerSwitch1_Off.text);

    await prefs.setString(
        '_editingControllerSwitch2_On', _editingControllerSwitch2_On.text);
    await prefs.setString(
        '_editingControllerSwitch2_Off', _editingControllerSwitch2_Off.text);

    // await prefs.setString(
    //     '_editingControllerLight1_On', _editingControllerLight1_On.text);
    // await prefs.setString(
    //     '_editingControllerLight1_Off', _editingControllerLight1_Off.text);

    // await prefs.setString(
    //     '_editingControllerLight2_On', _editingControllerLight2_On.text);
    // await prefs.setString(
    //     '_editingControllerLight2_Off', _editingControllerLight2_Off.text);


     print("Saved settings: ${_editingControllerSwitch1_On.text}, ${_editingControllerSwitch1_Off.text}");
     Fluttertoast.showToast(msg: "Saved settings: ${_editingControllerSwitch1_On.text}, ${_editingControllerSwitch1_Off.text}");
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _editingControllerSwitch1_On.text =
          prefs.getString('_editingControllerSwitch1_On') ?? '';
      _editingControllerSwitch1_Off.text =
          prefs.getString('_editingControllerSwitch1_Off') ?? '';

      _editingControllerSwitch2_On.text =
          prefs.getString('_editingControllerSwitch2_On') ?? '';
      _editingControllerSwitch2_Off.text =
          prefs.getString('_editingControllerSwitch2_Off') ?? '';

      // _editingControllerLight1_On.text =
      //     prefs.getString('_editingControllerLight1_On') ?? '';
      // _editingControllerLight1_Off.text =
      //     prefs.getString('_editingControllerLight1_Off') ?? '';

      // _editingControllerLight2_On.text =
      //     prefs.getString('_editingControllerLight2_On') ?? '';
      // _editingControllerLight2_Off.text =
      //     prefs.getString('_editingControllerLight2_Off') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT Settings'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align the column to the start
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded( // Use Expanded to prevent overflow in Row
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: InputSettingIoT(
                        label: "Switch 1: ON",
                        controller: _editingControllerSwitch1_On,
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between the two columns
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: InputSettingIoT(
                        label: "Switch 1: Off",
                        controller: _editingControllerSwitch1_Off,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded( // Use Expanded to prevent overflow in Row
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: InputSettingIoT(
                        label: "Switch 2: ON",
                        controller: _editingControllerSwitch2_On,
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between the two columns
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: InputSettingIoT(
                        label: "Switch 2: Off",
                        controller: _editingControllerSwitch2_Off,
                      ),
                    ),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Expanded( // Use Expanded to prevent overflow in Row
              //       child: Padding(
              //         padding: EdgeInsets.only(top: 20),
              //         child: InputSettingIoT(
              //           label: "Light 1: ON",
              //           controller: _editingControllerLight1_On,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 16), // Add spacing between the two columns
              //     Expanded(
              //       child: Padding(
              //         padding: EdgeInsets.only(top: 20),
              //         child: InputSettingIoT(
              //           label: "Light 1: Off",
              //           controller: _editingControllerLight1_Off,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Expanded( // Use Expanded to prevent overflow in Row
              //       child: Padding(
              //         padding: EdgeInsets.only(top: 20),
              //         child: InputSettingIoT(
              //           label: "Light 2: ON",
              //           controller: _editingControllerLight2_On,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 16), // Add spacing between the two columns
              //     Expanded(
              //       child: Padding(
              //         padding: EdgeInsets.only(top: 20),
              //         child: InputSettingIoT(
              //           label: "Light 2: Off",
              //           controller: _editingControllerLight2_Off,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: ElevatedButton(
                  onPressed: () {
                    _saveSettings();
                    Fluttertoast.showToast(msg: "Đã Lưu");
                    setState(() {
                      _saveSettings();
                    });
                  },
                  child: Text("Lưu"),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputSettingIoT extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  const InputSettingIoT({super.key, this.controller, required this.label});

  @override
  State<InputSettingIoT> createState() => _InputSettingIoTState();
}

class _InputSettingIoTState extends State<InputSettingIoT> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
