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
  late int maxy = 100;

  // maxYVal() {
  //   if (widget.maxNum > 30) {
  //     setState(() {
  //       maxy = widget.maxNum + 10;
  //     });
  //   } else {
  //     setState(() {
  //       maxy = 70;
  //     });
  //   }
  // }

  @override
  void initState() {
    // maxYVal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BarData barData = BarData(
      amounts: widget.quantityPerClass,
    );

    barData.intialzedBarData();

    return BarChart(
      BarChartData(
        maxY: maxy.toDouble(),
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
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
                  debugPrint(widget.dateList.toString());
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
                    width: 45,
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
