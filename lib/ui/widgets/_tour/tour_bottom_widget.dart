import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import '../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourBottomWidget extends StatefulWidget {
  final String title;
  final String description;
  final String insidetitle;
  final VoidCallback onTap;
  final bool isTapped;
  final bool isPreviousTapped;
  final VoidCallback onPerviousTap;
  bool isProfileTapped = false;
  bool isDiscussTapped = false;
  final IconData icon;
  final VoidCallback onCloseTap;

  TourBottomWidget(
      {@required this.title,
      @required this.description,
      @required this.insidetitle,
      @required this.onTap,
      @required this.onPerviousTap,
      @required this.isProfileTapped,
      @required this.isDiscussTapped,
      @required this.icon,
      this.isTapped = false,
      this.isPreviousTapped = false,
      @required this.onCloseTap});
  @override
  State<TourBottomWidget> createState() => _TourBottomWidgetState();
}

class _TourBottomWidgetState extends State<TourBottomWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          closeWidget(),
          ClipPath(
            clipper: BottomClipper(),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 430,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: (Radius.elliptical(100, 0)),
                          bottomRight: Radius.elliptical(100, 0)),
                      color: AppColors.darkBlue,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 130),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Text(widget.title,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: Color.fromRGBO(255, 255, 255, 0.95),
                                  fontSize: 20,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 8),
                          child: Text(widget.description,
                              maxLines: 2,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: Color.fromRGBO(255, 255, 255, 0.95),
                                  fontSize: 14,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5)),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: widget.onPerviousTap,
                              child: Text(
                                  AppLocalizations.of(context).mTourPrevious,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.95),
                                      fontSize: 14,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width: 15,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.verifiedBadgeIconColor,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                  AppLocalizations.of(context).mTourNext,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.orangeTourText,
                                      fontSize: 14,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(right: 87),
                          child: Transform.translate(
                            offset: Offset(0, 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.orangeTourText,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: Icon(
                                          widget.icon,
                                          size: 25,
                                          color: AppColors.black40,
                                        )),
                                        Text(widget.insidetitle,
                                            style: GoogleFonts.lato(
                                                decoration: TextDecoration.none,
                                                color: AppColors.black40,
                                                fontSize: 14,
                                                letterSpacing: 0.12,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget closeWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 30, right: 10),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: AppColors.black40,
                borderRadius: BorderRadius.circular(100)),
            child: IconButton(
                onPressed: widget.onCloseTap,
                icon: Icon(
                  Icons.close,
                  size: 15,
                  color: Colors.white,
                ))),
      ),
    );
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // Start from the bottom-left corner
    path.lineTo(size.width, size.height); // Move to the bottom-right corner
    path.lineTo(size.width,
        120); // Create a straight line at a desired height from the bottom
    path.quadraticBezierTo(size.width / 2, 0, 0,
        120); // Create a curve connecting to the top-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(0.0, size.height / 1.4);
    path.lineTo(size.width, size.height / 1.4);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
