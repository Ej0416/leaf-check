import 'package:leafcheck_project_v2/screeens/predict_image/results/bar_graph/ind-bar.dart';

class BarData {
  final double firstAmount;
  final double secondAmount;
  final double thirdAmount;
  final double fourthAmount;
  final double fifthAmount;
  // final double sixthAmount;
  // final double seventhAmount;
  // final double eightAmount;
  // final double ninethAmount;
  // final double tenthAmount;

  BarData({
    required this.firstAmount,
    required this.secondAmount,
    required this.thirdAmount,
    required this.fourthAmount,
    required this.fifthAmount,
    // required this.sixthAmount,
    // required this.seventhAmount,
    // required this.eightAmount,
    // required this.ninethAmount,
    // required this.tenthAmount,
  });

  List<IndividualBar> barData = [];

  intialzedBarData() {
    barData = [
      IndividualBar(x: 0, y: firstAmount),
      IndividualBar(x: 1, y: secondAmount),
      IndividualBar(x: 2, y: thirdAmount),
      IndividualBar(x: 3, y: fourthAmount),
      IndividualBar(x: 4, y: fifthAmount),
      // IndividualBar(x: 0, y: sixthAmount),
      // IndividualBar(x: 1, y: seventhAmount),
      // IndividualBar(x: 2, y: eightAmount),
      // IndividualBar(x: 3, y: ninethAmount),
      // IndividualBar(x: 4, y: tenthAmount),
    ];
  }
}
