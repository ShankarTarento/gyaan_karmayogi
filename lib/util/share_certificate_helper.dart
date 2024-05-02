import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShareCertificateHelper {
  static showPopupToSelectSharePlatforms(
      {@required BuildContext context,
      @required Function() onLinkedinTap,
      @required Function() onOtherAppsTap}) {
    ValueNotifier<bool> isShareLinkedinLoading = ValueNotifier(false);
    ValueNotifier<bool> isShareOtherAppsLoading = ValueNotifier(false);
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (ctx) => SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).mStaticShareCertificate,
                      style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  ValueListenableBuilder(
                      valueListenable: isShareLinkedinLoading,
                      builder:
                          (BuildContext context, bool isLoading, Widget child) {
                        return InkWell(
                          onTap: () {
                            try {
                              isShareLinkedinLoading.value = true;
                              onLinkedinTap();
                            } catch (e) {
                              isShareLinkedinLoading.value = false;
                            } finally {
                              isShareLinkedinLoading.value = false;
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: getRoundedButtonWidget(
                              bgColor: AppColors.primaryThree,
                              buttonLabel:
                                  AppLocalizations.of(context).mStaticLinkedIn,
                              isLoading: isLoading,
                              textColor: Colors.white),
                        );
                      }),
                  SizedBox(height: 10),
                  ValueListenableBuilder(
                      valueListenable: isShareOtherAppsLoading,
                      builder:
                          (BuildContext context, bool isLoading, Widget child) {
                        return InkWell(
                          onTap: () async {
                            try {
                              isShareOtherAppsLoading.value = true;
                              await onOtherAppsTap();
                            } catch (e) {
                              isShareOtherAppsLoading.value = false;
                            } finally {
                              isShareOtherAppsLoading.value = false;
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: getRoundedButtonWidget(
                              bgColor: Colors.white,
                              buttonLabel:
                                  AppLocalizations.of(context).mStaticOtherApps,
                              isLoading: isLoading,
                              textColor: AppColors.primaryThree),
                        );
                      }),
                ],
              ),
            )));
  }

  static Widget getRoundedButtonWidget(
      {@required String buttonLabel,
      @required Color bgColor,
      @required Color textColor,
      isLoading = false}) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: FractionalOffset.center,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
        border: bgColor == Colors.white
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: isLoading
          ? PageLoader()
          : Text(
              buttonLabel,
              style: GoogleFonts.montserrat(
                  decoration: TextDecoration.none,
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
    );
  }
}
