import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<void> showTerminalBottomSheet({
  required BuildContext context,
  required BluetoothDevice device,
}) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return TerminalBottomSheet(device: device);
    },
  );
}

class TerminalBottomSheet extends StatefulWidget {
  final BluetoothDevice device;

  const TerminalBottomSheet({super.key, required this.device});

  @override
  State<TerminalBottomSheet> createState() => _TerminalBottomSheetState();
}

class _TerminalBottomSheetState extends State<TerminalBottomSheet> {
  final List<_Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late BluetoothCharacteristic _writeChar;
  late BluetoothCharacteristic _notifyChar;
  StreamSubscription<List<int>>? _notifySubscription;

  final Guid writeCharUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  bool connected = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _setupBluetooth();
  }

  Future<void> _setupBluetooth() async {
    try {
      if (widget.device.connectionState != BluetoothConnectionState.connected) {
        await widget.device.connect(timeout: const Duration(seconds: 10));
      }

      final services = await widget.device.discoverServices();
      for (var s in services) {
        for (var c in s.characteristics) {
          if (c.uuid == writeCharUuid) _writeChar = c;
          if (c.uuid == notifyCharUuid) _notifyChar = c;
        }
      }

      await _notifyChar.setNotifyValue(true);
      _notifySubscription = _notifyChar.onValueReceived.listen((data) {
        final msg = utf8.decode(data);
        setState(() {
          messages.add(_Message(msg, false));
        });
        _scrollToBottom();
      });

      setState(() {
        connected = true;
        loading = false;
      });
    } catch (e) {
      setState(() {
        messages.add(_Message("❌ Error: $e", false));
        loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendCommand(String text) async {
    if (!connected || text.isEmpty) return;
    try {
      final bytes = utf8.encode(text + "\n");
      await _writeChar.write(bytes, withoutResponse: false);
      setState(() {
        messages.add(_Message(text, true));
        _controller.clear();
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(_Message("❌ Failed to send: $e", false));
      });
    }
  }

  @override
  void dispose() {
    _notifySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal),
                  SizedBox(width: 8),
                  Text(
                    "Terminal Chat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child:
                    loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (_, index) {
                            final msg = messages[index];
                            return Align(
                              alignment:
                                  msg.sentByUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      msg.sentByUser
                                          ? Colors.blue[100]
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(msg.text),
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendCommand,
                      decoration: const InputDecoration(
                        hintText: "Nhập lệnh...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendCommand(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Message {
  final String text;
  final bool sentByUser;

  _Message(this.text, this.sentByUser);
}
