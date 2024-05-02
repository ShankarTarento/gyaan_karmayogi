import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';

class NoDataWidget extends StatelessWidget {
  final bool isCompleted;
  final double paddingTop;
  final String message;

  const NoDataWidget(
      {Key key, this.isCompleted = false, this.paddingTop = 40, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            Container(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: paddingTop),
                  child: SvgPicture.asset(
                    isCompleted || message != null
                        ? 'assets/img/nodata_default.svg'
                        : 'assets/img/nodata_to_learn.svg',
                    alignment: Alignment.center,
                    // color: AppColors.grey16,
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: isCompleted
                        ? MediaQuery.of(context).size.height * 0.08
                        : MediaQuery.of(context).size.height * 0.13,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
              child: message != null
                  ? Text(
                      message,
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greys87),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    )
                  : isCompleted || message != null
                      ? Text(
                          AppLocalizations.of(context).mStaticNotFound,
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greys87),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        )
                      : InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, AppUrl.learningHub),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .mLearnNoCourseInProgress,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.greys87),
                                ),
                                TextSpan(
                                  text:
                                      ' ${AppLocalizations.of(context).mStaticClickHere}',
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkBlue),
                                ),
                                TextSpan(
                                  text:
                                      ' ${AppLocalizations.of(context).mStaticClickHere}',
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.greys87),
                                )
                              ],
                            ),
                          ),
                        ),
            )
          ],
        ),
      ],
    );
  }
}
