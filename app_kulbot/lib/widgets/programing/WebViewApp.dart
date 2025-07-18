// import 'dart:convert';
import 'dart:async';

// import 'package:Kulbot/service/bluetooth_service.dart';
import 'package:Kulbot/widgets/programing/ShowDiaglog/showBluetoothScanDialog.dart';
import 'package:Kulbot/widgets/programing/ShowDiaglog/showUploadDialog.dart';
// import 'package:Kulbot/widgets/programing/screen/Terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blockly_plus/flutter_blockly_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import './SaveProjectPrograming.dart'; //class lưu project , lấy tất cả project qua class ProgamingLayoutProvider

import 'package:Kulbot/widgets//programing/content.dart';

void showSaveDialog(
  BuildContext context, {
  required Function(String) onSaveNew,
  required Function(String) onOverwrite,
}) async {
  final savedLayouts = await ProgamingLayoutProvider.getSavedLayoutNames();
  final TextEditingController controller = TextEditingController(
    text: "United",
  );

  showDialog(
    context: context,
    builder: (_) {
      return DefaultTabController(
        length: 2,
        child: AlertDialog(
          titlePadding: const EdgeInsets.only(
            left: 24,
            top: 20,
            right: 24,
            bottom: 0,
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text('Lưu dự án'),
              // SizedBox(height: 8),
              TabBar(tabs: [Tab(text: 'Lưu mới'), Tab(text: 'Ghi đè')]),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          content: SizedBox(
            width: 400,
            child: SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  // Tab 1: Lưu mới
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: "Tên dự án",
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            final name = controller.text.trim();
                            if (name.isNotEmpty) {
                              onSaveNew(name);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Lưu'),
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Ghi đè
                  SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: savedLayouts.length,
                      itemBuilder: (context, index) {
                        final name = savedLayouts[index];
                        return ListTile(
                          title: Text(name),
                          trailing: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              // Xác nhận trước khi ghi đè
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Xác nhận"),
                                      content: Text('Ghi đè dự án "$name"?'),
                                      actions: [
                                        // TextButton(
                                        //   onPressed:
                                        //       () => Navigator.of(context).pop(),
                                        //   child: const Text("Huỷ"),
                                        // ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // xác nhận
                                            Navigator.of(
                                              context,
                                            ).pop(); // dialog chính
                                            onOverwrite(name);
                                          },
                                          child: const Text("Xác nhận"),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () => Navigator.pop(context),
          //     child: const Text("Đóng"),
          //   ),
          // ],
        ),
      );
    },
  );
}

class WebViewApp extends StatefulWidget {
  final String? projectName;

  const WebViewApp({Key? key, this.projectName}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  bool isSwitched = false; // show code

  String _generatedCode = '';
  String _xmlworkspace = '';
  int work_area_index = 0;
  late List<BlockList> work_area = [];
  Key _editorKey = UniqueKey();
  bool bluetoothOn = false;
  BluetoothDevice? selectedDevice;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initLayout(widget.projectName);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLayout(String? name) async {
    if (name != null) {
      final xml = await ProgamingLayoutProvider.loadLayout(name);
      if (xml.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy dữ liệu từ project: $name.')),
        );
      } else {
        work_area = xml;
        _xmlworkspace = xml[work_area_index].xml;
      }
    } else {
      work_area.add(BlockList(name: "Block 1", xml: initialXml));
      _xmlworkspace = initialXml;
    }
    setState(() {
      _editorKey = UniqueKey();
    });
  }

  void _showProjectModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.5,
                  maxWidth: size.width * 0.85,
                ),
                child: Stack(
                  children: [
                    // Nội dung cuộn (chừa chỗ cho nút Close)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 70,
                      ), // chừa khoảng cho nút Close
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Block list",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text("New"),
                                onPressed: () {
                                  setState(() {
                                    work_area.add(
                                      BlockList(
                                        name: "Block ${work_area.length + 1}",
                                        xml: initialXml,
                                      ),
                                    );
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Duyệt danh sách block
                            ...work_area.asMap().entries.map((entry) {
                              final index = entry.key;
                              final area = entry.value;

                              return Card(
                                color:
                                    work_area_index == index
                                        ? Colors.greenAccent
                                        : Colors.white,
                                child: ListTile(
                                  title: Text(
                                    "${index + 1}. ${area.name} ${work_area_index == index ? "✅" : ""}",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit",
                                        onPressed: () {
                                          _showEditCopyModal(
                                            context,
                                            title: "Rename",
                                            initialValue: area.name,
                                            onOk: (newName) {
                                              if (newName.isEmpty) return;
                                              final nameExists = work_area.any(
                                                (e) =>
                                                    e.name == newName &&
                                                    e.name != area.name,
                                              );
                                              if (nameExists) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Project name already exists!",
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                setState(() {
                                                  work_area[index] = BlockList(
                                                    name: newName,
                                                    xml: area.xml,
                                                  );
                                                });
                                              }
                                            },
                                            okColor: Colors.blueAccent,
                                            cancelColor: Colors.grey,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        tooltip: "Copy",
                                        onPressed: () {
                                          _showEditCopyModal(
                                            context,
                                            title: "Copy as",
                                            initialValue: "${area.name} Copy",
                                            onOk: (newName) {
                                              if (newName.isEmpty) return;
                                              final nameExists = work_area.any(
                                                (e) => e.name == newName,
                                              );
                                              if (nameExists) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Project name already exists!",
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                setState(() {
                                                  work_area.add(
                                                    BlockList(
                                                      name: newName,
                                                      xml: area.xml,
                                                    ),
                                                  );
                                                });
                                              }
                                            },
                                            okColor: Colors.blue,
                                            cancelColor: Colors.grey,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      work_area_index = index;
                                      _xmlworkspace = work_area[index].xml;
                                      _editorKey = UniqueKey();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Nút Close cố định ở dưới cùng
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text("Close"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // edit and copy
  void _showEditCopyModal(
    BuildContext context, {
    required String title,
    required String initialValue,
    required void Function(String) onOk,
    Color? okColor,
    Color? cancelColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return EditCopyModal(
          title: title,
          initialValue: initialValue,
          onOk: onOk,
          okColor: okColor,
          cancelColor: cancelColor,
        );
      },
    );
  }

  final BlocklyOptions workspaceConfiguration = BlocklyOptions.fromJson(const {
    'grid': {'spacing': 0, 'length': 0, 'colour': '#ccc', 'snap': true},
    'toolbox': initialToolboxJson,
    // null safety example
    'collapse': null,
    'comments': null,
    'css': null,
    'disable': null,
    'horizontalLayout': null,
    'maxBlocks': null,
    'maxInstances': null,
    'media': null,
    'modalInputs': null,
    'move': null,
    'oneBasedIndex': null,
    'readOnly': null,
    'renderer': 'zelos',
    'rendererOverrides': null,
    'rtl': null,
    'scrollbars': null,
    'sounds': null,
    'theme': null,
    'toolboxPosition': null,
    'trashcan': false,
    'maxTrashcanContents': null,
    'plugins': null,
    'zoom': {
      'controls': true,
      'wheel': true,
      'startScale': 0.5,
      'maxScale': 1,
      'minScale': 0.2,
      'scaleSpeed': 1.1,
    },
    'parentWorkspace': null,
  });

  // void onInject(BlocklyData data) {}

  void onChange(BlocklyData data) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      var codenew = "";
      if (data.js != null && data.js!.isNotEmpty && data.python != null) {
        const importHeader = "import kulbot\n\nRob = kulbot.KULBOT() \n\n";
        codenew = importHeader + data.python!;
      }

      if (codenew.trim() != _generatedCode.trim()) {
        setState(() {
          _generatedCode = codenew;
          work_area[work_area_index].xml =
              data.xml ??
              '<xml xmlns="https://developers.google.com/blockly/xml"></xml>';
        });
      }
    });
  }

  void onDispose(BlocklyData data) {}

  void onError(dynamic err) {
    debugPrint('onError: $err');
  }

  Future<List<String>> loadAddons() async {
    List<String> addons = [];

    addons.add(await rootBundle.loadString("assets/blocks/kulbot_block.js"));
    addons.add(await rootBundle.loadString("assets/blocks/kulbot_vm_js.js"));
    addons.add(
      await rootBundle.loadString("assets/blocks/kulbot_vm_python.js"),
    );
    return addons;
  }

  void _showScanDialog() async {
    final device = await showBluetoothScanDialog(context);
    if (device != null) {
      setState(() {
        selectedDevice = device;
        bluetoothOn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        // title: const Icon(Icons.house, size: 30, color: Colors.white),
        backgroundColor: Color(0xFF6DBCFF),
        actions: [
          Switch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
            },
            thumbColor: MaterialStateProperty.all(Colors.black),
            trackColor: MaterialStateProperty.resolveWith<Color>((states) {
              return isSwitched ? Colors.white : Colors.white;
            }),
            thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
              return Icon(
                isSwitched ? Icons.code : Icons.extension,
                color: Colors.white,
                size: 16,
              );
            }),
          ),
          SizedBox(width: size.width * 0.04),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              showSaveDialog(
                context,
                onSaveNew: (String name) async {
                  final savedName = await ProgamingLayoutProvider.saveLayout(
                    name,
                    work_area, // có thể mở rộng nhiều block sau
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Đã lưu layout "$savedName" thành công!'),
                    ),
                  );
                },
                onOverwrite: (String name) async {
                  final success = await ProgamingLayoutProvider.updateLayout(
                    name,
                    work_area,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Đã ghi đè layout "$name" thành công!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Không thể ghi đè layout "$name"!'),
                      ),
                    );
                  }
                },
              );
            },
          ),
          if (bluetoothOn) SizedBox(width: size.width * 0.02),
          if (bluetoothOn)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              tooltip: "Upload Code",
              onPressed: () {
                if (selectedDevice != null &&
                    _generatedCode.trim().isNotEmpty) {
                  showUploadDialog(
                    context: context,
                    device: selectedDevice!,
                    generatedCode: _generatedCode,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Thiết bị chưa kết nối hoặc không có code"),
                    ),
                  );
                }
              },
            ),
          SizedBox(width: size.width * 0.02),
          IconButton(
            icon: Icon(
              bluetoothOn
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: bluetoothOn ? Colors.blueAccent : Colors.red[400],
            ),
            onPressed: _showScanDialog,
          ),
          SizedBox(width: size.width * 0.02),
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              _showProjectModal(context);
              // menu
            },
          ),
          SizedBox(width: size.width * 0.02),
        ],
      ),
      body: Stack(
        children: [
          // Blockly Editor - luôn hiển thị dưới cùng
          FutureBuilder<List<String>>(
            future: loadAddons(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RepaintBoundary(
                  child: BlocklyEditorWidget(
                    key: _editorKey,
                    workspaceConfiguration: workspaceConfiguration,
                    initial: _xmlworkspace,
                    onChange: onChange,
                    onError: onError,
                    addons: snapshot.data!,
                    debug: false,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return const SizedBox.shrink();
            },
          ),

          // Code viewer (nổi lên trên khi isSwitched = true)
          if (isSwitched)
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white.withOpacity(
                  0.98,
                ), // Có thể chỉnh lại opacity
                child:
                    _generatedCode.isNotEmpty
                        ? Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(
                                      '\n'.allMatches(_generatedCode).length +
                                          1,
                                      (index) => Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Monospace',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          60,
                                    ),
                                    child: SelectableText(
                                      _generatedCode,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Monospace',
                                      ),
                                      textAlign: TextAlign.left,
                                      textWidthBasis:
                                          TextWidthBasis.longestLine,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}

class EditCopyModal extends StatefulWidget {
  final String title;
  final String initialValue;
  final void Function(String) onOk;
  final Color? okColor;
  final Color? cancelColor;

  const EditCopyModal({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onOk,
    this.okColor,
    this.cancelColor,
  });

  @override
  State<EditCopyModal> createState() => _EditCopyModalState();
}

class _EditCopyModalState extends State<EditCopyModal>
    with WidgetsBindingObserver {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  bool isInputFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = TextEditingController(text: widget.initialValue);

    focusNode.addListener(() {
      setState(() {
        isInputFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Đây mới là logic đúng, kết hợp bàn phím và trạng thái focus
    final shouldBeFocused = focusNode.hasFocus && isKeyboardOpen;

    if (shouldBeFocused != isInputFocused) {
      setState(() {
        isInputFocused = shouldBeFocused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: size.width * 0.4,
                          maxWidth: size.width * 0.6,
                          maxHeight:
                              constraints.maxHeight -
                              80, // chừa chỗ cho bàn phím
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 60),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: widget.cancelColor,
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: widget.okColor,
                                      ),
                                      onPressed: () {
                                        widget.onOk(controller.text.trim());
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Input nổi khi có focus
              Positioned(
                top: isInputFocused ? 0 : size.height / 2 - 80,
                left: isInputFocused ? 0 : size.width / 2 - 120,
                right: isInputFocused ? 0 : null,
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  child: Row(
                    children: [
                      SizedBox(
                        width: isInputFocused ? size.width - 100 : 200,
                        height: 40,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (isInputFocused)
                        SizedBox(
                          width: 50,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: const Icon(Icons.keyboard_hide),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
