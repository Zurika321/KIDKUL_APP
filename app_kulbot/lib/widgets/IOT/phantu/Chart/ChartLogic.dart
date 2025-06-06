import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/IOT/phantu/Chart/WidgetChart.dart';
// import 'package:fl_chart/fl_chart.dart'
//     show
//         LineChart,
//         LineChartData,
//         LineChartBarData,
//         FlSpot,
//         FlDotData,
//         FlTitlesData,
//         FlGridData,
//         FlBorderData,
//         AxisTitles,
//         SideTitles;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

// Biểu đồ miền nhiều mục tiêu
class CustomChart extends StatefulWidget {
  final Size size;
  final Map<String, dynamic> config;
  final Map<String, dynamic> value;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;
  // final Future<void> Function(String msg)? sendCommand;

  const CustomChart({
    super.key,
    required this.size,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
    required this.inMenu,
    // this.sendCommand,
  });

  @override
  State<CustomChart> createState() => _CustomChartStates();
}

class _CustomChartStates extends State<CustomChart> {
  final scrollController = ScrollController();
  late final Map<String, List<double>> DataFake = {
    'data1': [10.0, 20.0, 50.0, 10.0, 30.0],
    'data2': [15.0, 30.0, 90.0, 60.0, 50.0],
    'data3': [20.0, 40.0, 50.0, 20.0, 10.0],
    'data4': [25.0, 45.0, 55.0, 60.0, 70.0],
    'data5': [0.0, 40.0, 80.0, 20.0, 100.0],
  };

  late Map<String, List<double>> Data;
  late bool Chuacodulieu = false;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    bool inMenu = widget.inMenu;
    width = (widget.config['width'] ?? 160).toDouble();
    height = (widget.config['height'] ?? 100).toDouble();

    if (inMenu) {
      Data = DataFake;
    } else {
      final value = widget.value;
      Data = {};
      if (value.isEmpty) {
        Chuacodulieu = true;
      } else {
        value.forEach((key, val) {
          final k = key.toString();
          if (val is double) {
            Data[k] = [val];
          }
        });
        Chuacodulieu = Data.isEmpty;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(CustomChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        final value = widget.value;
        if (value.isNotEmpty) {
          value.forEach((key, val) {
            final k = key.toString();
            if (val is double) {
              if (Data.containsKey(k)) {
                Data[k]!.add(val);
              } else {
                Data[k] = [val];
              }
              // Giới hạn số lượng phần tử nếu muốn
              if (Data[k]!.length > 100) {
                Data[k] = Data[k]!.sublist(Data[k]!.length - 100);
              }
            }
          });

          // Sau khi cập nhật, đồng bộ độ dài các list
          if (Data.isNotEmpty) {
            final maxLength = Data.values
                .map((list) => list.length)
                .reduce((a, b) => a > b ? a : b);
            Data.forEach((key, list) {
              while (list.length < maxLength) {
                // Thêm giá trị cuối cùng cho đến khi đủ độ dài
                list.add(list.isNotEmpty ? list.last : 0.0);
              }
            });
          }

          Chuacodulieu = Data.isEmpty;
        } else {
          // if (Data.isEmpty) {
          //   Chuacodulieu = true;
          // }
          Chuacodulieu = widget.value.isEmpty;
          //vì Data đã được tạo sẵn khi kết nối nên khi thiết bị bị ngắt thì sẽ là Chuacodulieu = true
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showEditDialog() {
    final titleController = TextEditingController(
      text: widget.config['title'] ?? 'Biểu đồ',
    );

    final visibleCount = widget.config['visibleCount'] ?? 10;
    final visibleCountController = TextEditingController(
      text: visibleCount.toString(),
    );

    String chartType = widget.config['chartType'] ?? 'area';
    List<String> selectedDatasets = List<String>.from(
      widget.config['datasets'] ??
          (Data.isNotEmpty
              ? [Data.keys.first, 'None', 'None']
              : ['None', 'None', 'None']),
    );

    // Đảm bảo đủ 3 phần tử
    while (selectedDatasets.length < 3) {
      selectedDatasets.add('None');
    }

    final availableDatasets = ['None', ...Data.keys];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa biểu đồ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên biểu đồ',
                      ),
                    ),
                    TextField(
                      controller: visibleCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số điểm hiển thị trên 1 trang',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: chartType,
                      items: const [
                        DropdownMenuItem(
                          value: 'area',
                          child: Text('Biểu đồ miền'),
                        ),
                        DropdownMenuItem(
                          value: 'line',
                          child: Text('Biểu đồ đường'),
                        ),
                        DropdownMenuItem(
                          value: 'column',
                          child: Text('Biểu đồ cột'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Loại biểu đồ',
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            chartType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (Data.isEmpty) ...[
                      const Text(
                        'Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết bluetooth!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ] else ...[
                      ...List.generate(3, (index) {
                        return DropdownButtonFormField<String>(
                          value: selectedDatasets[index],
                          items:
                              availableDatasets
                                  .map(
                                    (data) => DropdownMenuItem(
                                      value: data,
                                      child: Text(
                                        data == 'None' ? 'Không có' : data,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          decoration: InputDecoration(
                            labelText:
                                'Chọn Cổng dữ liệu cho mục tiêu ${index + 1}',
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedDatasets[index] = val;
                              });
                            }
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete?.call();
                  },
                  child: const Text('Xoá', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    final newConfig = Map<String, dynamic>.from(widget.config);
                    newConfig['title'] = titleController.text;
                    newConfig['chartType'] = chartType;

                    final parsedCount = int.tryParse(
                      visibleCountController.text,
                    );
                    if (parsedCount != null && parsedCount > 0) {
                      newConfig['visibleCount'] = parsedCount;
                    }

                    if (Data.isEmpty) {
                      newConfig['datasets'] = [];
                    } else {
                      if (selectedDatasets.every((ds) => ds == 'None')) {
                        // Chỉ gán nếu Data không rỗng
                        if (Data.keys.isNotEmpty) {
                          selectedDatasets[0] = Data.keys.first;
                        }
                      }
                      newConfig['datasets'] = selectedDatasets;
                    }

                    widget.onSave?.call(newConfig);
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartTitle = widget.config['title'] ?? 'Biểu đồ';
    final int visibleCount =
        widget.inMenu ? 5 : widget.config['visibleCount'] ?? 10;
    String chartType =
        widget.config['chartType'] ?? 'area'; // 'area' hoặc 'line'
    List<String> selectedDatasets =
        widget.inMenu
            ? ["data1", "data2", "data3"]
            : List<String>.from(
              widget.config['datasets'] ??
                  (Data.isNotEmpty ? [Data.keys.first] : []),
            );
    // debugPrint("CustomChart value: ${widget.value}");
    // debugPrint("CustomChart Data: $Data");
    Map<String, List<double>> chartData = {};
    for (var dataset in selectedDatasets) {
      if (Data.containsKey(dataset)) {
        chartData[dataset] = Data[dataset]!;
      }
    }

    final int numberOfTargets = chartData.length;

    String Error = '';
    if (Chuacodulieu && !widget.inMenu) {
      Error = 'Không có dữ liệu.';
    } else if (chartData.isEmpty && !widget.inMenu) {
      Error = 'Cổng hiện tại không có dữ liệu.';
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Text(chartTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Error.isNotEmpty
              ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        Error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AreaOrLineChartWidgets(
                      numberOfTargets: numberOfTargets,
                      visibleCount: visibleCount,
                      chartData: chartData,
                      endIndex:
                          Error.isNotEmpty
                              ? DataFake.values.first.length
                              : chartData.values.first.length,
                      size: widget.size,
                      isCurved: chartType == 'area',
                    ),
                  ],
                ),
              )
              : Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child:
                      (chartType == 'area' || chartType == 'line')
                          ? AreaOrLineChartWidgets(
                            numberOfTargets: numberOfTargets,
                            visibleCount: visibleCount,
                            chartData: chartData,
                            endIndex: chartData.values.first.length,
                            size: widget.size,
                            isCurved: chartType == 'area',
                          )
                          : ColumnChartWidget(
                            numberOfTargets: numberOfTargets,
                            visibleCount: visibleCount,
                            chartData: chartData,
                            endIndex: chartData.values.first.length,
                            size: widget.size,
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
                    width = width.clamp(150, 600);
                    height = height.clamp(150, 600);
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
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: _showEditDialog,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
