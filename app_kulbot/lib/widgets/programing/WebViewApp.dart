// import 'dart:convert';
import 'dart:async';

// import 'package:Kulbot/service/bluetooth_service.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';
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
  late Future<List<String>> _addonsFuture;
  bool haveSave = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _addonsFuture = loadAddons();
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
      haveSave = name != null;
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // bo tròn nhiều hơn
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.5,
                  maxWidth: size.width * 0.6,
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 70),
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Blockly List",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nút NEW
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "New",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    109,
                                    188,
                                    255,
                                  ),
                                  shape:
                                      const StadiumBorder(), // bo tròn hoàn toàn
                                ),
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

                            const SizedBox(height: 20),

                            // Danh sách block
                            ...work_area.asMap().entries.map((entry) {
                              final index = entry.key;
                              final area = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      work_area_index == index
                                          ? Color.fromARGB(255, 244, 244, 244)
                                          : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ListTile(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  title: Text(
                                    "${area.name}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading:
                                      work_area_index == index
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // COPY
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        color: Color.fromARGB(
                                          255,
                                          109,
                                          188,
                                          255,
                                        ),
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

                                      // EDIT
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: Color.fromARGB(
                                          255,
                                          109,
                                          188,
                                          255,
                                        ),
                                        tooltip: "Rename",
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
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: "Delete",
                                        onPressed: () {
                                          if (work_area.length > 1) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (ctx) => AlertDialog(
                                                    title: const Text(
                                                      "Xoá dự án",
                                                    ),
                                                    content: Text(
                                                      'Bạn có chắc muốn xoá "${area.name}"?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(),
                                                        child: const Text(
                                                          "Huỷ",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            work_area.removeAt(
                                                              index,
                                                            );

                                                            if (work_area_index ==
                                                                index) {
                                                              _xmlworkspace =
                                                                  work_area[0]
                                                                      .xml;
                                                              work_area_index =
                                                                  0;
                                                              _editorKey =
                                                                  UniqueKey();
                                                            }
                                                          });
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop();
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          "Xoá",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      work_area_index = index;
                                      _xmlworkspace = area.xml;
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

                    // Nút CLOSE
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                color: Colors.white,
                              ), // << Màu trắng
                            ),
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

  void _showEditCopyModal(
    BuildContext context, {
    required String title,
    required String initialValue,
    required void Function(String) onOk,
    Color? okColor,
    Color? cancelColor,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomDialog(
          title: title,
          controllers: [
            TextInputField<String>(
              label: "Tên mới",
              controller: controller,
              minlength: 1,
              maxlength: 50,
            ),
          ],
          onOk: (result) {
            final name = result["Tên mới"] as String;
            onOk(name);
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
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
      'startScale': 1,
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
        const importHeader =
            "import kulbot\nimport time\n\nRob = kulbot.KULBOT()\n\n";

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
        backgroundColor: const Color.fromARGB(255, 109, 188, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isSwitched) {
              setState(() {
                isSwitched = false;
              });
            } else {
              if (haveSave) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                // Hiện dialog xác nhận lưu
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Chưa lưu layout"),
                        content: const Text(
                          "Bạn có muốn lưu layout trước khi thoát không?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); // đóng dialog xác nhận
                              Navigator.of(context).pop(); // thoát mà không lưu
                            },
                            child: const Text("Không"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); // đóng dialog xác nhận

                              showSaveDialog(
                                context,
                                onSaveNew: (String name) async {
                                  final savedName =
                                      await ProgamingLayoutProvider.saveLayout(
                                        name,
                                        work_area,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Đã lưu layout "$savedName" thành công!',
                                      ),
                                    ),
                                  );

                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                onOverwrite: (String name) async {
                                  final success =
                                      await ProgamingLayoutProvider.updateLayout(
                                        name,
                                        work_area,
                                      );
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✅ Đã ghi đè layout "$name" thành công!',
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Không thể ghi đè layout "$name"!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            child: const Text("Có"),
                          ),
                        ],
                      ),
                );
              }
            }
          },
        ),
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
                  setState(() {
                    haveSave = true;
                  });
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
                    setState(() {
                      haveSave = true;
                    });
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
            future: _addonsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              // ✅ Tách widget lớn ra khỏi FutureBuilder
              return _buildBlockly(snapshot.data!);
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
                                    // child: SelectableText(
                                    child: Text(
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
          if (isSwitched)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Đã copy code thành công")),
                  );
                },
                label: const Text("Copy Code"),
                icon: const Icon(Icons.copy),
                backgroundColor: Colors.blueAccent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockly(List<String> addons) {
    return RepaintBoundary(
      child: BlocklyEditorWidget(
        key: _editorKey,
        workspaceConfiguration: workspaceConfiguration,
        initial: _xmlworkspace,
        onChange: onChange,
        onError: onError,
        addons: addons,
        debug: false,
      ),
    );
  }
}

// class EditCopyModal extends StatefulWidget {
//   final String title;
//   final String initialValue;
//   final void Function(String) onOk;
//   final Color? okColor;
//   final Color? cancelColor;

//   const EditCopyModal({
//     super.key,
//     required this.title,
//     required this.initialValue,
//     required this.onOk,
//     this.okColor,
//     this.cancelColor,
//   });

//   @override
//   State<EditCopyModal> createState() => _EditCopyModalState();
// }

// class _EditCopyModalState extends State<EditCopyModal>
//     with WidgetsBindingObserver {
//   late TextEditingController controller;
//   final FocusNode focusNode = FocusNode();
//   bool isInputFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     controller = TextEditingController(text: widget.initialValue);

//     focusNode.addListener(() {
//       setState(() {
//         isInputFocused = focusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     controller.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeMetrics() {
//     final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
//     final isKeyboardOpen = bottomInset > 0;

//     // Đây mới là logic đúng, kết hợp bàn phím và trạng thái focus
//     final shouldBeFocused = focusNode.hasFocus && isKeyboardOpen;

//     if (shouldBeFocused != isInputFocused) {
//       setState(() {
//         isInputFocused = shouldBeFocused;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.zero,
//       child: SizedBox(
//         width: size.width,
//         height: size.height,
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: Stack(
//             children: [
//               // Hộp nội dung chính
//               Center(
//                 child: RepaintBoundary(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minWidth: size.width * 0.4,
//                       maxWidth: size.width * 0.6,
//                       maxHeight: size.height - 100,
//                     ),
//                     child: Material(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               widget.title,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             const SizedBox(height: 60),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: const StadiumBorder(),
//                                     backgroundColor: widget.cancelColor,
//                                   ),
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: const StadiumBorder(),
//                                     backgroundColor: widget.okColor,
//                                   ),
//                                   onPressed: () {
//                                     widget.onOk(controller.text.trim());
//                                     Navigator.of(context).pop();
//                                   },
//                                   child: const Text("OK"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Input nổi khi có focus
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 top: isInputFocused ? 20 : size.height / 2 - 80,
//                 left: isInputFocused ? 20 : size.width / 2 - 120,
//                 right: isInputFocused ? 20 : null,
//                 child: Material(
//                   color: Colors.white,
//                   elevation: 8,
//                   borderRadius: BorderRadius.circular(8),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: isInputFocused ? size.width - 100 : 200,
//                         height: 40,
//                         child: TextField(
//                           controller: controller,
//                           focusNode: focusNode,
//                           autofocus: true,
//                           decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                             ),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       if (isInputFocused)
//                         SizedBox(
//                           width: 50,
//                           height: 40,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.zero,
//                             ),
//                             onPressed: () {
//                               FocusScope.of(context).unfocus();
//                             },
//                             child: const Icon(Icons.keyboard_hide),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
