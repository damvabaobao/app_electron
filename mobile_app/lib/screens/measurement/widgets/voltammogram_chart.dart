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
    final xRange = _calculateXRange();
    final yRange = _calculateYRange();

    return Container(
      height: 320,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minX: xRange.min,
          maxX: xRange.max,

          minY: yRange.min,
          maxY: yRange.max,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: _calculateHorizontalInterval(
              yRange.min,
              yRange.max,
            ),
            verticalInterval: _calculateVerticalInterval(
              xRange.min,
              xRange.max,
            ),
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Potential (mV)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: _calculateVerticalInterval(xRange.min, xRange.max),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
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
                reservedSize: 48,
                interval: _calculateHorizontalInterval(yRange.min, yRange.max),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade400),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,

              isCurved: true,

              curveSmoothness: 0.15,

              barWidth: 2.5,

              isStrokeCapRound: true,

              dotData: const FlDotData(show: false),

              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
  // X RANGE

  _ChartRange _calculateXRange() {
    if (spots.isEmpty) {
      final minX = startVoltage < endVoltage ? startVoltage : endVoltage;

      final maxX = startVoltage > endVoltage ? startVoltage : endVoltage;

      if (minX == maxX) {
        return _ChartRange(min: minX - 1, max: maxX + 1);
      }

      return _ChartRange(min: minX, max: maxX);
    }

    double minX = spots.first.x;
    double maxX = spots.first.x;

    for (final spot in spots) {
      if (spot.x < minX) {
        minX = spot.x;
      }

      if (spot.x > maxX) {
        maxX = spot.x;
      }
    }

    // Giữ một khoảng nhỏ ở hai bên để đường đo
    // không chạm sát mép biểu đồ.
    final range = maxX - minX;

    if (range <= 0) {
      return _ChartRange(min: minX - 1, max: maxX + 1);
    }

    final padding = range * 0.02;

    return _ChartRange(min: minX - padding, max: maxX + padding);
  }
  // Y RANGE

  _ChartRange _calculateYRange() {
    if (spots.isEmpty) {
      return const _ChartRange(min: 0, max: 1);
    }

    double minY = spots.first.y;
    double maxY = spots.first.y;

    for (final spot in spots) {
      if (spot.y < minY) {
        minY = spot.y;
      }

      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    // Trường hợp toàn bộ current bằng nhau.
    if (minY == maxY) {
      final padding = maxY.abs() * 0.2;

      return _ChartRange(
        min: minY - (padding > 0 ? padding : 0.5),
        max: maxY + (padding > 0 ? padding : 0.5),
      );
    }

    final range = maxY - minY;

    // Tạo khoảng trống phía trên và phía dưới.
    final padding = range * 0.10;

    return _ChartRange(min: minY - padding, max: maxY + padding);
  }
  // GRID INTERVAL

  double _calculateHorizontalInterval(double minY, double maxY) {
    final range = maxY - minY;

    if (range <= 0) {
      return 1;
    }

    final interval = range / 5;

    if (interval <= 0.01) {
      return 0.01;
    }

    if (interval <= 0.05) {
      return 0.05;
    }

    if (interval <= 0.1) {
      return 0.1;
    }

    if (interval <= 0.5) {
      return 0.5;
    }

    if (interval <= 1) {
      return 1;
    }

    if (interval <= 5) {
      return 5;
    }

    return 10;
  }

  double _calculateVerticalInterval(double minX, double maxX) {
    final range = maxX - minX;

    if (range <= 0) {
      return 1;
    }

    final interval = range / 6;

    if (interval <= 0.1) {
      return 0.1;
    }

    if (interval <= 0.2) {
      return 0.2;
    }

    if (interval <= 0.5) {
      return 0.5;
    }

    if (interval <= 1) {
      return 1;
    }

    if (interval <= 2) {
      return 2;
    }

    if (interval <= 5) {
      return 5;
    }

    if (interval <= 10) {
      return 10;
    }

    return 20;
  }
}

// SIMPLE RANGE MODEL

class _ChartRange {
  final double min;
  final double max;

  const _ChartRange({required this.min, required this.max});
}
