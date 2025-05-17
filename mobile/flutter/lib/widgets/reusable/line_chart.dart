import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/data/line_chart_data.dart';
import 'package:swms_administration/widgets/reusable/custom_card.dart';

class LineChartCard extends StatefulWidget {
  final String title;
  final Color selectionColor;
  final Color greyColor;
  final bool isDesktop;
  final bool isFilled;

  const LineChartCard({
    super.key,
    required this.selectionColor,
    required this.greyColor,
    required this.title,
    required this.isDesktop,
    required this.isFilled,
  });

  @override
  State<LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  late final BinChartData chartData;

  @override
  void initState() {
    super.initState();
    chartData = BinChartData();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<FlSpot>>(
      valueListenable:
          widget.isFilled ? chartData.filledSpots : chartData.emptySpots,
      builder: (context, spots, _) {
        return ValueListenableBuilder<Map<int, String>>(
          valueListenable: chartData.bottomTitles,
          builder: (context, bottomTitles, _) {
            return ValueListenableBuilder<Map<double, String>>(
              valueListenable: chartData.leftTitles,
              builder: (context, leftTitles, _) {
                return _buildChartContainer(spots, bottomTitles, leftTitles);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChartContainer(
    List<FlSpot> spots,
    Map<int, String> bottomTitles,
    Map<double, String> leftTitles,
  ) {
    final maxY = leftTitles.keys.lastOrNull ?? 0;
    final minY = leftTitles.keys.firstOrNull ?? 0;
    final double maxX = spots.isNotEmpty ? spots.last.x : 0;

    // Filter the bottomTitles to include only the first of every 8 pairs
    final filteredBottomTitles = {
      for (var entry in bottomTitles.entries.where((e) => e.key % 8 == 0))
        entry.key: entry.value,
      bottomTitles.keys.last: bottomTitles.values.last,
    };

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle(),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: widget.isDesktop ? 16 / 6 : 1.5,
            child: LineChart(
              LineChartData(
                lineTouchData: _buildTouchData(),
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(filteredBottomTitles, leftTitles),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [_buildChartBarData(spots)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => AppColours().mainWhiteColour,
        tooltipBorder:
            BorderSide(color: AppColours().mainGreyColour.withOpacity(0.1), width: 2),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              '${spot.y}',
              GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: widget.selectionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: widget.isDesktop,
      getDrawingHorizontalLine: (value) => FlLine(
        color: widget.greyColor.withOpacity(0.1),
        strokeWidth: 1,
      ),
    );
  }

  FlTitlesData _buildTitlesData(
    Map<int, String> bottomTitles,
    Map<double, String> leftTitles,
  ) {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        axisNameWidget: _buildAxisLabel('Time of the Day'),
        sideTitles: SideTitles(
          interval: 1,
          showTitles: true,
          getTitlesWidget: (value, _) => FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Text(
                bottomTitles[value.toInt()] ?? '',
                style: TextStyle(
                  color: widget.greyColor,
                ),
              ),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget:
            widget.isDesktop ? _buildAxisLabel('Number of Bins') : null,
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) => Tooltip(
            message: 'Number of Bins',
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  leftTitles[value] ?? '',
                  style: TextStyle(
                    color: widget.greyColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAxisLabel(String text) {
    return Tooltip(
      message: text,
      child: AutoSizeText(
        text,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: widget.greyColor,
            fontSize: widget.isDesktop ? 14 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        maxLines: 1,
        minFontSize: 8,
      ),
    );
  }

  LineChartBarData _buildChartBarData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      color: widget.selectionColor,
      barWidth: 3,
      isCurved: true,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.selectionColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildChartTitle() {
    return Text(
      widget.title,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: widget.isDesktop ? 17 : 16,
          fontWeight: FontWeight.w500,
          color: widget.selectionColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    chartData.dispose();
    super.dispose();
  }
}
