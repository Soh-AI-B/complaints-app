import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

enum ChartType { pieChart, barChart, lineChart }

class ChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final ChartType chartType;
  final double height;
  final String? title;

  const ChartWidget({
    super.key,
    required this.data,
    required this.chartType,
    this.height = 200,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.pieChart:
        return _buildPieChart();
      case ChartType.barChart:
        return _buildBarChart();
      case ChartType.lineChart:
        return _buildLineChart();
    }
  }

  Widget _buildPieChart() {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final total = data.values.reduce((a, b) => a + b);
    final colors = _getColors();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: PieChartPainter(data, colors, total),
            child: Container(),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(child: _buildLegend(colors)),
      ],
    );
  }

  Widget _buildBarChart() {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final colors = _getColors();

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              final barHeight = (entry.value / maxValue) * (height - 60);

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    entry.value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: CustomPaint(painter: LineChartPainter(data), child: Container()),
    );
  }

  Widget _buildLegend(List<Color> colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        final total = data.values.reduce((a, b) => a + b);
        final percentage = (entry.value / total * 100).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: AppDimensions.iconL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'No data available',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  List<Color> _getColors() {
    return [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double total;

  PieChartPainter(this.data, this.colors, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height
        ? size.width / 2 - 10
        : size.height / 2 - 10;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (final entry in data.entries) {
      final index = data.keys.toList().indexOf(entry.key);
      final sweepAngle = (entry.value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final Map<String, double> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final stepX = size.width / (data.length - 1);

    Path path = Path();
    List<Offset> points = [];

    data.entries.toList().asMap().forEach((index, entry) {
      final x = index * stepX;
      final y = size.height - (entry.value / maxValue) * size.height;

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      points.add(Offset(x, y));
    });

    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
