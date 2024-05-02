import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class FormFieldSectionHeading extends StatelessWidget {
  final String text;
  final bool isSubHeadingText;
  const FormFieldSectionHeading({
    Key key,
    @required this.text,
    this.isSubHeadingText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        color: AppColors.greys87,
        fontWeight: isSubHeadingText ? FontWeight.w500 : FontWeight.w600,
        fontSize: isSubHeadingText ? 15 : 16,
      ),
    );
  }
}
