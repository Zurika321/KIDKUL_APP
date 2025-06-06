import 'dart:async';
import 'dart:convert';

import 'package:Kulbot/utils/service/AnimatedToggleSwitch.dart';
import 'package:Kulbot/widgets/IOT/phantu/SCS/SleekCircularSlider.dart';
import 'package:Kulbot/widgets/IOT/settingIoT_widget.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../service/bluetooth_service.dart';

class IotWidget extends StatefulWidget {
  final bool checkAvailability;
  const IotWidget({super.key, this.checkAvailability = true});

  @override
  State<IotWidget> createState() => _IotWidgetState();
}

class _IotWidgetState extends State<IotWidget> {
  String _ControllerSwitch1_On = "";
  String _ControllerSwitch1_Off = "";

  String _ControllerSwitch2_On = "";
  String _ControllerSwitch2_Off = "";

  // String _ControllerLight1_On = "";
  // String _ControllerLight1_Off = "";

  // String _ControllerLight2_On = "";
  // String _ControllerLight2_Off = "";

  final TextEditingController _editingSCS_title_1 = TextEditingController();
  final TextEditingController _editingSCS_dv_1 = TextEditingController();
  String SCS_title_1 = "";
  String SCS_dv_1 = "";

  final TextEditingController _editingSCS_title_2 = TextEditingController();
  final TextEditingController _editingSCS_dv_2 = TextEditingController();
  String SCS_title_2 = "";
  String SCS_dv_2 = "";

  final TextEditingController _editingSCS_title_3 = TextEditingController();
  final TextEditingController _editingSCS_dv_3 = TextEditingController();
  String SCS_title_3 = "";
  String SCS_dv_3 = "";

  final TextEditingController _editingSCS_title_4 = TextEditingController();
  final TextEditingController _editingSCS_dv_4 = TextEditingController();
  String SCS_title_4 = "";
  String SCS_dv_4 = "";

  final BluetoothService _bluetoothService = BluetoothService();
  bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);
  String connectedDeviceName = "...";

  bool switch1 = false;
  bool switch2 = false;
  Color _containerColor_1 = Colors.blue;
  Color _containerColor_2 = Colors.blue;

  late Stream<List<int>> stream;
  bool isConnecting = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String voicetotext = "";

  double _currentValueId1 = 0.0;
  double _currentValueId2 = 0.0;
  double _currentValueId3 = 0.0;
  double _currentValueId4 = 0.0;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    stream = Stream.empty(); // This will ensure stream is not null
    _loadSettings();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _bluetoothService.startDiscoveryWithTimeout();

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
        connectedDeviceName = deviceName;
      });
    };

    FlutterBluetoothSerial.instance.onStateChanged().listen((
      BluetoothState state,
    ) {
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

    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _bluetoothService.connection!.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('_editingSCS_title_1', _editingSCS_title_1.text);
    await prefs.setString('_editingSCS_dv_1', _editingSCS_dv_1.text);

    await prefs.setString('_editingSCS_title_2', _editingSCS_title_2.text);
    await prefs.setString('_editingSCS_dv_2', _editingSCS_dv_2.text);

    await prefs.setString('_editingSCS_title_3', _editingSCS_title_3.text);
    await prefs.setString('_editingSCS_dv_3', _editingSCS_dv_3.text);

    await prefs.setString('_editingSCS_title_4', _editingSCS_title_4.text);
    await prefs.setString('_editingSCS_dv_4', _editingSCS_dv_4.text);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ControllerSwitch1_On =
          prefs.getString('_editingControllerSwitch1_On') ?? '';
      _ControllerSwitch1_Off =
          prefs.getString('_editingControllerSwitch1_Off') ?? '';

      _ControllerSwitch2_On =
          prefs.getString('_editingControllerSwitch2_On') ?? '';
      _ControllerSwitch2_Off =
          prefs.getString('_editingControllerSwitch2_Off') ?? '';

      // _ControllerLight1_On =
      //     prefs.getString('_editingControllerLight1_On') ?? '';
      // _ControllerLight1_Off =
      //     prefs.getString('_editingControllerLight1_Off') ?? '';

      // _ControllerLight2_On =
      //     prefs.getString('_editingControllerLight2_On') ?? '';
      // _ControllerLight2_Off =
      //     prefs.getString('_editingControllerLight2_Off') ?? '';

      SCS_title_1 = prefs.getString('_editingSCS_title_1') ?? 'Temp 1';
      //_editingSCS_title_1.text = prefs.getString('_editingSCS_title_1')?? 'Temp 1';
      SCS_dv_1 = prefs.getString('_editingSCS_dv_1') ?? '˚C';
      //_editingSCS_dv_1.text = prefs.getString('_editingSCS_dv_1')?? '˚C';

      SCS_title_2 = prefs.getString('_editingSCS_title_2') ?? 'Humidity 2';
      //_editingSCS_title_2.text = prefs.getString('_editingSCS_title_2')?? 'Humidity 2';
      SCS_dv_2 = prefs.getString('_editingSCS_dv_2') ?? '%';
      //_editingSCS_dv_2.text = prefs.getString('_editingSCS_dv_2')?? '%';

      SCS_title_3 = prefs.getString('_editingSCS_title_3') ?? 'Temp 3';
      //_editingSCS_title_3.text = prefs.getString('_editingSCS_title_3')?? 'Temp 3';
      SCS_dv_3 = prefs.getString('_editingSCS_dv_3') ?? '˚C';
      //_editingSCS_dv_3.text = prefs.getString('_editingSCS_dv_3')?? '˚C';

      SCS_title_4 = prefs.getString('_editingSCS_title_4') ?? 'Humidity 4';
      //_editingSCS_title_4.text = prefs.getString('_editingSCS_title_4')?? 'Humidity 4';
      SCS_dv_4 = prefs.getString('_editingSCS_dv_4') ?? '%';
      //_editingSCS_dv_4.text = prefs.getString('_editingSCS_dv_4')?? '%';

      // print(
      //     "Loaded settings: $_ControllerSwitch1_On, $_ControllerSwitch1_Off, $_ControllerSwitch2_On, $_ControllerSwitch2_Off");
      // Fluttertoast.showToast(
      //     msg:
      //         "Loaded settings: $_ControllerSwitch1_On, $_ControllerSwitch1_Off, $_ControllerSwitch2_On, $_ControllerSwitch2_Off");
    });
  }

  Future<void> _delayedLoadSettings() async {
    // Gọi _loadSettings() lần đầu
    await _loadSettings();

    // Tạo độ trễ, ví dụ 2 giây
    await Future.delayed(Duration(milliseconds: 500));

    // Gọi _loadSettings() lần thứ hai
    await _loadSettings();
  }

  void _connectAndStartReceiving() async {
    setState(() {
      isConnecting = true;
      _bluetoothService.startDiscoveryWithTimeout();
    });

    try {
      // Kết nối với thiết bị
      await _bluetoothService.connectBluetoothDialog(context);

      if (_bluetoothService.connection!.isConnected) {
        setState(() {
          Fluttertoast.showToast(
            msg: "Connected to device " + connectedDeviceName,
          );
          print("Connected to device " + connectedDeviceName);
          isConnecting = false;
        });

        // Chờ một chút trước khi nhận dữ liệu
        await Future.delayed(Duration(milliseconds: 1000));
      } else {
        throw Exception("Kết nối không thành công.");
      }
    } catch (e) {
      setState(() {
        isConnecting = false;
      });
      print('Error connecting to device: $e');
    }
  }

  //   void _listenForESPResponseSwitch() {
  //   _subscription?.cancel();
  //   _subscription = _bluetoothService.stream.listen((data) {
  //     // Giả sử dữ liệu từ ESP được gửi dưới dạng string
  //     String response = utf8.decode(data);
  //     print("response from ESP: $response");  // In ra phản hồi từ ESP

  //     // Kiểm tra xem phản hồi có chứa các lệnh đúng không
  //     if (response.contains(_ControllerLight1_On)) {
  //       setState(() {
  //         _containerColor_1 = Colors.green;  // Cập nhật màu cho Container 1
  //       });
  //     } else if (response.contains(_ControllerLight1_Off)) {
  //       setState(() {
  //         _containerColor_1 = Colors.red;
  //       });
  //     } else if (response.contains(_ControllerLight2_On)) {
  //       setState(() {
  //         _containerColor_2 = Colors.green;  // Cập nhật màu cho Container 2
  //       });
  //     } else if (response.contains(_ControllerLight2_Off)) {
  //       setState(() {
  //         _containerColor_2 = Colors.red;
  //       });
  //     }
  //   });
  // }

  // void _listenForESPResponseSwitch() {
  //   _subscription?.cancel();
  //   _subscription = _bluetoothService.stream.listen((data) {
  //     String response = utf8.decode(data);
  //     //print("response from ESP: $response");  // Kiểm tra chuỗi nhận được

  //     // Tách chuỗi khi phát hiện ký tự kết thúc
  //     List<String> responses = response.split("\n");
  //     for (var res in responses) {
  //       if (res.contains('Ledon')) {
  //         setState(() {
  //           _containerColor_1 = Colors.green;
  //         });
  //       } else if (res.contains('Ledoff')) {
  //         setState(() {
  //           _containerColor_1 = Colors.red;
  //         });
  //       } else if (res.contains('on')) {
  //         setState(() {
  //           _containerColor_2 = Colors.green;
  //         });
  //       } else if (res.contains('off')) {
  //         setState(() {
  //           _containerColor_2 = Colors.red;
  //         });
  //       }
  //     }
  //   });
  // }

  void _listenVoiceToText() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult:
                (val) => setState(() {
                  voicetotext = val.recognizedWords;
                  Fluttertoast.showToast(msg: voicetotext);
                }),
          );
        } else {
          print('Speech recognition not available');
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } catch (e) {
      print('Error initializing speech recognition: $e');
    }
  }

  void voiceActive() {
    if (voicetotext.contains('Tiến') ||
        voicetotext.contains('lên') ||
        voicetotext.contains('forward')) {
      _bluetoothService.sendMessage('f');
    } else if (voicetotext.contains('lui') ||
        voicetotext.contains('lùi') ||
        voicetotext.contains('back')) {
      _bluetoothService.sendMessage('b');
    } else if (voicetotext.contains('trái') || voicetotext.contains('left')) {
      _bluetoothService.sendMessage('l');
    } else if (voicetotext.contains('phải') || voicetotext.contains('right')) {
      _bluetoothService.sendMessage('r');
    } else if (voicetotext.contains('dừng lại') ||
        voicetotext.contains('stop')) {
      _bluetoothService.sendMessage('s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IOT', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingiotWidget()),
                ).then((_) {
                  // Sau khi quay lại, load lại dữ liệu từ SharedPreferences
                  _loadSettings();
                });
              },
              icon: Icon(Icons.settings),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: IconButton(
                icon:
                    _bluetoothService.bluetoothState.isEnabled
                        ? Icon(
                          _bluetoothService.connection != null &&
                                  _bluetoothService.connection!.isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color:
                              _bluetoothService.connection != null &&
                                      _bluetoothService.connection!.isConnected
                                  ? Colors.green
                                  : Colors.red,
                        )
                        : Icon(Icons.bluetooth, color: Colors.red),
                onPressed: () {
                  _connectAndStartReceiving(); // Kết nối và nhận dữ liệu
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.green,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: _listenVoiceToText,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body:
          isConnecting
              ? Center(child: CircularProgressIndicator())
              : stream == null
              ? Center(child: Text('Chưa kết nối với thiết bị Bluetooth.'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: StreamBuilder<Map<String, dynamic>>(
                        stream:
                            _bluetoothService
                                .stream, // Lấy luồng dữ liệu từ BluetoothService
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<Map<String, dynamic?>> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return Text('Lỗi: ${snapshot.error}');
                          }

                          if (snapshot.connectionState ==
                                  ConnectionState.active &&
                              snapshot.hasData) {
                            // Phân tích dữ liệu nhận được
                            // var parsedValues = snapshot.data ?? [];

                            // // Kiểm tra có đủ 2 giá trị
                            // if (parsedValues.isNotEmpty) {
                            //   // Gán giá trị cho từng biến dựa trên số lượng giá trị nhận được
                            //   if (parsedValues.length >= 1) {
                            //     _currentValueId1 = parsedValues[0].toDouble();
                            //   }
                            //   if (parsedValues.length >= 2) {
                            //     _currentValueId2 = parsedValues[1].toDouble();
                            //   }
                            //   if (parsedValues.length >= 3) {
                            //     _currentValueId3 = parsedValues[2].toDouble();
                            //   }
                            //   if (parsedValues.length >= 4) {
                            //     _currentValueId4 = parsedValues[3].toDouble();
                            //   }
                            // if (parsedValues[4] == 1) {
                            //   _containerColor_1 = Colors.green;
                            // }else if (parsedValues[4] == 0)
                            //   {_containerColor_1 = Colors.red;}

                            //}

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: SCS(
                                        value:
                                            snapshot.data?['receivedValue1']
                                                .toDouble() ??
                                            0.0,
                                        unit:
                                            SCS_dv_1.isEmpty ? '˚C' : SCS_dv_1,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_1.isEmpty
                                                ? 'Temp 1'
                                                : SCS_title_1,
                                        editingControllerTitle:
                                            _editingSCS_title_1,
                                        editingControllerUnit: _editingSCS_dv_1,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                    Expanded(
                                      child: SCS(
                                        value:
                                            snapshot.data?['receivedValue2']
                                                .toDouble() ??
                                            0.0,
                                        unit: SCS_dv_2.isEmpty ? '%' : SCS_dv_2,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_2.isEmpty
                                                ? 'Humidity 2'
                                                : SCS_title_2,
                                        editingControllerTitle:
                                            _editingSCS_title_2,
                                        editingControllerUnit: _editingSCS_dv_2,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: SCS(
                                        value:
                                            snapshot.data?['receivedValue3']
                                                .toDouble() ??
                                            0.0,
                                        unit:
                                            SCS_dv_3.isEmpty ? '˚C' : SCS_dv_3,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_3.isEmpty
                                                ? 'Temp 3'
                                                : SCS_title_3,
                                        editingControllerTitle:
                                            _editingSCS_title_3,
                                        editingControllerUnit: _editingSCS_dv_3,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                    Expanded(
                                      child: SCS(
                                        value:
                                            snapshot.data?['receivedValue4']
                                                .toDouble() ??
                                            0.0,
                                        unit: SCS_dv_4.isEmpty ? '%' : SCS_dv_4,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_4.isEmpty
                                                ? 'Humtidity 4'
                                                : SCS_title_4,
                                        editingControllerTitle:
                                            _editingSCS_title_4,
                                        editingControllerUnit: _editingSCS_dv_4,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: SCS(
                                        value: 0,
                                        unit:
                                            SCS_dv_1.isEmpty ? '˚C' : SCS_dv_1,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_1.isEmpty
                                                ? 'Temp 1'
                                                : SCS_title_1,
                                        editingControllerTitle:
                                            _editingSCS_title_1,
                                        editingControllerUnit: _editingSCS_dv_1,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                    Expanded(
                                      child: SCS(
                                        value: 0,
                                        unit: SCS_dv_2.isEmpty ? '%' : SCS_dv_2,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_2.isEmpty
                                                ? 'Humidity 2'
                                                : SCS_title_2,
                                        editingControllerTitle:
                                            _editingSCS_title_2,
                                        editingControllerUnit: _editingSCS_dv_2,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: SCS(
                                        value: 0,
                                        unit:
                                            SCS_dv_3.isEmpty ? '˚C' : SCS_dv_3,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_3.isEmpty
                                                ? 'Temp 3'
                                                : SCS_title_3,
                                        editingControllerTitle:
                                            _editingSCS_title_3,
                                        editingControllerUnit: _editingSCS_dv_3,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          _delayedLoadSettings();
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                    Expanded(
                                      child: SCS(
                                        value: 0,
                                        unit: SCS_dv_4.isEmpty ? '%' : SCS_dv_4,
                                        trackColor: Colors.amber,
                                        progressBarColor: Colors.orange,
                                        min: 0,
                                        max: 100,
                                        trackWidth: 5,
                                        progressBarWidth: 20,
                                        bottomLabelText:
                                            SCS_title_4.isEmpty
                                                ? 'Humtidity 4'
                                                : SCS_title_4,
                                        editingControllerTitle:
                                            _editingSCS_title_4,
                                        editingControllerUnit: _editingSCS_dv_4,
                                        onPress: () {
                                          _saveSettings();
                                          Navigator.pop(context);
                                          setState(() {
                                            _delayedLoadSettings();
                                          });
                                        },
                                        size: const Size(200, 200),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                Text("Light & Switch 1"),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                      color:
                                          _bluetoothService.connection !=
                                                      null &&
                                                  _bluetoothService
                                                      .connection!
                                                      .isConnected &&
                                                  switch1
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ATSwitch(
                                  current: switch1,
                                  first: false,
                                  second: true,
                                  spacing: 50,
                                  onChanged: (valueSwitch) {
                                    setState(() {
                                      switch1 = valueSwitch;
                                      if (switch1) {
                                        _bluetoothService.sendMessage(
                                          _ControllerSwitch1_On,
                                        );
                                        // Fluttertoast.showToast(
                                        //     msg: _ControllerSwitch1_On);
                                        print(_ControllerSwitch1_On);
                                      } else {
                                        _bluetoothService.sendMessage(
                                          _ControllerSwitch1_Off,
                                        );
                                        // Fluttertoast.showToast(
                                        //     msg: _ControllerSwitch1_Off);
                                        print(_ControllerSwitch1_Off);
                                      }
                                    });
                                  },
                                  titleSwitchTrue: 'ON',
                                  titleSwitchFalse: 'OFF',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                Text("Light & Switch 2"),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                      color:
                                          _bluetoothService.connection !=
                                                      null &&
                                                  _bluetoothService
                                                      .connection!
                                                      .isConnected &&
                                                  switch2
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ATSwitch(
                                  current: switch2,
                                  first: false,
                                  second: true,
                                  spacing: 50,
                                  onChanged: (valueSwitch) {
                                    setState(() {
                                      switch2 = valueSwitch;
                                      if (switch2) {
                                        _bluetoothService.sendMessage(
                                          _ControllerSwitch2_On,
                                        );
                                        // Fluttertoast.showToast(
                                        //     msg: _ControllerSwitch2_On);
                                        print(_ControllerSwitch1_On);
                                      } else {
                                        _bluetoothService.sendMessage(
                                          _ControllerSwitch2_Off,
                                        );
                                        // Fluttertoast.showToast(
                                        //     msg: _ControllerSwitch2_Off);
                                        print(_ControllerSwitch2_Off);
                                      }
                                    });
                                  },
                                  titleSwitchTrue: 'ON',
                                  titleSwitchFalse: 'OFF',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
    );
  }
}
