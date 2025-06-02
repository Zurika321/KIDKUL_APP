import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'
    show
        LineChart,
        LineChartData,
        LineChartBarData,
        FlSpot,
        FlDotData,
        FlTitlesData,
        FlGridData,
        FlBorderData,
        AxisTitles,
        SideTitles,
        BarChart,
        BarChartData,
        BarChartGroupData,
        LineTouchData,
        LineTouchTooltipData,
        LineTooltipItem,
        LineBarSpot,
        BarChartRodData,
        BarTouchData,
        BarTouchTooltipData,
        BarTooltipItem;

class AreaOrLineChartWidgets extends StatefulWidget {
  final int numberOfTargets;
  final int visibleCount;
  final int endIndex;
  final Map<String, List<double>> chartData;
  final int startIndex;
  final Size size;
  final bool isCurved;

  const AreaOrLineChartWidgets({
    required this.numberOfTargets, //số mục tiêu trong biểu đồ
    required this.visibleCount, //số điểm hiển thị trên 1 trang
    required this.endIndex, //vị trí kết thúc của dữ liệu (đã kiểm tra có vượt quá mảng hay không)
    required this.chartData, // dữ liệu
    this.startIndex = 0, //vị trí bắt đầu của dữ liệu
    required this.size, // kích thước của widget
    required this.isCurved, // có vẽ đường cong hay không
  });

  @override
  State<AreaOrLineChartWidgets> createState() => _AreaOrLineChartWidgetsState();
}

class _AreaOrLineChartWidgetsState extends State<AreaOrLineChartWidgets> {
  final List<Color> targetColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final chartEntries = widget.chartData.entries.toList();
    final double pixelsPerPoint = widget.size.width / (widget.visibleCount + 2);
    // print(
    //   widget.size.height.toString() +
    //       " " +
    //       widget.size.width.toString() +
    //       " " +
    //       widget.visibleCount.toString() +
    //       " " +
    //       widget.endIndex.toString(),
    // );

    return SizedBox(
      width: widget.endIndex * pixelsPerPoint,
      height: widget.size.height - 40,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            for (int i = 0; i < widget.numberOfTargets; i++)
              LineChartBarData(
                spots:
                    List.generate(widget.endIndex, (j) {
                      final currentData = chartEntries[i].value;
                      final index = j;
                      if (index < currentData.length) {
                        return FlSpot(j.toDouble(), currentData[index]);
                      } else {
                        return null;
                      }
                    }).whereType<FlSpot>().toList(),
                isCurved: widget.isCurved,
                color: targetColors[i],
                barWidth: 2,
                dotData: FlDotData(show: true),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: -widget.numberOfTargets * 30 - 10,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final seriesIndex = spot.barIndex;
                  final seriesName = widget.chartData.keys.elementAt(
                    seriesIndex,
                  );
                  final yValue = spot.y;

                  return LineTooltipItem(
                    '$seriesName: ${yValue.toStringAsFixed(2)}',
                    TextStyle(
                      color: targetColors[seriesIndex],
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                interval: 50,
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                interval: 50,
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 35,
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
      ),
    );
  }
}

// Biểu đồ cột nhiều mục tiêu
class ColumnChartWidget extends StatelessWidget {
  final int numberOfTargets;
  final int visibleCount;
  final int endIndex;
  final Map<String, List<double>> chartData;
  final int startIndex;
  final Size size;

  ColumnChartWidget({
    required this.numberOfTargets,
    required this.visibleCount,
    required this.endIndex,
    required this.chartData,
    this.startIndex = 0,
    required this.size,
  });

  final List<Color> targetColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final chartEntries = chartData.entries.toList();
    final double pixelsPerPoint = size.width / visibleCount;

    // Tạo dữ liệu BarChartGroupData
    List<BarChartGroupData> barGroups = List.generate(endIndex, (index) {
      List<BarChartRodData> rods = [];

      for (int i = 0; i < numberOfTargets; i++) {
        final data = chartEntries[i].value;
        if (index < data.length) {
          rods.add(
            BarChartRodData(
              toY: data[index],
              width: pixelsPerPoint / (numberOfTargets + 1),
              color: targetColors[i],
              borderRadius: BorderRadius.zero,
            ),
          );
        }
      }

      return BarChartGroupData(x: index, barRods: rods, barsSpace: 2);
    });

    return SizedBox(
      width: endIndex * pixelsPerPoint,
      height: size.height - 40,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final seriesName = chartData.keys.elementAt(rodIndex);
                return BarTooltipItem(
                  '$seriesName: ${rod.toY.toStringAsFixed(2)}',
                  TextStyle(
                    color: targetColors[rodIndex],
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
