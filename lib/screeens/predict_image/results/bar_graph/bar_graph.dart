import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/predict_image/results/bar_graph/bar_data.dart';

class ResultBarGraph extends StatefulWidget {
  final List<double> quantityPerClass;
  final List<String> dateList;
  final int maxNum;

  const ResultBarGraph({
    super.key,
    required this.maxNum,
    required this.dateList,
    required this.quantityPerClass,
  });

  @override
  State<ResultBarGraph> createState() => _ResultBarGraphState();
}

class _ResultBarGraphState extends State<ResultBarGraph> {
  late int maxy = 0;

  maxYVal() {
    if (widget.maxNum > 30) {
      setState(() {
        maxy = widget.maxNum + 10;
      });
    } else {
      setState(() {
        maxy = 30;
      });
    }
  }

  @override
  void initState() {
    maxYVal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BarData barData = BarData(
      firstAmount: widget.quantityPerClass[0].toDouble(),
      secondAmount: widget.quantityPerClass[1].toDouble(),
      thirdAmount: widget.quantityPerClass[2].toDouble(),
      fourthAmount: widget.quantityPerClass[3].toDouble(),
      fifthAmount: widget.quantityPerClass[4].toDouble(),
      // sixthAmount: quantityPerClass[5].toDouble(),
      // seventhAmount: quantityPerClass[6].toDouble(),
      // eightAmount: quantityPerClass[7].toDouble(),
      // ninethAmount: quantityPerClass[8].toDouble(),
      // tenthAmount: quantityPerClass[9].toDouble(),
    );

    barData.intialzedBarData();

    return BarChart(
      BarChartData(
        maxY: maxy.toDouble(),
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Theme.of(context).cardTheme.color,
              // tooltipPadding: const EdgeInsets.all(2),
              // direction: TooltipDirection.top,
              rotateAngle: 0,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12));
              }),
          enabled: true,
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                Widget text = const Text("");

                if (value.toInt() >= 0 &&
                    value.toInt() < widget.dateList.length) {
                  text = Text(widget.dateList[value.toInt()]);
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
            ),
          ),
        ),
        barGroups: barData.barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    color: Colors.green.shade400,
                    width: 50,
                    borderRadius: BorderRadius.zero,
                    // backDrawRodData: BackgroundBarChartRodData(
                    //   show: true,
                    //   toY: 30,
                    //   color: Colors.grey.shade200,
                    // ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
