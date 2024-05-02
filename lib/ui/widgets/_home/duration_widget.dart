import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';

class DurationWidget extends StatelessWidget {
  final String duration;

  const DurationWidget(this.duration, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greys87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/img/clock_white.svg',
            width: 16.0,
            height: 16.0,
          ),
          SizedBox(
            width: 4,
          ),
          Text(duration,
              style: GoogleFonts.lato(
                color: AppColors.avatarText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}
