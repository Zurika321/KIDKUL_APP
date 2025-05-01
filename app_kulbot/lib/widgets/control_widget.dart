import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:showcaseview/showcaseview.dart';
import '../service/bluetooth_service.dart';
import 'scanQR_widget.dart';

// GlobalKey _one = GlobalKey();
// GlobalKey _two = GlobalKey();
// GlobalKey _three = GlobalKey();
// GlobalKey _four = GlobalKey();
// GlobalKey _five = GlobalKey();
// GlobalKey _six = GlobalKey();
// GlobalKey _seven = GlobalKey();
// GlobalKey _eight = GlobalKey();

class ControlWidget extends StatefulWidget {
  final bool checkAvailability;

  const ControlWidget({this.checkAvailability = true});

  @override
  State<ControlWidget> createState() => _ControlWidgetState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ControlWidgetState extends State<ControlWidget> {
  late GlobalKey _one;
  late GlobalKey _two;
  late GlobalKey _three;
  late GlobalKey _four;
  late GlobalKey _five;
  late GlobalKey _six;
  late GlobalKey _seven;
  late GlobalKey _eight;

  late String _moveForwardCommand;
  late String _moveFLeftCommand;
  late String _moveFRightCommand;

  late String _moveBackwardCommand;
  late String _moveBLeftCommand;
  late String _moveBRightCommand;

  late String _moveTurnLeftCommand;
  late String _moveTurnRightCommand;

  late String _moveStopCommand;

  final BluetoothService _bluetoothService = BluetoothService();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String voicetotext = "";

  bool isPressedSound = false;
  bool isPressedLight = false;

  JoystickMode _joystickModeLeft = JoystickMode.vertical;
  JoystickMode _joystickModeRight = JoystickMode.horizontal;
  double _x = 100;
  double _y = 100;

  List<_Message> messages = [];

  bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);
  String connectedDeviceName = "Chưa kết nối với robot"; //Thông báo cho ng dùng

  @override
  void initState() {
    super.initState();

    _one = GlobalKey();
    _two = GlobalKey();
    _three = GlobalKey();
    _four = GlobalKey();
    _five = GlobalKey();
    _six = GlobalKey();
    _seven = GlobalKey();
    _eight = GlobalKey();
    _loadSettings();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothService.bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.address.then((address) {
      setState(() {
        _bluetoothService.address = address!;
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _bluetoothService.name = name!;
      });
    });

    _bluetoothService.onDeviceConnected = (String deviceName) {
      setState(() {
        connectedDeviceName = "Đã kết nối với $deviceName";
      });
    };

    _bluetoothService.onDeviceDisconnected = () {
      setState(() {
        connectedDeviceName = "Chưa kết nối với robot";
      });
    };

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothService.bluetoothState = state;
      });
    });

    _bluetoothService.requestLocationPermission().then((_) {
      if (widget.checkAvailability) {
        _bluetoothService.startDiscoveryWithTimeout();
      }
    });

    _bluetoothService.getBondedDevices();
    _checkBluetoothStatus();

    _speech = stt.SpeechToText();
  }

  void _checkBluetoothStatus() {
    _bluetoothService.flutterBluetoothSerial.state.then((state) {
      setState(() {
        _bluetoothService.bluetoothState = state;
      });
    });
  }

  Future<void> scanQRcodeNormal() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQRWidget(
          onScanComplete: (String result) {
            _bluetoothService.sendMessage(result);
          },
        ),
      ),
    );
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveForwardCommand = prefs.getString('moveForward') ?? 'FF';
      _moveFLeftCommand = prefs.getString('moveFLeft') ?? 'GG';
      _moveFRightCommand = prefs.getString('moveFRight') ?? 'II';

      _moveBackwardCommand = prefs.getString('moveBackward') ?? 'BB';
      _moveBLeftCommand = prefs.getString('moveBLeft') ?? 'JJ';
      _moveBRightCommand = prefs.getString('moveBRight') ?? 'HH';

      _moveTurnLeftCommand = prefs.getString('moveTurnLeft') ?? 'LL';
      _moveTurnRightCommand = prefs.getString('moveTurnRight') ?? 'RR';

      _moveStopCommand = prefs.getString('moveStop') ?? 'SS';
    });
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

// ...existing code...

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        // backgroundColor: isDarkMode
        //     ? Colors.black
        //     : const Color.fromARGB(
        //         255, 131, 139, 149),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: Row(
            children: [
              Icon(Icons.rocket, color: Colors.cyanAccent), // Biểu tượng robot
              SizedBox(width: 10),
              Text(
                "$connectedDeviceName",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Showcase(
              key: _one,
              description: 'Đây là nút hướng dẫn sử dụng điều khiển robot',
              child: IconButton(
                icon:
                    Icon(Icons.question_mark_rounded, color: Colors.cyanAccent),
                onPressed: () {
                  ShowCaseWidget.of(context).startShowCase([
                    _one,
                    _two,
                    _three,
                    _four,
                    _five,
                    _six,
                    _seven,
                    _eight,
                  ]);
                },
              ),
            ),
            Showcase(
              key: _two,
              description: 'Đây là nút quét mã QR để điều khiển robot',
              child: IconButton(
                icon: Icon(Icons.qr_code_scanner_outlined,
                    color: Colors.cyanAccent),
                onPressed: scanQRcodeNormal,
              ),
            ),
            Showcase(
              key: _three,
              description: 'Bật / tắt Bluetooth và kết nối robot',
              child: IconButton(
                icon: Icon(
                  _bluetoothService.bluetoothState.isEnabled
                      ? (isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth)
                      : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.greenAccent : Colors.redAccent,
                ),
                onPressed: () {
                  _bluetoothService.startDiscoveryWithTimeout();
                  isConnected
                      ? _bluetoothService.connection?.dispose()
                      : _bluetoothService.connectBluetoothDialog(context);
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Showcase(
          key: _four,
          description: 'Điều khiển robot bằng giọng nói',
          child: AvatarGlow(
            animate: _isListening,
            glowColor: Colors.cyanAccent,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            child: FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              onPressed: _listenVoiceToText,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.black),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Showcase(
                  key: _five,
                  description: 'Bật đèn robot',
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPressedLight = !isPressedLight;
                        isPressedLight ? _light() : _endlight();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPressedLight ? Colors.grey : Colors.cyanAccent,
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.tips_and_updates_outlined,
                          color: Colors.black),
                    ),
                  ),
                ),
                Showcase(
                  key: _six,
                  description: 'Bật kèn robot',
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        isPressedSound = true;
                        _sound();
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        isPressedSound = false;
                        _endsound();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPressedSound ? Colors.grey : Colors.cyanAccent,
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.volume_up, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Showcase(
                  key: _seven,
                  description: 'Joystick điều khiển robot lên/xuống',
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(bottom: 40, left: 50),
                    alignment: const Alignment(0, 0.8),
                    child: Joystick(
                      base: JoystickBase(
                        mode: _joystickModeLeft,
                        decoration: JoystickBaseDecoration(
                          middleCircleColor: Colors.cyanAccent,
                          drawOuterCircle: true,
                          drawInnerCircle: true,
                          boxShadowColor: Colors.cyanAccent.withOpacity(0.5),
                        ),
                        arrowsDecoration: JoystickArrowsDecoration(
                          color: Colors.yellowAccent,
                        ),
                      ),
                      stick: JoystickStick(
                        size: 100,
                        decoration: JoystickStickDecoration(
                          color: Colors.yellowAccent,
                        ),
                      ),
                      mode: _joystickModeLeft,
                      listener: handleVerticalJoystickMove,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    voicetotext == '' ? "..." : voicetotext,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32.0,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Showcase(
                  key: _eight,
                  description: 'Joystick điều khiển robot trái/phải',
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(bottom: 40, right: 50),
                    alignment: const Alignment(0, 0.8),
                    child: Joystick(
                      base: JoystickBase(
                        mode: _joystickModeRight,
                        decoration: JoystickBaseDecoration(
                          middleCircleColor: Colors.cyanAccent,
                          drawOuterCircle: true,
                          drawInnerCircle: true,
                          boxShadowColor: Colors.cyanAccent.withValues(),
                        ),
                        arrowsDecoration: JoystickArrowsDecoration(
                          color: Colors.yellowAccent,
                        ),
                      ),
                      stick: JoystickStick(
                        size: 100,
                        decoration: JoystickStickDecoration(
                          color: Colors.yellowAccent,
                        ),
                      ),
                      mode: _joystickModeRight,
                      listener: handleHorizontalJoystickMove,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sound() async {
    if (isPressedSound) {
      print('EE');
      _bluetoothService.sendMessage('EE');
      Future.delayed(Duration(milliseconds: 200));
    }
  }

  void _endsound() {
    if (isPressedSound == false) {
      print('NN');
      _bluetoothService.sendMessage('NN');
      Future.delayed(Duration(milliseconds: 200));
    }
  }

  void _light() async {
    print('O');
    _bluetoothService.sendMessage('OO');
    await Future.delayed(Duration(milliseconds: 200));
  }

  void _endlight() {
    if (isPressedLight == false) {
      print('PP');
      _bluetoothService.sendMessage('PP');
      Future.delayed(Duration(milliseconds: 200));
    }
  }

  void _listenVoiceToText() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            voicetotext = val.recognizedWords;
            moveMotor();
          }),
        );
      } else {
        print("Không thể khởi tạo mic. Có thể bị từ chối quyền.");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (voicetotext.isNotEmpty) moveMotor();
    }
  }

  void moveMotor() {
    if (!isConnected) return;
    final voice = voicetotext.toLowerCase();
    if (voice.contains('Tiến') ||
        voice.contains('lên') ||
        voice.contains('forward')) {
      _bluetoothService.sendMessage(_moveForwardCommand);
    } else if (voice.contains('lui') ||
        voice.contains('lùi') ||
        voice.contains('back')) {
      _bluetoothService.sendMessage(_moveBackwardCommand);
    } else if (voice.contains('trái') || voice.contains('left')) {
      _bluetoothService.sendMessage(_moveTurnLeftCommand);
    } else if (voice.contains('phải') || voice.contains('right')) {
      _bluetoothService.sendMessage(_moveTurnRightCommand);
    } else if (voice.contains('dừng') || voice.contains('stop')) {
      _bluetoothService.sendMessage(_moveStopCommand);
    } else {
      print("Không nhận diện được lệnh thoại: $voicetotext");
    }
    setState(() {
      voicetotext = "";
    });
  }

  void handleHorizontalJoystickMove(details) {
    _x = details.x;
    print("x: $_x");
    determineMovement();
  }

  void handleVerticalJoystickMove(details) {
    _y = details.y;
    print("y: $_y");
    determineMovement();
  }

  void determineMovement() {
    const double threshold =
        0.2; // ngưỡng để tránh nhiễu nhỏ khi joystick ở giữa

    if (_y < -threshold) {
      // Tiến
      if (_x < -threshold) {
        print("Tiến Trái");
        _bluetoothService.sendMessage(_moveFLeftCommand);
      } else if (_x > threshold) {
        print("Tiến Phải");
        _bluetoothService.sendMessage(_moveFRightCommand);
      } else {
        print("Tiến");
        _bluetoothService.sendMessage(_moveForwardCommand);
      }
    } else if (_y > threshold) {
      // Lùi
      if (_x < -threshold) {
        print("Lùi Trái");
        _bluetoothService.sendMessage(_moveBLeftCommand);
      } else if (_x > threshold) {
        print("Lùi Phải");
        _bluetoothService.sendMessage(_moveBRightCommand);
      } else {
        print("Lùi");
        _bluetoothService.sendMessage(_moveBackwardCommand);
      }
    } else {
      // Không tiến/lùi, chỉ xoay tại chỗ
      if (_x < -threshold) {
        print("Xoay Trái");
        _bluetoothService.sendMessage(_moveTurnLeftCommand);
      } else if (_x > threshold) {
        print("Xoay Phải");
        _bluetoothService.sendMessage(_moveTurnRightCommand);
      } else {
        print("Dừng");
        _bluetoothService.sendMessage(_moveStopCommand);
      }
    }
  }
}
