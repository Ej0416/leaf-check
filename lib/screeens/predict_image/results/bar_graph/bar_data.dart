import 'package:leafcheck_project_v2/screeens/predict_image/results/bar_graph/ind-bar.dart';

class BarData {
  // final double firstAmount;
  // final double secondAmount;
  // final double thirdAmount;
  // final double fourthAmount;
  // final double fifthAmount;
  final List amounts;

  BarData({
    // required this.firstAmount,
    // required this.secondAmount,
    // required this.thirdAmount,
    // required this.fourthAmount,
    // required this.fifthAmount,
    required this.amounts,
  });

  List<IndividualBar> barData = [];

  intialzedBarData() {
    // barData = [
    //   IndividualBar(x: 0, y: firstAmount),
    //   IndividualBar(x: 1, y: secondAmount),
    //   IndividualBar(x: 2, y: thirdAmount),
    //   IndividualBar(x: 3, y: fourthAmount),
    //   IndividualBar(x: 4, y: fifthAmount),
    // ];
    barData = List.generate(amounts.length, (index) {
      return IndividualBar(x: index, y: amounts[index]);
    });
  }
}
