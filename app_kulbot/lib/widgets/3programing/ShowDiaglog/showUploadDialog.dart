import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<void> showUploadDialog({
  required BuildContext context,
  required BluetoothDevice device,
  required String generatedCode,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) =>
            _UploadDialog(device: device, generatedCode: generatedCode),
  );
}

class _UploadDialog extends StatefulWidget {
  final BluetoothDevice device;
  final String generatedCode;

  const _UploadDialog({
    // super.key,
    required this.device,
    required this.generatedCode,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final List<String> log = [];
  bool isUploading = true;
  late BluetoothCharacteristic _writeChar;
  late BluetoothCharacteristic _notifyChar;
  StreamSubscription<List<int>>? _notifySubscription;
  final ScrollController _scrollController = ScrollController();
  late int totalLines = widget.generatedCode.split('\n').length;
  bool Firmware = false;

  final Guid writeCharUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  @override
  void initState() {
    super.initState();
    totalLines = widget.generatedCode.split('\n').length;
    _setupAndUpload();
  }

  late String upload_progress = "";

  Future<void> _setupAndUpload() async {
    try {
      log.add("🔌 Checking connection...");

      // Nếu chưa kết nối, thì kết nối
      if (widget.device.connectionState != BluetoothConnectionState.connected) {
        log.add("📡 Connecting to device...");
        await widget.device.connect(timeout: const Duration(seconds: 10));
      }

      log.add("✅Connected. Searching for service...");

      final services = await widget.device.discoverServices();
      if (services.isEmpty) {
        setState(() => log.add("❌ No services found on the device."));
        return;
      }

      for (var s in services) {
        for (var c in s.characteristics) {
          if (c.uuid == writeCharUuid) _writeChar = c;
          if (c.uuid == notifyCharUuid) _notifyChar = c;
        }
      }

      // if (_writeChar == null || _notifyChar == null) {
      //   setState(() => log.add("❌ Không tìm thấy UUID ghi hoặc notify."));
      //   return;
      // }

      // log.add("✅ Tìm thấy đặc tính ghi và notify.");
      await _notifyChar.setNotifyValue(true);
      _notifySubscription = _notifyChar.onValueReceived.listen((data) {
        final msg = utf8.decode(data);
        if (msg == ".") {
          setState(() {
            upload_progress += msg;
            // log[log.length - 1] = upload_progress;
          });
        } else {
          if (msg.toLowerCase().contains("firmware")) {
            Firmware = true;
          }
          setState(() => log.add("📥 esp response: $msg"));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
            );
          }
        });
      });

      await _uploadCode(widget.generatedCode);
    } catch (e) {
      if (isUploading) {
        setState(() => log.add("❌ Error in setup: $e"));
      }
    }
  }

  int calculateCrc16Ccitt(
    List<int> data, {
    int polynomial = 0x1021, // ✅ chuẩn CRC-16/CCITT-FALSE
    int initial = 0xFFFF,
  }) {
    int crc = initial;

    for (final byte in data) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ polynomial) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc & 0xFFFF;
  }

  Future<void> writeLong(List<int> data) async {
    const int chunkSize = 244; // BLE giới hạn payload
    for (int i = 0; i < data.length; i += chunkSize) {
      final chunk = data.sublist(
        i,
        (i + chunkSize > data.length) ? data.length : i + chunkSize,
      );
      await _writeChar.write(chunk);
      await Future.delayed(
        const Duration(milliseconds: 5),
      ); // Giúp ESP xử lý kịp
    }
  }

  Future<void> _uploadCode(String code) async {
    if (!isUploading) return;

    final List<String> lines = code.split('\n');
    final BytesBuilder sentBytes = BytesBuilder();

    await writeLong(utf8.encode("upload\n"));
    // setState(() => log.add("📤 bên app báo: upload"));

    for (final line in lines) {
      if (!isUploading) break;

      final trimmed = line.trimRight(); // giống ESP: rstrip()
      final finalLine = trimmed + '\n'; // ESP sau đó + '\n'
      final lineBytes = utf8.encode(finalLine);

      sentBytes.add(lineBytes);
      setState(() => log.add("📤 app side: $finalLine"));
      await writeLong(lineBytes);
    }

    final crc = calculateCrc16Ccitt(sentBytes.toBytes());
    final crcHex = crc.toRadixString(16).padLeft(4, '0').toUpperCase();

    setState(() => log.add("📤 app side: crc:$crcHex"));
    await writeLong(utf8.encode("crc:$crcHex\n"));

    setState(() {
      log.add("📤 app side: done");
      isUploading = false;
    });
    await writeLong(utf8.encode("done\n"));
  }

  @override
  void dispose() {
    _notifySubscription?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    double progress =
        (totalLines == 0)
            ? 0
            : (upload_progress.length / totalLines).clamp(0.0, 1.0);

    return AlertDialog(
      title: const Text("Uploading code..."),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: log.length,
          itemBuilder: (_, i) => Text(log[i]),
        ),
      ),
      actions: [
        Row(
          children: [
            // ✅ Thanh tiến độ
            Expanded(child: LinearProgressIndicator(value: progress)),
            const SizedBox(width: 16),
            // ✅ Nút
            if (isUploading)
              TextButton(
                onPressed: () => setState(() => isUploading = false),
                child: const Text("Stop"),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  Firmware ? "Done" : "Close",
                  style: TextStyle(
                    color:
                        Firmware
                            ? const Color.fromARGB(255, 76, 175, 79)
                            : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
