import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';

class HomeHubItemNew extends StatelessWidget {
  final int id;
  final String title;
  final Object icon;
  final Object iconColor;
  final String url;
  final bool displayNotification;
  final String svgIcon;

  const HomeHubItemNew(
    this.id,
    this.title,
    this.icon,
    this.iconColor,
    this.url,
    this.displayNotification,
    this.svgIcon, {
    Key key,
  }) : super(key: key);

  List<Widget> _buildItems() {
    List<Widget> stackElements = [];
    stackElements.add(Stack(children: <Widget>[
      Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                width: 1,
                color: AppColors.darkBlue,
                style: BorderStyle.solid,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: svgIcon.isNotEmpty
                  ? SvgPicture.asset(
                      svgIcon,
                      width: 24.0,
                      height: 24.0,
                    )
                  : Icon(
                      Icons.menu_book,
                      color: AppColors.darkBlue,
                    ),
            ),
          ),
          title.length > 10
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
        ],
      ),
    ]));
    if (displayNotification) {
      stackElements.add(Positioned(
        // draw a red marble
        top: -1,
        right: -1,
        child: new Icon(Icons.brightness_1,
            size: 12.0, color: AppColors.negativeLight),
      ));
    }
    return stackElements;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
        child: Stack(children: _buildItems()));
  }
}
