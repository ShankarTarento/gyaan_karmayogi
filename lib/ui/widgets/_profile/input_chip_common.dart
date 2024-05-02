import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class InputChipWidget extends StatelessWidget {
  final Function() onAddTap;
  final Function() onDeleted;
  final dynamic text;
  InputChipWidget({
    Key key,
    this.onAddTap,
    this.onDeleted,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: InputChip(
        padding: EdgeInsets.all(10.0),
        backgroundColor: AppColors.lightOrange,
        label: Text(
          text.toString(),
          style: GoogleFonts.lato(
            color: AppColors.greys87,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
        deleteIcon: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              top: -3.5,
              left: -4.5,
              right: 0,
              child: Icon(Icons.cancel, size: 25.0, color: AppColors.grey40),
            ),
          ],
        ),
        onDeleted: onDeleted,
      ),
    );
  }
}
