import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/landing_page_repository.dart';
import 'package:karmayogi_mobile/util/hexcolor.dart';

import '../../../util/helper.dart';


class UserNudgeCard extends StatelessWidget {
  final Profile profileDetails;
  final bool isDisplayUserNudge;
  final LandingPageRepository landingPageRepository;
  final Animation<double> opacityAnimation;
  final int nudgeFadeInOutDuration;
  const UserNudgeCard(
      {Key key,
      this.profileDetails,
      this.isDisplayUserNudge,
      this.landingPageRepository,
      this.opacityAnimation,
      this.nudgeFadeInOutDuration,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(17, 16, 17, 16).w,
      child: landingPageRepository.userNudgeInfo.backgroundImage.isNotEmpty
          ? Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.network(
                  landingPageRepository.userNudgeInfo.backgroundImage,
                  width: 1.sw,
                  fit: BoxFit.fill,
                  height: 330.h,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0).w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.network(
                          landingPageRepository.userNudgeInfo.centerImage,
                          width: 0.3.sw,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        AnimatedOpacity(
                          duration: Duration(milliseconds: nudgeFadeInOutDuration + 1000),
                          opacity: isDisplayUserNudge
                              ? opacityAnimation.value
                              : opacityAnimation.value,
                          child: SizedBox(
                            width: 0.5.sw,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    landingPageRepository.userNudgeInfo.text
                                        .replaceAll(
                                        "<userName>",
                                        profileDetails.firstName != null
                                            ? Helper.capitalizeFirstLetter(
                                            profileDetails.firstName
                                                .split(' ')
                                                .first)
                                            : ""),
                                    style: GoogleFonts.montserrat(
                                      color: HexColor(landingPageRepository
                                          .userNudgeInfo.textColor),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      letterSpacing: 0.12,
                                    )),
                                SizedBox(
                                  height: 8.w,
                                ),
                                Text(landingPageRepository.userNudgeInfo.content,
                                    style: GoogleFonts.lato(
                                      color: HexColor(landingPageRepository
                                          .userNudgeInfo.textColor),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.sp,
                                      letterSpacing: 0.12,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
