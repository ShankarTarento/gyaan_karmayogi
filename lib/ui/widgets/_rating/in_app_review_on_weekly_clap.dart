import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/services/_services/feed_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_buttons/animated_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';

class InAppReviewPopupOnWeeklyClap extends StatefulWidget {
  final BuildContext parentContext;
  final String feedId;
  const InAppReviewPopupOnWeeklyClap(
      {Key key, @required this.parentContext, @required this.feedId})
      : super(key: key);

  @override
  State<InAppReviewPopupOnWeeklyClap> createState() =>
      _InAppReviewPopupOnWeeklyClapState();
}

class _InAppReviewPopupOnWeeklyClapState
    extends State<InAppReviewPopupOnWeeklyClap> {
  final FeedService feedService = FeedService();
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _loadTelemetryData();
  }

  _loadTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.weeklyClaps.toLowerCase(),
        env: EnglishLang.home,
        objectType: TelemetrySubType.profile);
    // print(jsonEncode(eventData));
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.seaShell,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 24),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/img/clap_icon.svg',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      AppLocalizations.of(widget.parentContext)
                          .mRateOnWeeklyClapCongratsText,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: GoogleFonts.montserrat(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16))),
                padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(widget.parentContext)
                          .mRateOnWeeklyClapCongratsDescription,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: GoogleFonts.montserrat(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonClickEffect(
                        child: Text(AppLocalizations.of(widget.parentContext)
                            .mRateOnWeeklyClapRateText),
                        onTap: () {
                          _generateInteractTelemetryData(
                              TelemetryConstants.rateNow);
                          feedService.deleteInAppReviewFeed(
                              feedId: widget.feedId);
                          final InAppReview inAppReview = InAppReview.instance;
                          inAppReview.openStoreListing(
                              appStoreId: APP_STORE_ID);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    TextButton(
                        onPressed: () {
                          _generateInteractTelemetryData(
                              TelemetryConstants.mayBeLater);
                          feedService.deleteInAppReviewFeed(
                              feedId: widget.feedId);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(widget.parentContext)
                              .mRateOnWeeklyClapLaterText,
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkBlue),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
