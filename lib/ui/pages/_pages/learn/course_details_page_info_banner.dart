import 'package:flutter/material.dart';

import '../../../../constants/_constants/color_constants.dart';
import '../../../../localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CouseDetailsPageInfoBanner extends StatelessWidget {
  final VoidCallback callBack;
  final String days;
  final bool showBanner;
  const CouseDetailsPageInfoBanner(
      {Key key, this.callBack, this.days, this.showBanner})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return showBanner
        ? Container(
            height: 82,
            color: Colors.black.withOpacity(0.7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context).mStaticBatchStartInfo,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white70)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            days +
                                ' ' +
                                AppLocalizations.of(context)
                                    .mStaticBatchStartInfoDays,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ghostWhite)),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: callBack,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.close,
                      color: AppColors.ghostWhite,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
