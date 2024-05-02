import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class CompetencyPassbookThemeChipsWidget extends StatelessWidget {
  final chipText;
  const CompetencyPassbookThemeChipsWidget({Key key, @required this.chipText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: AppColors.darkBlue)),
      child: Text(
        chipText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
            height: 1.5,
            color: AppColors.darkBlue,
            fontSize: 12,
            fontWeight: FontWeight.w400),
      ),
    );
  }
}
