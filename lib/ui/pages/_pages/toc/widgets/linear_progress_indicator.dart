import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class LinearProgressIndicatorWidget extends StatelessWidget {
  final double value;
  final bool isExpnaded;
  final bool isCourse;

  LinearProgressIndicatorWidget(
      {Key key, @required this.value, @required this.isExpnaded, @required this.isCourse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: GoogleFonts.lato(
            color: isExpnaded && isCourse ? 
            AppColors.appBarBackground : AppColors.darkBlue,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            letterSpacing: 0.25
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.75,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: isExpnaded ? AppColors.white016 : AppColors.grey16,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeTourText),
          ),
        ),
      ],
    );
  }
}
