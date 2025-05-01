import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blockly_plus/flutter_blockly_plus.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../data/contentPrograming.dart';

import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Programingscreen extends StatefulWidget {
  final bool checkAvailability;
  const Programingscreen({super.key, this.checkAvailability = true});

  @override
  State<Programingscreen> createState() => _ProgramingscreenState();
}

class _ProgramingscreenState extends State<Programingscreen> {

    List<Map<String, dynamic>> blocklyItems = [];
  int? selectedItemIndex; // Index of the currently selected item

  bool _isExpanded = false;
  bool _loadproject = false;
  String _generatedCode = '';
  String _xmlworkspace = '';



  final BlocklyOptions workspaceConfiguration = BlocklyOptions.fromJson(const {
    'grid': {
      'spacing': 12,
      'length': 30,
      'colour': '#b6b6b6',
      'snap': true,
    },
    'toolbox': initialToolboxJson,

    'theme': null,
    // null safety example
    'collapse': null,
    'comments': true,
    'css': null,
    'disable': null,
    'horizontalLayout': null,
    'maxBlocks': 200,
    'maxInstances': null,
    'media': null,
    'modalInputs': null,
    'move': null,
    'oneBasedIndex': null,
    'readOnly': null,
    'renderer': 'zelos',
    'rendererOverrides': null,
    'rtl': null,
    'scrollbars': {
      'horizontal': false,
      'vertical': false,
    },
    'sounds': true,
    'toolboxPosition': null,
    'trashcan': true,
    'maxTrashcanContents': null,
    'plugins': null,
    'zoom': {
      'controls': false,
      'wheel': false,
      'startScale': 0.6,
      'maxScale': 1.0,
      'minScale': 0.1,
      'scaleSpeed': 0.5
    },
    'parentWorkspace': null,
  });




Future<void> _showDialogSaveLoad(){
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
      return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: const EdgeInsets.all(16.0),
      content: SizedBox(
        width: screenWidth * 0.7,
        height: screenHeight * 0.6,
        child: Column(
          children: [
            const Text(
              'Blockly List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Add new item and set it as selected
                  blocklyItems.add({
                    "name": "Blockly${blocklyItems.length + 1}",
                    "isVisible": true,
                  });
                  selectedItemIndex =
                      blocklyItems.length - 1; // Select the new button
                  _saveItems();
                  _loadproject = false;
                });

                Navigator.of(context)
                    .pop(); // Close dialog after adding and selecting the new button
              },
              icon: const Icon(Icons.add_circle),
              label: const Text(
                'New',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF6DBCFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: blocklyItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;

                    if (!item["isVisible"]) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10.0), // Space between items
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Slidable(
                          key: ValueKey(index),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.12,
                            children: [
                              const SizedBox(width: 10),
                              SlidableAction(
                                onPressed: (context) {
                                  // Check if there's more than one visible item before deleting
                                  if (blocklyItems
                                          .where((item) => item["isVisible"])
                                          .length >
                                      1) {
                                    setState(() {
                                      item["isVisible"] = false;
                                      if (selectedItemIndex == index)
                                        selectedItemIndex = null;
                                      _saveItems();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Cannot delete the last item.'),
                                      ),
                                    );
                                  }
                                },
                                backgroundColor: Colors.grey[200]!,
                                foregroundColor: Colors.red,
                                icon: EvaIcons.trash2Outline,
                                padding: EdgeInsets.zero,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedItemIndex =
                                      index; // Set selected item
                                  _saveItems();
                                  _loadproject = true;
                                });
                                Navigator.of(context)
                                    .pop(); // Close dialog on selection
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      Text(
                                        item["name"],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(width: 8),
                                      if (selectedItemIndex == index)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          EvaIcons.clipboardOutline,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          EvaIcons.edit2Outline,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        ),
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
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              minimumSize: const Size(140, 40),
            ),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
    },
  );
}



Future<void> saveXmlWorkspace() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('xml', _xmlworkspace);
    Fluttertoast.showToast(msg: "Workspace saved successfully!");
  } catch (e) {
    Fluttertoast.showToast(msg: "Failed to save workspace: $e");
  }
}

Future<void> loadXmlWorkspace() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? loadedXml = prefs.getString('xml');
    setState(() {
      _xmlworkspace = loadedXml ?? '';
    });
    Fluttertoast.showToast(msg: "Workspace loaded successfully!");
  } catch (e) {
    Fluttertoast.showToast(msg: "Failed to load workspace: $e");
  }
}





Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? items = prefs.getString('blocklyItems');
    final int? savedSelectedIndex = prefs.getInt('selectedItemIndex');

    setState(() {
      if (items != null) {
        blocklyItems = List<Map<String, dynamic>>.from(json.decode(items));
      } else {
        blocklyItems = [
          {"name": "Blockly1", "isVisible": true}
        ];
      }
      selectedItemIndex = savedSelectedIndex ??
          0; // Default to first item if no selection is saved
    });
  }

  Future<void> _saveItems() async {
  await Future.delayed(Duration(seconds: 10)); // Đặt delay 10 giây
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('blocklyItems', json.encode(blocklyItems));
  if (selectedItemIndex != null) {
    await prefs.setInt('selectedItemIndex', selectedItemIndex!);
  }
}






  
  @override
  void initState() {
    super.initState();
    _loadItems();
    loadXmlWorkspace();
  }


  void onInject(BlocklyData data) {
    debugPrint('onInject: ${data.xml}\n${jsonEncode(data.json)}');
  }

  void onChange(BlocklyData data) {
    setState(() {
      // Check if there are any blocks in the workspace
      if (data.js != null && data.js!.isNotEmpty) {
        _generatedCode = data.js!; // Update with the generated code
      } else {
        _generatedCode = ''; // No blocks, so clear the generated code
      }
      //_generatedCode = jsonEncode(data);
      _xmlworkspace = data.xml ?? '';
    });
    debugPrint('onChange: ${data.xml}\n${jsonEncode(data.json)}\n${data.dart}');
  }

  void onDispose(BlocklyData data) {
    debugPrint('onDispose: ${data.xml}\n${jsonEncode(data.json)}');
  }

  void onError(dynamic err) {
    debugPrint('onError: $err');
  }

  Future<List<String>> loadAddons() async {
    List<String> addons = [];
    try {
      addons.add(await rootBundle
          .loadString('assets/scratch/blocks/events_generators.js'));
      addons
          .add(await rootBundle.loadString('assets/scratch/blocks/module.js'));
      addons
          .add(await rootBundle.loadString('assets/scratch/blocks/display.js'));
      addons
          .add(await rootBundle.loadString('assets/scratch/blocks/motions.js'));
      addons.add(await rootBundle.loadString('assets/scratch/blocks/led.js'));
      //Fluttertoast.showToast(msg: "Loaded addons successfully");
      print('Loaded addons successfully');
      //addons.add(await rootBundle.loadString('assets/scratch/blocks/motor.js'));
    } catch (e) {
      print("Error loading addons: $e");
    }
    return addons;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
  flex: 3,
  child: StatefulBuilder(
    builder: (context, setState) {
      return _loadproject == false
          ? FutureBuilder(
              future: loadAddons(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Fluttertoast.showToast(msg: "new");
                  print("new");
                  return BlocklyEditorWidget(
                    workspaceConfiguration: workspaceConfiguration,
                    initial: initialToolboxJson,
                    onInject: onInject,
                    onChange: onChange,
                    onDispose: onDispose,
                    onError: onError,
                    addons: snapshot.data,
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : FutureBuilder(
              future: loadAddons(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Fluttertoast.showToast(msg: "Load ${_xmlworkspace}");
                  print("Load ${_xmlworkspace}");
                  return BlocklyEditorWidget(
                    workspaceConfiguration: workspaceConfiguration,
                    initial: _xmlworkspace,
                    onInject: onInject,
                    onChange: onChange,
                    onDispose: onDispose,
                    onError: onError,
                    addons: snapshot.data,
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const SizedBox.shrink();
              },
            );
    },
  ),
),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isExpanded ? 150 : 0,
              height: _isExpanded ? 330 : 0,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _generatedCode.isNotEmpty
                      ? _generatedCode
                      : '', // Display code if available
                  style: const TextStyle(fontSize: 14, fontFamily: 'Monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Programing'),
        toolbarHeight: 40,
        actions: [
          Padding(
    padding: const EdgeInsets.only(right: 20),
    child: IconButton(
      icon: const Icon(Icons.save),
      onPressed: () {
        saveXmlWorkspace();
      },
    ),
  ),
  Padding(
    padding: const EdgeInsets.only(right: 20),
    child: IconButton(
      icon: const Icon(Icons.download),
      onPressed: () {
        loadXmlWorkspace();
      },
    ),
  ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              child: IconButton(
                icon: const Icon(Icons.open_in_full),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Thay đổi trạng thái
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.view_list),
              onPressed: () {
               _showDialogSaveLoad();
              },
            ),
          ),
        ],
      ),
    );
  }
}


