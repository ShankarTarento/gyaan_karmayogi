import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../../constants/index.dart';

class TooltipWidget extends StatelessWidget {
  final String message;
  final double iconSize;
  final Color iconColor, textColor;
  final double width;
  final TooltipTriggerMode triggerMode;

  TooltipWidget(
      {Key key,
      @required this.message,
      this.iconSize = 16,
      this.iconColor = AppColors.greys60,
      this.textColor = AppColors.avatarText,
      this.width = 300,
      this.triggerMode = TooltipTriggerMode.tap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      showDuration: Duration(seconds: 3),
      tailBaseWidth: 16,
      triggerMode: triggerMode,
      backgroundColor: AppColors.greys60,
      child: Icon(
        Icons.info_outline_rounded,
        color: iconColor,
        size: iconSize,
      ),
      content: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            message,
            style: GoogleFonts.lato(
                color: textColor,
                height: 1.33,
                letterSpacing: 0.25,
                fontSize: 12.0,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
