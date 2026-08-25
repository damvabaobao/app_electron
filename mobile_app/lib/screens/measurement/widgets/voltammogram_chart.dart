import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VoltammogramChart extends StatelessWidget {
  final List<FlSpot> spots;

  final double startVoltage;
  final double endVoltage;

  final String method;

  const VoltammogramChart({
    super.key,
    required this.spots,
    required this.startVoltage,
    required this.endVoltage,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minX: startVoltage,
          maxX: endVoltage,

          minY: 0,

          // Tự động lấy khoảng Y dựa trên dữ liệu.
          maxY: _calculateMaxY(),

          gridData: const FlGridData(show: true),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Potential (V)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                'Current',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(show: true),

          lineBarsData: [
            LineChartBarData(
              spots: spots,

              isCurved: false,

              barWidth: 2.5,

              dotData: const FlDotData(show: false),

              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (spots.isEmpty) {
      return 1.5;
    }

    double maxCurrent = spots.first.y;

    for (final spot in spots) {
      if (spot.y > maxCurrent) {
        maxCurrent = spot.y;
      }
    }

    // Thêm khoảng trống phía trên peak
    final calculatedMax = maxCurrent * 1.2;

    // Tránh trường hợp maxY quá nhỏ
    return calculatedMax < 0.5 ? 0.5 : calculatedMax;
  }
}
