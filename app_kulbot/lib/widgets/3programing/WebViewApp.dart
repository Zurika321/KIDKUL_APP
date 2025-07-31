// import 'dart:convert';
import 'dart:async';

// import 'package:KulBlock/service/bluetooth_service.dart';
import 'package:KulBlock/provider/CustomInputField.dart';
import 'package:KulBlock/widgets/3programing/ShowDiaglog/showBluetoothScanDialog.dart';
import 'package:KulBlock/widgets/3programing/ShowDiaglog/showUploadDialog.dart';
import 'package:KulBlock/widgets/3programing/ShowDiaglog/showTerminalDialog.dart';
// import 'package:KulBlock/widgets/programing/screen/Terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blockly_plus/flutter_blockly_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../provider/Sample&Data/SaveProjectPrograming.dart'; //class lưu project , lấy tất cả project qua class ProgamingLayoutProvider

import 'package:KulBlock/widgets/3programing/content.dart';

import 'package:provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
import 'package:KulBlock/provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart

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
              TabBar(tabs: [Tab(text: 'Save new'), Tab(text: 'Overwrite ')]),
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
                            labelText: "Name Project",
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
                          child: const Text('Save'),
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
                                      title: const Text("Confirm"),
                                      content: Text(
                                        'Overwrite project "$name"?',
                                      ),
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
                                          child: const Text("Confirm"),
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
          SnackBar(content: Text('No data found from project: $name.')),
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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                label: const Text(
                                  "New",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
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
                                          ? const Color.fromARGB(
                                            255,
                                            244,
                                            244,
                                            244,
                                          )
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
                                            color: Color.fromARGB(
                                              255,
                                              76,
                                              175,
                                              79,
                                            ),
                                          )
                                          : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // COPY
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        color: const Color.fromARGB(
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
                                            okColor: const Color.fromARGB(
                                              255,
                                              33,
                                              149,
                                              243,
                                            ),
                                            cancelColor: const Color.fromARGB(
                                              255,
                                              158,
                                              158,
                                              158,
                                            ),
                                          );
                                        },
                                      ),

                                      // EDIT
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: const Color.fromARGB(
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
                                            okColor: const Color.fromARGB(
                                              255,
                                              68,
                                              137,
                                              255,
                                            ),
                                            cancelColor: const Color.fromARGB(
                                              255,
                                              158,
                                              158,
                                              158,
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(
                                            255,
                                            244,
                                            67,
                                            54,
                                          ),
                                        ),
                                        tooltip: "Delete",
                                        onPressed: () {
                                          if (work_area.length > 1) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (ctx) => AlertDialog(
                                                    title: const Text(
                                                      "Delete Blockly",
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete "${area.name}"?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(),
                                                        child: const Text(
                                                          "Cancel",
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
                                                          "Delete",
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
                        color: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                117,
                                117,
                                117,
                              ),
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
                                color: Color.fromARGB(255, 255, 255, 255),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheetContent(
          title: title,
          controllers: [
            TextInputField<String>(
              label: "New Name",
              controller: controller,
              minlength: 1,
              maxlength: 50,
            ),
          ],
          onOk: (result) {
            final name = result["New Name"] as String;
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
    'grid': {'spacing': 0, 'length': 0, 'colour': '#cc1', 'snap': true},
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

  void onDispose(BlocklyData data) {
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
                Navigator.of(context).pop(true);
                // Navigator.of(context).pop();
              } else {
                // Hiện dialog xác nhận lưu
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Layout not saved"),
                        content: const Text(
                          "Do you want to save the layout before exiting?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pop();
                              // Navigator.of(context).pop();
                            },
                            child: const Text("No"),
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
                                  Navigator.of(context).pop(true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Layout "$savedName" saved successfully!',
                                      ),
                                    ),
                                  );
                                },
                                onOverwrite: (String name) async {
                                  final success =
                                      await ProgamingLayoutProvider.updateLayout(
                                        name,
                                        work_area,
                                      );
                                  if (success) {
                                    Navigator.of(context).pop(true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✅ Successfully overwritten layout "$name"!',
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Cannot override layout "$name"!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            child: const Text("Yes"),
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
            thumbColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 0, 0, 0),
            ),
            trackColor: MaterialStateProperty.resolveWith<Color>((states) {
              return isSwitched
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 255, 255, 255);
            }),
            thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
              return Icon(
                isSwitched ? Icons.code : Icons.extension,
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 16,
              );
            }),
          ),
          if (bluetoothOn) ...[
            SizedBox(width: size.width * 0.04),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (selectedDevice == null) return;
                showTerminalBottomSheet(
                  context: context,
                  device: selectedDevice!,
                );
              },
            ),
          ],
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
                      content: Text(
                        '✅ Layout "$savedName" saved successfully!',
                      ),
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
                        content: Text(
                          '✅ Successfully overwritten layout "$name"!',
                        ),
                      ),
                    );
                    setState(() {
                      haveSave = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Cannot override layout "$name"!'),
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
                      content: Text("Device not connected or no code"),
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
              color:
                  bluetoothOn
                      ? const Color.fromARGB(255, 68, 137, 255)
                      : const Color.fromARGB(255, 239, 83, 80),
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
                color: const Color.fromARGB(230, 255, 255, 255),
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
                                          color: Color.fromARGB(
                                            255,
                                            158,
                                            158,
                                            158,
                                          ),
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
                    const SnackBar(content: Text("✅ Code copied successfully")),
                  );
                },
                label: const Text("Copy Code"),
                icon: const Icon(Icons.copy),
                backgroundColor: const Color.fromARGB(255, 68, 137, 255),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockly(List<String> addons) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // final isDarkMode = themeNotifier.isDarkMode;
    return RepaintBoundary(
      child: BlocklyEditorWidget(
        key: _editorKey,
        workspaceConfiguration: workspaceConfiguration,

        //         style:
        //             isDarkMode
        //                 ? '''
        // .blocklyWorkspace { background-color: #202125 !important; }
        // .blocklyToolboxDiv { background-color: #888 !important; }
        // .blocklyFlyoutBackground { background-color: #888 !important; color: #fff !important; }
        // .blocklyFlyoutBackground * { color: #fff !important; }
        // .blocklyScrollbarHorizontal, .blocklyScrollbarVertical { background: #444 !important; }
        // .blocklyScrollbarHandle { background: #888 !important; }
        // .blocklyScrollbarBackground { background: #333 !important; }
        // .blocklyScrollbarCorner { background: #eae !important; }
        // '''
        //                 : /* tương tự nhưng dùng màu sáng */ '''
        // .blocklyWorkspace { background-color: #ffffff !important; }
        // .blocklyToolboxDiv { background-color: #f0f0f0 !important; }
        // .blocklyFlyoutBackground { background-color: #f0f0f0 !important; color: #000 !important; }
        // .blocklyFlyoutBackground * { color: #000 !important; }
        // .blocklyScrollbarHorizontal, .blocklyScrollbarVertical { background: #cccc !important; }
        // .blocklyScrollbarHandle { background: #fff !important; }
        // .blocklyScrollbarBackground { background: #fff !important; }
        // .blocklyScrollbarCorner { background: transparent !important; }
        // ''',
        initial: _xmlworkspace,
        onChange: onChange,
        onError: onError,
        addons: addons,
        debug: false,
      ),
    );
  }
}
