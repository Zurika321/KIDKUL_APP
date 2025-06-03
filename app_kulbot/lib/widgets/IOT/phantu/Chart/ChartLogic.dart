import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/IOT/Sample&Data/ControlValueManager.dart';
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
  final bluetoothstate = ControlValueManager.getValue("bluetoothState");

  final Map<String, List<double>> DataFake = {
    'data1': [10.0, 20.0, 50.0, 10.0, 30.0],
    'data2': [15.0, 30.0, 90.0, 60.0, 50.0],
    'data3': [20.0, 40.0, 50.0, 20.0, 10.0],
    'data4': [25.0, 45.0, 55.0, 60.0, 70.0],
    'data5': [0.0, 40.0, 80.0, 20.0, 100.0],
  };

  late Map<String, List<double>> Data;
  late bool Chuacodulieu = false;

  @override
  void initState() {
    super.initState();
    bool inMenu = widget.inMenu;

    if (inMenu) {
      Data = DataFake;
      debugPrint("IN MENU: Data = $Data");
    } else {
      final value = widget.value;
      if (value.isEmpty) {
        Data = {};
        Chuacodulieu = true;
      } else {
        Data = {};
        value.forEach((key, val) {
          final k = key.toString();
          List<double> values;
          if (val is List) {
            values =
                val
                    .map(
                      (e) =>
                          e is double
                              ? e
                              : double.tryParse(e.toString()) ?? 0.0,
                    )
                    .toList();
          } else if (val is num) {
            values = [val.toDouble()];
          } else {
            values = [];
          }
          if (Data.containsKey(k)) {
            Data[k]!.addAll(values);
          } else {
            Data[k] = List<double>.from(values);
          }
          // Giới hạn số lượng phần tử nếu muốn
          if (Data[k]!.length > 100) {
            Data[k] = Data[k]!.sublist(Data[k]!.length - 100);
          }
        });
        Chuacodulieu = Data.isEmpty;
      }
    }
    print("INIT: Data = $Data");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(CustomChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("dữ liệu mới nhận đc: ${widget.value}");
    if (widget.value != oldWidget.value) {
      setState(() {
        final value = widget.value;
        if (value.isNotEmpty) {
          value.forEach((key, val) {
            final k = key.toString();
            List<double> values;
            if (val is List) {
              values =
                  val
                      .map(
                        (e) =>
                            e is double
                                ? e
                                : double.tryParse(e.toString()) ?? 0.0,
                      )
                      .toList();
            } else if (val is num) {
              values = [val.toDouble()];
            } else {
              values = [];
            }
            if (Data.containsKey(k)) {
              Data[k]!.addAll(values);
            } else {
              Data[k] = List<double>.from(values);
            }
            // Giới hạn số lượng phần tử nếu muốn
            if (Data[k]!.length > 100) {
              Data[k] = Data[k]!.sublist(Data[k]!.length - 100);
            }
          });
          Chuacodulieu = Data.isEmpty;
          debugPrint("UPDATED (append): Data = $Data");
        } else {
          if (Data.isEmpty) {
            Chuacodulieu = true;
            debugPrint("UPDATED: Data = null or empty");
          }
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showEditDialog(BuildContext context) {
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
                        'Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết bluetooth.',
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
                            labelText: 'Chọn dữ liệu ${index + 1}',
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
                    if (Data.isNotEmpty) {
                      if (selectedDatasets.every((ds) => ds == 'None')) {
                        selectedDatasets[0] = Data.keys.first;
                      }

                      final newConfig = Map<String, dynamic>.from(
                        widget.config,
                      );
                      newConfig['title'] = titleController.text;
                      newConfig['chartType'] = chartType;
                      newConfig['datasets'] = selectedDatasets;

                      final parsedCount = int.tryParse(
                        visibleCountController.text,
                      );
                      if (parsedCount != null && parsedCount > 0) {
                        newConfig['visibleCount'] = parsedCount;
                      }

                      newConfig['numberOfTargets'] = 3;

                      widget.onSave?.call(newConfig);
                      Navigator.pop(context);
                    }
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

  Widget _buildErrorWidget(String Error, Size size, bool isLocked) {
    return GestureDetector(
      onDoubleTap: !isLocked ? () => _showEditDialog(context) : null,
      child: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                Error,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Chuacodulieu) {
      return _buildErrorWidget(
        'Không có dữ liệu để hiển thị, vui lòng kiểm tra kết nối bluetooth. \n double tap để mở setting',
        widget.size,
        widget.config['lock'] == true,
      );
    }
    final isLocked = widget.config['lock'] == true;
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
    debugPrint("CustomChart value: ${widget.value}");
    debugPrint("CustomChart Data: $Data");
    Map<String, List<double>> chartData = {};
    for (var dataset in selectedDatasets) {
      if (Data.containsKey(dataset)) {
        chartData[dataset] = Data[dataset]!;
      }
      //else {
      // Data[dataset] = [];
      //}
    }

    final int numberOfTargets = chartData.length;

    final maxlength = chartData.values
        .map((data) => data.length)
        .reduce((a, b) => a > b ? a : b);

    if (chartData.isEmpty) {
      return _buildErrorWidget(
        'Không có dữ liệu để hiển thị',
        widget.size,
        isLocked,
      );
    } else if (chartData.values.any((data) => data.isEmpty)) {
      return _buildErrorWidget(
        'Dữ liệu không hợp lệ hoặc trống',
        widget.size,
        isLocked,
      );
    } else if (chartData.values.any((data) => data.length < maxlength)) {
      return _buildErrorWidget(
        'Dữ liệu không đồng nhất, độ dài không bằng nhau',
        widget.size,
        isLocked,
      );
    } else if (numberOfTargets >= 6 || numberOfTargets <= 0) {
      return _buildErrorWidget(
        'Số mục tiêu cần để hiển thị là: 1-5 mục tiêu',
        widget.size,
        isLocked,
      );
    }

    return GestureDetector(
      onDoubleTap: !isLocked ? () => _showEditDialog(context) : null,
      // child: OverflowBox(
      //   minHeight: 30.0,
      //   maxHeight: double.infinity,
      //   minWidth: 30.0,
      //   maxWidth: double.infinity,
      child: Container(
        width: widget.size.width,
        height: widget.size.height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
        // Stack(
        //   children: [
        //     Positioned.fill(
        //       child: Scrollbar(
        //         controller: scrollController,
        //         thumbVisibility: true,
        //         child: SingleChildScrollView(
        //           controller: scrollController,
        //           scrollDirection: Axis.horizontal,
        //           child: SingleChildScrollView(
        //             scrollDirection: Axis.vertical,
        //             clipBehavior: Clip.none,
        //             child:
        //                 chartType == 'area' || chartType == 'line'
        //                     ? AreaOrLineChartWidgets(
        //                       numberOfTargets: numberOfTargets,
        //                       visibleCount: visibleCount,
        //                       chartData: chartData,
        //                       endIndex: chartData.values.first.length,
        //                       size: widget.size,
        //                       isCurved: chartType == 'area',
        //                     )
        //                     : ColumnChartWidget(
        //                       numberOfTargets: numberOfTargets,
        //                       visibleCount: visibleCount,
        //                       endIndex: chartData.values.first.length,
        //                       chartData: chartData,
        //                       size: widget.size,
        //                     ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        Column(
          children: [
            Text(
              chartTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Expanded(
            Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                // Để mặc định hoặc dùng Clip.hardEdge để chỉ cắt trái/phải
                // clipBehavior: Clip.hardEdge, // <-- có thể bỏ dòng này vì mặc định đã là hardEdge
                child:
                    chartType == 'area' || chartType == 'line'
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
                          endIndex: chartData.values.first.length,
                          chartData: chartData,
                          size: widget.size,
                        ),
              ),
            ),
            // ),
          ],
        ),
      ),
      // ),
    );
  }
}
