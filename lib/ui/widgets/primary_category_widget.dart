import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/index.dart';
import '../../util/helper.dart';

class PrimaryCategoryWidget extends StatelessWidget {
  final String contentType;
  final bool addedMargin;
  final Color bgColor, textColor;

  const PrimaryCategoryWidget(
      {Key key,
      this.contentType,
      this.addedMargin = false,
      this.bgColor = AppColors.orangeFaded,
      this.textColor = AppColors.greys60})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: addedMargin ? 0 : 16),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.orangeTourText, width: 1)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/img/play_course.svg',
              width: 12.0,
              height: 12.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Text(
                contentType != null && contentType != ''
                    ? Helper().capitalizeFirstCharacter(contentType)
                    : '',
                style: GoogleFonts.lato(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
