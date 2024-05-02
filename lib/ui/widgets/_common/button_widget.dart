import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color bgColor, borderColor, textColor;
  const ButtonWidget(
      {Key key,
      @required this.onPressed,
      @required this.title,
      this.bgColor = AppColors.darkBlue,
      this.borderColor = AppColors.darkBlue,
      this.textColor = AppColors.appBarBackground})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shadowColor: Colors.transparent,
          fixedSize: Size(166, 40),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(63.0),
          ),
          side: BorderSide(color: borderColor),
        ),
        child: TitleBoldWidget(
          title,
          fontSize: 14,
          color: textColor,
        ));
  }
}
