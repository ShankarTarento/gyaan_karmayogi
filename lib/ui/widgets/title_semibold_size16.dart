import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/index.dart';

class TitleSemiboldSize16 extends StatelessWidget {
  final String title;
  final int maxLines;

  const TitleSemiboldSize16(this.title, {Key key, this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
            color: AppColors.greys87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.12,
            height: 1.5));
  }
}
