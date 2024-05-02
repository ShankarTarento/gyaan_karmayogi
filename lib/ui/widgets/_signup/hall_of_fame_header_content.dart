import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/models/_models/hall_of_fame_mdo_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/hall_of_fame_text_widget.dart';

class HallOfFameHeaderContentWidget extends StatefulWidget {
  final HallOfFameMdoListModel listOfMdo;

  HallOfFameHeaderContentWidget({Key key, @required this.listOfMdo})
      : super(key: key);

  @override
  State<HallOfFameHeaderContentWidget> createState() =>
      _HallOfFameHeaderContentWidgetState();
}

class _HallOfFameHeaderContentWidgetState
    extends State<HallOfFameHeaderContentWidget> {
  MdoList rankOneMdo;
  MdoList rankTwoMdo;
  MdoList rankThreeMdo;
  @override
  void initState() {
    super.initState();
    extractRankedMdo();
  }

  void extractRankedMdo() {
    rankOneMdo = widget.listOfMdo.mdoList.firstWhere(
        (element) => element.rank == 1,
        orElse: () => MdoList.defaultMdo);
    rankTwoMdo = widget.listOfMdo.mdoList.firstWhere(
        (element) => element.rank == 2,
        orElse: () => MdoList.defaultMdo);
    rankThreeMdo = widget.listOfMdo.mdoList.firstWhere(
        (element) => element.rank == 3,
        orElse: () => MdoList.defaultMdo);
  }

  @override
  Widget build(BuildContext context) {
    print('\n' +
        " devicePixelRatio-> " +
        MediaQuery.of(context).devicePixelRatio.toString() +
        '/n');

    final bool largeDisplay = MediaQuery.of(context).devicePixelRatio > 3;
    final bool mediumDisplay = MediaQuery.of(context).devicePixelRatio > 2.5 &&
        MediaQuery.of(context).devicePixelRatio < 3;
    final bool smallDisplay = MediaQuery.of(context).devicePixelRatio < 2.5;

    final double screenWidthPart = MediaQuery.of(context).size.width /
        (smallDisplay
            ? 5.8
            : mediumDisplay
                ? 6
                : largeDisplay
                    ? 6.6
                    : 6.5);
    return Container(
      height: smallDisplay
          ? 550
          : mediumDisplay
              ? 550
              : largeDisplay
                  ? 550
                  : 550,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.darkerBlue,
              AppColors.darkestBlue,
              AppColors.darkerBlue,
            ],
          )),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: -150,
            child: Image.asset(
              HallOfFameAssets.dots,
              color: AppColors.whiteGradientOne,
              // alignment: Alignment.topLeft,
            ),
          ),
          Column(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                  margin: const EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(color: AppColors.orangeBackground),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context).mHallOfFameTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            color: AppColors.ghostWhite,
                            height: 1.28,
                            letterSpacing: 0.25,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700),
                      ),
                      JustTheTooltip(
                        showDuration: const Duration(seconds: 3),
                        tailBaseWidth: 16,
                        triggerMode: TooltipTriggerMode.tap,
                        backgroundColor:
                            AppColors.appBarBackground.withOpacity(1),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.info_outline,
                                color: AppColors.whiteGradientOne, size: 16),
                          ),
                        ),
                        content: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mhallOfFameTooltipInfo,
                              style: GoogleFonts.montserrat(
                                  color: AppColors.black,
                                  height: 1.33,
                                  letterSpacing: 0.25,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        margin: EdgeInsets.all(40),
                      ),
                    ],
                  )),
              //Month and year
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.listOfMdo.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: AppColors.ghostWhite,
                      height: 1.12,
                      letterSpacing: 0.25,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              //Rank, org name annd crown
              Flexible(
                  child: Stack(
                fit: StackFit.passthrough,
                children: [
                  //Rank 2 and org name
                  Positioned(
                      left: (smallDisplay
                          ? 70
                          : mediumDisplay
                              ? 55
                              : largeDisplay
                                  ? 25
                                  : 55),
                      bottom: (smallDisplay
                          ? 170
                          : mediumDisplay
                              ? 170
                              : largeDisplay
                                  ? 190
                                  : 180),
                      child: HallOfFameTextWidget(
                        title: rankTwoMdo.rank.toString(),
                        fontSize: 32,
                        subTitle: rankTwoMdo.orgName,
                      )),
                  //dots png
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset(
                      HallOfFameAssets.dots,
                      color: AppColors.whiteGradientOne,
                    ),
                  ),
                  //Rank 2 piller png
                  Positioned(
                    left: screenWidthPart -
                        (smallDisplay
                            ? 30
                            : mediumDisplay
                                ? 30
                                : largeDisplay
                                    ? 50
                                    : 25),
                    bottom: (smallDisplay
                        ? -20
                        : mediumDisplay
                            ? -20
                            : largeDisplay
                                ? -20
                                : -20),
                    child: Image.asset(
                      HallOfFameAssets.rankTwoBg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  //Rank 3 and org name
                  Positioned(
                      left: screenWidthPart +
                          (smallDisplay
                              ? 190
                              : mediumDisplay
                                  ? 185
                                  : largeDisplay
                                      ? 170
                                      : 185),
                      bottom: (smallDisplay
                          ? 160
                          : mediumDisplay
                              ? 155
                              : largeDisplay
                                  ? 160
                                  : 155),
                      child: HallOfFameTextWidget(
                        title: rankThreeMdo.rank.toString(),
                        fontSize: 24,
                        subTitle: rankThreeMdo.orgName,
                        showClock: showClock(rankThreeMdo),
                      )),
                  //Rank 3 piller png
                  Positioned(
                    left: screenWidthPart *
                        (smallDisplay
                            ? 3.1
                            : mediumDisplay
                                ? 3.2
                                : largeDisplay
                                    ? 3.4
                                    : 3.2),
                    bottom: (smallDisplay
                        ? -20
                        : mediumDisplay
                            ? -20
                            : largeDisplay
                                ? -20
                                : -20),
                    child: Image.asset(
                      HallOfFameAssets.rankThreeBg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  //Rank 1 piller png
                  Positioned(
                    left: screenWidthPart *
                        (smallDisplay
                            ? 1.9
                            : mediumDisplay
                                ? 1.9
                                : largeDisplay
                                    ? 1.8
                                    : 2.1),
                    bottom: (smallDisplay
                        ? -20
                        : mediumDisplay
                            ? -20
                            : largeDisplay
                                ? -20
                                : -20),
                    child: Image.asset(
                      HallOfFameAssets.rankOneBg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  //Rank 1 and org name
                  Positioned(
                      left: screenWidthPart *
                          (smallDisplay
                              ? 2.25
                              : mediumDisplay
                                  ? 2.2
                                  : largeDisplay
                                      ? 2.4
                                      : 2.5),
                      bottom: screenWidthPart +
                          (smallDisplay
                              ? 180
                              : mediumDisplay
                                  ? 190
                                  : largeDisplay
                                      ? 220
                                      : 190),
                      child: HallOfFameTextWidget(
                        title: rankOneMdo.rank.toString(),
                        fontSize: 40,
                        subTitle: rankOneMdo.orgName,
                        showCrown: true,
                      )),
                  //KP Logo rank 2
                  Positioned(
                    bottom: (smallDisplay
                        ? 70
                        : mediumDisplay
                            ? 60
                            : largeDisplay
                                ? 70
                                : 70),
                    left: screenWidthPart -
                        (smallDisplay
                            ? -20
                            : mediumDisplay
                                ? -10
                                : largeDisplay
                                    ? 5
                                    : -20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 27,
                          height: 27,
                          child: SvgPicture.asset(
                            HallOfFameAssets.kp_logo,
                          ),
                        ),
                        Text(
                          rankTwoMdo.averageKp.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              height: 1.28,
                              letterSpacing: 0.25,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                  //KP Logo rank 1
                  Positioned(
                    bottom: (smallDisplay
                        ? 140
                        : mediumDisplay
                            ? 140
                            : largeDisplay
                                ? 140
                                : 130),
                    left: screenWidthPart +
                        (smallDisplay
                            ? 120
                            : mediumDisplay
                                ? 110
                                : largeDisplay
                                    ? 95
                                    : 115),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 27,
                          height: 27,
                          child: SvgPicture.asset(
                            HallOfFameAssets.kp_logo,
                          ),
                        ),
                        Text(
                          rankOneMdo.averageKp.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              height: 1.28,
                              letterSpacing: 0.25,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                  //KP Logo rank 3
                  Positioned(
                    bottom: (smallDisplay
                        ? 50
                        : largeDisplay
                            ? 50
                            : 50),
                    left: screenWidthPart +
                        (smallDisplay
                            ? 220
                            : mediumDisplay
                                ? 210
                                : largeDisplay
                                    ? 190
                                    : 205),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 27,
                          height: 27,
                          child: SvgPicture.asset(
                            HallOfFameAssets.kp_logo,
                          ),
                        ),
                        Text(
                          rankThreeMdo.averageKp.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              height: 1.28,
                              letterSpacing: 0.25,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }

  bool showClock(MdoList mdo) {
    bool showClock = false;
    for (int i = 0; i < widget.listOfMdo.mdoList.length; i++) {
      if (widget.listOfMdo.mdoList[i] !=
          mdo) if (widget.listOfMdo.mdoList[i].averageKp == mdo.averageKp) {
        showClock = true;
        break;
      }
    }
    return showClock;
  }
}
