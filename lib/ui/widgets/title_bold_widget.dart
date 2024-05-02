import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/index.dart';

class TitleBoldWidget extends StatelessWidget {
  final String title;
  final int maxLines;
  final double fontSize;
  final double letterSpacing;
  final Color color;

  const TitleBoldWidget(this.title,
      {Key key,
      this.maxLines = 1,
      this.fontSize = 16,
      this.letterSpacing = 0.12,
      this.color = AppColors.greys87})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title != null ? title : '',
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          height: 1.5,
        ));
  }
}
