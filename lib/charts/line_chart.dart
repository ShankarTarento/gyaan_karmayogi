import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_charts/line_chart_model.dart';

class LineChart extends StatelessWidget {
  final String title;
  final List<LineChartModel> data;
  final bool vertical;

  LineChart(
      {@required this.title, @required this.data, @required this.vertical});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<LineChartModel, String>> series = [
      charts.Series(
          id: "LineChartModel",
          data: data,
          domainFn: (LineChartModel point, _) =>
              point.labelAxis.split('-').last,
          measureFn: (LineChartModel point, _) => point.dataAxis,
          labelAccessorFn: (LineChartModel skill, _) =>
              'skill.labelAxis'.toString(),
          outsideLabelStyleAccessorFn: (LineChartModel skill, _) {
            final color = charts.MaterialPalette.black;
            return new charts.TextStyleSpec(color: color, fontSize: 10);
          },
          colorFn: (LineChartModel skill, _) =>
              charts.ColorUtil.fromDartColor(AppColors.indicatorColor))
    ];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.5),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  )),
              Expanded(
                child: new charts.OrdinalComboChart(
                  series,
                  animate: true,
                  defaultRenderer: new charts.LineRendererConfig(
                    stacked: false,
                  ),
                  domainAxis: new charts.OrdinalAxisSpec(),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                        desiredTickCount: 5),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
