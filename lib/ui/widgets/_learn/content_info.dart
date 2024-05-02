import 'package:flutter/material.dart';

import '../../../constants/_constants/color_constants.dart';

class ContentInfo extends StatelessWidget {
  final String infoMessage;
  final bool isReport;
  final icon;
  const ContentInfo(
      {Key key,
      this.infoMessage,
      this.isReport = false,
      this.icon = Icons.info_outline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Tooltip(
        child: Icon(
          icon,
          color: isReport
              ? AppColors.primaryThree
              : (icon == Icons.flag_rounded
                  ? AppColors.greys60
                  : AppColors.greys87),
        ),
        // textStyle: GoogleFonts.lato(color: AppColors.greys87),
        message: infoMessage
            .replaceAll('<p class="ws-mat-primary-text">', '')
            .replaceAll('</p>', ''),
        showDuration: Duration(
            seconds: (isReport || icon == Icons.flag_rounded) ? 5 : 10),
        // preferBelow: false,
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(left: 32, right: 32),
        verticalOffset: 20,
        triggerMode: TooltipTriggerMode.tap,
      ),
    );
  }
}
