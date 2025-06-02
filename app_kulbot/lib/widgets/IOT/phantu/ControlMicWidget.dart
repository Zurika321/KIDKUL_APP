import 'package:Kulbot/widgets/Control/Control.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; //mic
import 'dart:async'; //báo có sử dụng chờ đợi
import 'package:Kulbot/widgets/IOT/Sample&Data/ControlValueManager.dart';

class MicWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final void Function(Map<String, dynamic>) onSave;
  final VoidCallback onDelete;
  final bool lock;
  final Size size;
  final Future<void> Function(String msg)? voiceTextToCommand;

  MicWidget({
    super.key,
    required this.config,
    required this.onSave,
    required this.onDelete,
    required this.lock,
    required this.size,
    required this.voiceTextToCommand,
  });

  @override
  State<MicWidget> createState() => _MicWidgetState();
}

class _MicWidgetState extends State<MicWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String voicetotext = "...";
  String _previousText = "";
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  String get _languageCode => widget.config["languageCode"] ?? "en";

  String _getLocaleId(String code) {
    switch (code) {
      case 'vi':
        return 'vi_VN';
      case 'en':
      default:
        return 'en_US';
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
        _previousText = "";
        voicetotext = "";

        _speech.listen(
          localeId: _getLocaleId(_languageCode),
          onResult: (val) {
            _debounce?.cancel();

            _debounce = Timer(Duration(milliseconds: 500), () {
              String newPart =
                  val.recognizedWords.substring(_previousText.length).trim();
              if (newPart.isNotEmpty) {
                setState(() {
                  voicetotext = newPart;
                });
                sendCommand(newPart.toLowerCase());
              }
              _previousText = val.recognizedWords;
            });
          },
        );
      } else {
        print("Không thể bật mic.");
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      voicetotext = "...";
      sendCommand("...");
    });
  }

  void sendCommand(String command) {
    widget.voiceTextToCommand?.call(command);
    if (ControlValueManager.hasValue("BoxVoiceText1_voice")) {
      ControlValueManager.setValue("BoxVoiceText1_voice", command);
    }
    //nếu có key thì sẽ set giá trị cho key ,key đó tự động tạo khi có phần tử box BoxVoiceText
  }

  void _showSettingsDialog() {
    String selectedLang = _languageCode;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Chọn ngôn ngữ"),
            content: DropdownButton<String>(
              value: selectedLang,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedLang = val);
                }
              },
              items: [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "vi", child: Text("Tiếng Việt")),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  widget.onSave({"languageCode": selectedLang});
                  Navigator.pop(context);
                },
                child: Text("Lưu"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: !widget.lock ? _showSettingsDialog : null,
      onTap: widget.lock ? _listenVoiceToText : null,
      child: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.cyanAccent,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.cyanAccent,
          onPressed: _listenVoiceToText,
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
