import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // để điều khiển orientation
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanQRWidget extends StatefulWidget {
  final Function(String) onScanComplete;

  const ScanQRWidget({super.key, required this.onScanComplete});

  @override
  _ScanQRWidgetState createState() => _ScanQRWidgetState();
}

class _ScanQRWidgetState extends State<ScanQRWidget> {
  String? _scanQRres;
  final List<String> _qrCodes = [];

  //hàm quét QR 1 lần và lưu data vào _qrCodes
  Future<void> scanQRcodeOnce() async {
    String scanData = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (scanData != '-1') {
      // '-1' indicates that the user cancelled the scan
      setState(() {
        _qrCodes.add(scanData);
      });
    }
  }

  Future<void> scanQRcodeStream() async {
    // Chuyển sang portrait tạm thời
    // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // await Future.delayed(const Duration(seconds: 2));

    bool isScanning = false;

    FlutterBarcodeScanner.getBarcodeStreamReceiver(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    )!.listen((scanData) async {
      if (!isScanning) {
        isScanning = true;

        setState(() {
          _scanQRres = scanData;
          widget.onScanComplete(scanData);
        });

        // await Future.delayed(const Duration(seconds: 1));

        // setState(() {
        //   // _scanQRres = null;
        // });

        isScanning = false;

        // // Trả về landscape sau khi quét xong
        // await SystemChrome.setPreferredOrientations([
        //   DeviceOrientation.landscapeLeft,
        //   DeviceOrientation.landscapeRight,
        // ]);
      }
    });
  }

  // Hàm chơi tất cả các QR đã quét được lưu trong _qrCodes
  Future<void> playQRcodes() async {
    for (String code in _qrCodes) {
      widget.onScanComplete(code);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    setState(() {
      _qrCodes.clear(); // Clear the list after sending all messages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildQRButton(
                'Scan QR Code stream',
                const Color.fromARGB(255, 244, 67, 54),
                scanQRcodeStream,
              ),
              const SizedBox(width: 30),
              buildQRButton(
                'Add QR Code',
                const Color.fromARGB(255, 255, 235, 59),
                scanQRcodeOnce,
              ),
              const SizedBox(width: 30),
              buildQRButton(
                'Play QR Codes 📤',
                const Color.fromARGB(255, 76, 175, 79),
                playQRcodes,
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scanned QR Codes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _qrCodes.join(', '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQRButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 200,
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
