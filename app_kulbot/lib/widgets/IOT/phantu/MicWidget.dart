// MicShowKeyWidget.dart
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:async'; //báo có sử dụng chờ đợi
import 'package:speech_to_text/speech_to_text.dart' as stt; //mic

class MicShowKeyWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Future<void> Function(String msg)? VoiceTextToCommand;
  final bool lock;

  const MicShowKeyWidget({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.VoiceTextToCommand,
    required this.lock,
  });

  @override
  State<MicShowKeyWidget> createState() => _MicShowKeyWidgetState();
}

class _MicShowKeyWidgetState extends State<MicShowKeyWidget> {
  bool _isListening = false;
  String voicetotext = "";
  String _previousText = "";
  Timer? _debounce;
  String _selectedLanguage = 'vi';
  late stt.SpeechToText _speech;

  // Dummy speech object, replace with your actual speech recognition instance
  // final _speech = ...;

  String _getSpeechLocale(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return 'vi_VN';
      case 'en':
      default:
        return 'en_US';
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listenVoiceToText() async {
    final locale = Locale(_selectedLanguage);
    String languageCode = locale.languageCode;

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        _previousText = "";
        voicetotext = "";

        setState(() => _isListening = true);
        await checkLocales();

        _speech.listen(
          localeId: _getSpeechLocale(languageCode),
          onResult: (val) {
            print('🟢 Speech raw: ${val.recognizedWords}');

            _debounce?.cancel();

            // Khởi tạo lại timer — chỉ xử lý sau khi im lặng ~1 giây
            _debounce = Timer(Duration(milliseconds: 500), () {
              String newPart =
                  val.recognizedWords.substring(_previousText.length).trim();

              if (newPart.isNotEmpty) {
                setState(() {
                  voicetotext = newPart;
                  _callVoiceTextToCommand(voicetotext);
                });
              }
              _previousText = val.recognizedWords;
            });
          },
        );
      } else {
        print("Không thể khởi tạo mic.");
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        voicetotext = "...";
        _callVoiceTextToCommand(voicetotext);
      });
    }
  }

  Future<void> checkLocales() async {
    var locales = await _speech.locales();
    for (var locale in locales) {
      print('${locale.localeId} - ${locale.name}');
    }
  }

  void _callVoiceTextToCommand(String msg) {
    if (widget.VoiceTextToCommand != null && msg.isNotEmpty) {
      widget.VoiceTextToCommand!(msg);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempLang = _selectedLanguage;
        return AlertDialog(
          title: const Text('Chọn ngôn ngữ'),
          content: DropdownButton<String>(
            value: tempLang,
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  tempLang = value;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDelete != null) widget.onDelete!();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // setState(() {
                //   _selectedLanguage = tempLang;
                // });//ko cần vì gửi newConfig là nó setState lại rồi
                if (widget.onSave != null) {
                  final newConfig = {
                    ...widget.config,
                    'languageCode': _selectedLanguage,
                  };
                  widget.onSave!(newConfig);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.lock == false ? _showLanguageDialog : null,
      child: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.cyanAccent,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.cyanAccent,
          onPressed: !widget.lock ? _listenVoiceToText : null,
          tooltip:
              voicetotext.isNotEmpty
                  ? voicetotext
                  : _isListening
                  ? "Đang lắng nghe..."
                  : "Nhấn để nói",
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
