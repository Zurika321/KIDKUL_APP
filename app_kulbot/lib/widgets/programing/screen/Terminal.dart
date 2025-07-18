import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleTerminal extends StatefulWidget {
  final BluetoothDevice device;
  final Guid writeCharacteristicUuid;
  final Guid notifyCharacteristicUuid;
  final String? generatedCode;

  const BleTerminal({
    super.key,
    required this.device,
    required this.writeCharacteristicUuid,
    required this.notifyCharacteristicUuid,
    this.generatedCode,
  });

  @override
  State<BleTerminal> createState() => _BleTerminalState();
}

class _BleTerminalState extends State<BleTerminal> {
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  final TextEditingController _inputController = TextEditingController();
  final List<String> _log = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _setup().then((_) {
      // if (widget.generatedCode != null &&
      //     widget.generatedCode!.trim().isNotEmpty) {
      //   uploadCode(widget.generatedCode!);
      // }
    });
  }

  Future<void> _setup() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid == widget.writeCharacteristicUuid) _writeChar = c;
        if (c.uuid == widget.notifyCharacteristicUuid) _notifyChar = c;
      }
    }

    if (_notifyChar != null) {
      await _notifyChar!.setNotifyValue(true);
      _notifyChar!.onValueReceived.listen((data) {
        final msg = utf8.decode(data);
        setState(() => _log.add("📥 $msg"));
      });
    }

    // Tự động upload nếu có generatedCode
    // if (widget.generatedCode != null && widget.generatedCode!.isNotEmpty) {
    //   uploadCode(widget.generatedCode!);
    // }
  }

  Future<void> _send(String message) async {
    if (_writeChar == null || message.trim().isEmpty) return;
    final data = utf8.encode(message + '\r\n');
    await _writeChar!.write(data, withoutResponse: true);
    setState(() => _log.add("📤 $message"));
    _inputController.clear();
  }

  Future<void> uploadCode(String code) async {
    if (_writeChar == null) return;
    setState(() => _isUploading = true);

    List<String> lines = const LineSplitter().convert(code);
    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      print("📤 Gửi dòng: $line");
      final bytes = utf8.encode(line + '\r\n'); // thêm kết thúc dòng

      const int chunkSize = 20;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final chunk = bytes.sublist(
          i,
          (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
        );
        await _writeChar!.write(chunk);
        print("📤 Gửi chunk: ${utf8.decode(chunk)}");
        await Future.delayed(const Duration(milliseconds: 30));
      }

      setState(() => _log.add("📤 $line"));
    }

    setState(() => _isUploading = false);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terminal: ${widget.device.platformName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Xoá log",
            onPressed: () => setState(() => _log.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder:
                  (_, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(_log[index]),
                  ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nhập lệnh...',
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _send(_inputController.text),
                  child: const Text("Gửi"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _isUploading ||
                              widget.generatedCode == null ||
                              widget.generatedCode!.trim().isEmpty
                          ? () => (print("Không có code để upload"))
                          : () => uploadCode(widget.generatedCode!),
                  child:
                      _isUploading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Upload Code"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
