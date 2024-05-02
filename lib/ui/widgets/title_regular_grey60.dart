import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/index.dart';

class TitleRegularGrey60 extends StatelessWidget {
  final String title;
  final int maxLines;
  final Color color;
  final double fontSize;

  const TitleRegularGrey60(this.title,
      {Key key,
      this.maxLines = 1,
      this.color = AppColors.greys60,
      this.fontSize = 12})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.lato(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: fontSize.sp,
        letterSpacing: 0.25.sp,
        height: 1.3,
      ),
    );
  }
}
