import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/hall_of_fame.dart';

class IntroFourBody extends StatefulWidget {
  const IntroFourBody({Key key}) : super(key: key);

  @override
  State<IntroFourBody> createState() => _IntroFourBodyState();
}

class _IntroFourBodyState extends State<IntroFourBody> {
  @override
  Widget build(BuildContext context) {
    return HallOfFameWidget();
  }
}
