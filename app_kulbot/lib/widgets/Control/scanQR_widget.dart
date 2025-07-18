import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
    // String scanData = await FlutterBarcodeScanner.scanBarcode(
    //     '#ff6666', 'Cancel', true, ScanMode.QR);

    // if (scanData != '-1') {
    //   // '-1' indicates that the user cancelled the scan
    //   setState(() {
    //     _qrCodes.add(scanData);
    //
    //   });
    // }
  }

  // hàm quét  QR dạng stream và gửi data
  Future<void> scanQRcodeStream() async {
    bool isScanning = false; // Biến theo dõi trạng thái quét

    // FlutterBarcodeScanner.getBarcodeStreamReceiver(
    //         '#ff6666', 'Cancel', true, ScanMode.QR)!
    //     .listen((scanData) async {
    //   if (!isScanning) {
    //     isScanning = true; // Đặt trạng thái quét là đang quét
    //
    //     setState(() {
    //       _scanQRres = scanData;
    //       widget.onScanComplete(scanData);
    //     });
    //
    //     // Delay for 1 second để đảm bảo quét xong
    //     await Future.delayed(Duration(seconds: 1));
    //
    //     setState(() {
    //       _scanQRres = null; // Xóa dữ liệu sau khi delay
    //     });
    //
    //     isScanning = false; // Đặt lại trạng thái quét
    //   }
    // });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: scanQRcodeStream,
                    child: const Text(
                      'Scan QR Code stream',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: scanQRcodeOnce,
                    child: const Text(
                      'Add QR Code ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: playQRcodes,
                    child: const Text(
                      'Play QR Codes 📤',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text('Scanned QR Codes: ${_qrCodes.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
