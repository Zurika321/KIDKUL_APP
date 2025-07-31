import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class TransactionItem {
  final String n; // name
  final String c; // command
  final int d; // delay

  TransactionItem({required this.n, required this.c, required this.d});

  TransactionItem copyWith({String? name, String? command, int? delay}) {
    return TransactionItem(
      n: name ?? this.n,
      c: command ?? this.c,
      d: delay ?? this.d,
    );
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      n: json['n'] as String,
      c: json['c'] as String,
      d: json['d'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'n': n, 'c': c, 'd': d};
  }
}

class CommandSequenceWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool lock;
  final Future<void> Function(String)? sendCommand;

  const CommandSequenceWidget({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
  });

  @override
  State<CommandSequenceWidget> createState() => _CommandSequenceWidgetState();
}

class _CommandSequenceWidgetState extends State<CommandSequenceWidget> {
  List<TransactionItem> actions = [
    TransactionItem(n: "Stop", c: "SS", d: 100),
    TransactionItem(n: "Forward", c: "WW", d: 100),
  ];

  List<TransactionItem> transactions = [];

  late double width;
  late double height;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    final data_transactions = widget.config['transactions'];
    if (data_transactions != null && data_transactions is List) {
      transactions =
          data_transactions
              .map(
                (e) => TransactionItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
    }
    final data_actions = widget.config['actions'];
    if (data_actions != null && data_actions is List) {
      actions = data_actions.map((e) => TransactionItem.fromJson(e)).toList();
    }

    width = (widget.config['width'] ?? 200).toDouble();
    height = (widget.config['height'] ?? 200).toDouble();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void showActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select action'),
          content: SizedBox(
            width: 315,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(85),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(60),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 158, 158, 158),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Action'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Command'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Delay'),
                        ),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      ],
                    ),
                    ...actions.asMap().entries.map((entry) {
                      final actionName = entry.value.n;
                      final command = entry.value.c;
                      final delay = entry.value.d;

                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(actionName),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(command),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(delay.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              color: const Color.fromARGB(255, 33, 149, 243),
                              onPressed: () {
                                if (transactions.length >= 100) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "100 action limit reached.",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                transactions.add(
                                  TransactionItem(
                                    n: actionName,
                                    c: command,
                                    d: delay,
                                  ),
                                );
                                final configToSave = {
                                  ...widget.config,
                                  "transactions":
                                      transactions
                                          .map((e) => e.toJson())
                                          .toList(),
                                };
                                widget.onSave?.call(configToSave);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Add Action By QR"),
              onPressed: () {
                // Navigator.of(context).pop();
                // scanQRcodeOnce(false);
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> scanQRcodeOnce(bool addTypeActive) async {
  //   String scanData = await FlutterBarcodeScanner.scanBarcode(
  //     '#ff6666',
  //     'Cancel',
  //     true,
  //     ScanMode.QR,
  //   );

  //   if (scanData != '-1') {
  //     try {
  //       final decoded = jsonDecode(scanData);

  //       if (decoded is List) {
  //         final List<TransactionItem> items =
  //             decoded.map((e) {
  //               if (e is Map<String, dynamic> || e is Map) {
  //                 return TransactionItem.fromJson(Map<String, dynamic>.from(e));
  //               } else {
  //                 throw FormatException('Invalid item type');
  //               }
  //             }).toList();

  //         if (addTypeActive) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text("Action added from QR successfully"),
  //             ),
  //           );
  //           actions.addAll(items);
  //           final configToSave = {
  //             ...widget.config,
  //             "actions": actions.map((e) => e.toJson()).toList(),
  //           };
  //           widget.onSave?.call(configToSave);
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text("Added action type from QR successfully"),
  //             ),
  //           );
  //           transactions.addAll(items);
  //           final configToSave = {
  //             ...widget.config,
  //             "transactions": transactions.map((e) => e.toJson()).toList(),
  //           };
  //           widget.onSave?.call(configToSave);
  //         }
  //       } else {
  //         throw FormatException('QR is not a valid list');
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("Invalid QR")));
  //     }
  //   }
  // }

  void showActionsSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit the list of actions"),
              content: SizedBox(
                width: 335,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FixedColumnWidth(120),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(60),
                        3: FixedColumnWidth(50),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 158, 158, 158),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Name'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Command'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Delay'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(''),
                            ),
                          ],
                        ),
                        ...actions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: item.n,
                                  maxLength: 10,
                                  onChanged: (value) {
                                    setState(() {
                                      actions[index] = actions[index].copyWith(
                                        name: value,
                                      );
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: item.c,
                                  maxLength: 5,
                                  onChanged: (value) {
                                    setState(() {
                                      actions[index] = actions[index].copyWith(
                                        command: value,
                                      );
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: item.d.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final intValue = int.tryParse(value) ?? 0;
                                    final clampedValue = intValue.clamp(
                                      100,
                                      60000,
                                    );
                                    setState(() {
                                      actions[index] = actions[index].copyWith(
                                        delay: clampedValue,
                                      );
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 244, 67, 54),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      actions.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton.icon(
                                onPressed: () {
                                  if (actions.length >= 100) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Reached 100 limit for additional action type.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    actions.add(
                                      TransactionItem(n: 'New', c: '', d: 100),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add"),
                              ),
                            ),
                            const SizedBox(),
                            const SizedBox(),
                            const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Save to Config"),
                  onPressed: () {
                    final configToSave = {
                      ...widget.config,
                      "actions": actions.map((e) => e.toJson()).toList(),
                    };
                    widget.onSave?.call(configToSave);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("Add Type Action By QR"),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // scanQRcodeOnce(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  int Playing_at_index = -1;
  Future<void> _playSequence() async {
    if (transactions.length == 0) return;
    if (Playing_at_index != -1) return;
    setState(() {
      Playing_at_index = 0;
    });
    for (var entry in transactions) {
      await widget.sendCommand?.call(entry.c);
      await Future.delayed(Duration(milliseconds: entry.d));
      setState(() {
        ++Playing_at_index;
      });
    }
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      Playing_at_index = -1;
    });
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 67, 54),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 68, 137, 255),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder.all(),
                              columnWidths: const {
                                0: FixedColumnWidth(100),
                                1: FixedColumnWidth(85),
                                2: FixedColumnWidth(60),
                                3: FixedColumnWidth(120),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 158, 158, 158),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Action',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Command',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Delay',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        ' ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...transactions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;
                                  final isPlaying = index == Playing_at_index;

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          data.n,
                                          style: TextStyle(
                                            color:
                                                isPlaying
                                                    ? const Color.fromARGB(
                                                      255,
                                                      76,
                                                      175,
                                                      79,
                                                    )
                                                    : const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                            fontWeight:
                                                isPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          data.c,
                                          style: TextStyle(
                                            color:
                                                isPlaying
                                                    ? const Color.fromARGB(
                                                      255,
                                                      76,
                                                      175,
                                                      79,
                                                    )
                                                    : const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                            fontWeight:
                                                isPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          (data.d).toString(),
                                          style: TextStyle(
                                            color:
                                                isPlaying
                                                    ? const Color.fromARGB(
                                                      255,
                                                      76,
                                                      175,
                                                      79,
                                                    )
                                                    : const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                            fontWeight:
                                                isPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 18,
                                              icon: const Icon(
                                                Icons.play_arrow,
                                              ),
                                              color: const Color.fromARGB(
                                                255,
                                                76,
                                                175,
                                                79,
                                              ),
                                              onPressed: () async {
                                                if (Playing_at_index != -1)
                                                  return;
                                                setState(() {
                                                  Playing_at_index = index;
                                                });
                                                await widget.sendCommand?.call(
                                                  data.c,
                                                );
                                                await Future.delayed(
                                                  Duration(
                                                    milliseconds: data.d,
                                                  ),
                                                );
                                                setState(() {
                                                  Playing_at_index = -1;
                                                });
                                              },
                                            ),
                                            IconButton(
                                              iconSize: 18,
                                              icon: const Icon(Icons.delete),
                                              color: const Color.fromARGB(
                                                255,
                                                244,
                                                67,
                                                54,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  transactions.removeAt(index);
                                                  // Nếu đang phát thì reset lại index nếu bị ảnh hưởng
                                                  if (Playing_at_index >=
                                                      transactions.length) {
                                                    Playing_at_index = -1;
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => showActionsDialog(context),
                          icon: const Icon(Icons.add),
                          label: const FittedBox(child: Text("Add Action")),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: _playSequence,
                          icon: const Icon(Icons.play_arrow),
                          label: const FittedBox(child: Text("Play All")),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    width += details.delta.dx;
                    height += details.delta.dy;
                    width = width.clamp(200, 500);
                    height = height.clamp(200, 500);
                  });
                },
                onPanEnd: (_) {
                  widget.onSave?.call({
                    ...widget.config,
                    'width': width,
                    'height': height,
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  showActionsSettingsDialog(context);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 76, 175, 79),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          if (widget.config["lock"] == false)
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showDeleteConfirmDialog,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      255,
                      0,
                      0,
                    ).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
