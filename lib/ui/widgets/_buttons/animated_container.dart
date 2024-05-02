import 'package:flutter/material.dart';

import '../../../constants/_constants/app_constants.dart';
import '../../../constants/_constants/color_constants.dart';

class ButtonClickEffect extends StatelessWidget {
  const ButtonClickEffect({Key key, this.child, this.onTap, this.opacity = 1.0})
      : super(key: key);

  final Widget child;
  final VoidCallback onTap;
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        height: 40,
        duration: BUTTON_ANIMATION_DURATION,
        curve: Curves.bounceInOut,
        child: ElevatedButton(
            onPressed: onTap,
            child: child,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue.withOpacity(opacity),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(63),
              ),
            )));
  }
}
