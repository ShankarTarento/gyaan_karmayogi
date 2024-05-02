import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/hall_of_fame_mdo_model.dart';

class HallOfFameListItemWidget extends StatelessWidget {
  final MdoList mdoListItem;
  final bool showClock;
  const HallOfFameListItemWidget(
      {Key key, @required this.mdoListItem, @required this.showClock})
      : super(key: key);

  bool get isPositive => mdoListItem.negativeOrPositive == 'positive';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.voiletCardBg.withOpacity(0.8),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ),
                child: mdoListItem.progress == 0
                    ? SizedBox(
                        width: 20,
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            mdoListItem.progress.toString(),
                            style: GoogleFonts.lato(
                              color: isPositive
                                  ? AppColors.greenOne
                                  : AppColors.avatarRed,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            isPositive
                                ? HallOfFameAssets.up
                                : HallOfFameAssets.down,
                            color: isPositive
                                ? AppColors.greenOne
                                : AppColors.avatarRed,
                          )
                        ],
                      ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18.0),
                width: 50,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.whiteGradientOne,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                ),
                child: Center(
                  child: Text(
                    mdoListItem.rank.toString(),
                    style: GoogleFonts.montserrat(
                      color: AppColors.voiletCardBg,
                      fontSize: 22.0,
                      letterSpacing: 0.12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              JustTheTooltip(
                showDuration: const Duration(seconds: 3),
                tailBaseWidth: 16,
                triggerMode: TooltipTriggerMode.tap,
                backgroundColor: AppColors.appBarBackground.withOpacity(1),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Visibility(
                      visible: showClock,
                      child: SvgPicture.asset(
                        HallOfFameAssets.clock,
                        width: 16.0,
                        height: 16.0,
                      ),
                    ),
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      AppLocalizations.of(context).mHallOfFameClockInfo,
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
              Spacer(),
              SizedBox(
                width: 27,
                height: 27,
                child: SvgPicture.asset(
                  HallOfFameAssets.kp_logo,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                ),
                child: Text(
                  mdoListItem.averageKp.toStringAsFixed(1),
                  style: GoogleFonts.lato(
                    color: AppColors.whiteGradientOne,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Image(
                        height: 20,
                        width: 20,
                        fit: BoxFit.fitHeight,
                        image: AssetImage(HallOfFameAssets.emblem_logo)),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  child: Text(
                    mdoListItem.orgName,
                    style: GoogleFonts.lato(
                      color: AppColors.whiteGradientOne,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
