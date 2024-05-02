import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/_respositories/in_app_review_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/_constants/app_constants.dart';
import '../../constants/_constants/color_constants.dart';
import '../../constants/_constants/storage_constants.dart';
import '../../constants/_constants/telemetry_constants.dart';
import '../../localization/_langs/english_lang.dart';
import '../../models/_models/telemetry_event_model.dart';
import '../../respositories/_respositories/nps_repository.dart';
import '../../util/telemetry.dart';
import '../../util/telemetry_db_helper.dart';

class NPSFeedback extends StatefulWidget {
  final Map<String, dynamic> formFields;
  final int formId;
  final String feedId;

  NPSFeedback(this.formFields, this.formId, this.feedId);
  @override
  FeedbackState createState() => FeedbackState();
}

class FeedbackState extends State<NPSFeedback>
    with SingleTickerProviderStateMixin {
  bool showSubmitBtn = false;
  int rating = 0;
  bool submit = false;
  String response;
  bool showAnimation = true;
  TextEditingController reviewController = TextEditingController();
  String hintText = "Inspire others by sharing your experience";
  final _storage = FlutterSecureStorage();

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  List allEventsData = [];
  var telemetryEventData;
  Map<String, dynamic> formFields;
  bool isClosePopUpShown = false;
  int _start = 0;

  @override
  void initState() {
    super.initState();
    _getFormById(widget.formId);
    reviewController.text = '';
    _triggerStartTelemetryEvent();
  }

  void _triggerStartTelemetryEvent() async {
    startTimer();
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();

    Map eventData = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.platformRatingPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.platformRatingPageUri,
        env: TelemetryEnv.platformRating);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());

    allEventsData.add(eventData);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _triggerEndTelemetryEvent() async {
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.platformRatingPageId,
        userSessionId,
        messageIdentifier,
        _start * 1000,
        TelemetryType.page,
        TelemetryPageIdentifier.platformRatingPageUri,
        {},
        env: TelemetryEnv.platformRating);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<void> _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.platformRatingPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        rating.toString(),
        env: TelemetryEnv.platformRating,
        objectType: TelemetrySubType.platformRatingSubmit);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _getFormById(formId) async {
    if (formId == null) return;
    formFields = await Provider.of<NpsRepository>(context, listen: false)
        .getFormById(formId);
    setState(() {});
  }

  Future<void> _submitForm() async {
    String userId = await _storage.read(key: Storage.userId);
    response = await Provider.of<NpsRepository>(context, listen: false)
        .submitForm(formFields, reviewController.text, rating, widget.formId);
    String result = await Provider.of<NpsRepository>(context, listen: false)
        .deleteNPSFeed(userId, widget.feedId);
    if (result.toLowerCase().compareTo('success') == 0) {
      await _storage.write(key: Storage.showRatingPlatform, value: 'false');
    }
  }

  Widget showSmiley(rating) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1.5, color: AppColors.primaryBlue),
      ),
      child: Image(
        image: AssetImage('assets/img/rating_$rating.png'),
        height: 40,
      ),
    );
  }

  Widget getAnimatedWidget() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image(
              image: AssetImage('assets/img/karmasahayogi.png'),
              height: 160,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey16,
                  blurRadius: 3.0,
                  spreadRadius: 3,
                  offset: Offset(-3.0, -3.0),
                ),
                BoxShadow(
                  color: AppColors.primaryBlue,
                  blurRadius: 3.0,
                  spreadRadius: 4,
                  offset: Offset(-1.0, -1.0),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () async {
                            rating = 0;
                            if (!submit) {
                              await _submitForm();
                              await _generateInteractTelemetryData(
                                  EnglishLang.platformRatingClose);
                              await _triggerEndTelemetryEvent();
                            }
                            isClosePopUpShown = false;
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 1, color: AppColors.grey16),
                            ),
                            child: Icon(Icons.close,
                                color: AppColors.greys60, size: 16),
                          ),
                        )),
                  ),
                  !submit
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                !showSubmitBtn
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.2,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                      .mRatingHowLikelyAreYouToRecommed +
                                                  AppLocalizations.of(context)
                                                      .mRatingIgotToColleagues,
                                              style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontSize: 16,
                                                  letterSpacing: 0.12,
                                                  fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                          // Text(
                                          //     AppLocalizations.of(context)
                                          //         .mRatingIgotToColleagues,
                                          //     style: GoogleFonts.lato(
                                          //         color: AppColors.greys87,
                                          //         fontSize: 16,
                                          //         letterSpacing: 0.12,
                                          //         fontWeight: FontWeight.w700)),
                                        ],
                                      )
                                    : Center(),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 40, right: 40),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 2,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: showSubmitBtn
                                          ? const EdgeInsets.only(
                                              top: 0, bottom: 4)
                                          : const EdgeInsets.only(
                                              top: 10, bottom: 4),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mRatingNotLikely,
                                        style: GoogleFonts.lato(
                                          color: AppColors.grey40,
                                          fontSize: 12,
                                          letterSpacing: 0.09,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...List.generate(
                                    RATING_LIMIT,
                                    (index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: InkWell(
                                              child: (showSubmitBtn &&
                                                      rating == index + 1)
                                                  ? showSmiley(rating)
                                                  : Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            width: 1,
                                                            color: AppColors
                                                                .primaryBlue),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            color: Color(
                                                                0XFF1B2133),
                                                            fontSize: 16,
                                                            letterSpacing: 0.25,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      )),
                                              onTap: () {
                                                setState(() {
                                                  if (rating == index + 1) {
                                                    showSubmitBtn = false;
                                                    rating = 0;
                                                    showAnimation = true;
                                                  } else {
                                                    showSubmitBtn = true;
                                                    rating = index + 1;
                                                    if (rating < 4) {
                                                      hintText = AppLocalizations
                                                              .of(context)
                                                          .mRatingHowCanWeMakeItBetter;
                                                    } else {
                                                      hintText = AppLocalizations
                                                              .of(context)
                                                          .mRatingInspireOthers;
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Container(
                                        width: 60,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mRatingExtremelyLikely,
                                          maxLines: 2,
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.lato(
                                            color: AppColors.grey40,
                                            fontSize: 12,
                                            letterSpacing: 0.09,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            showSubmitBtn
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Column(
                                      children: <Widget>[
                                        Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            // color: Colors.grey,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: AppColors.grey16)),
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: reviewController,
                                                  maxLines: 4,
                                                  maxLength: 500,
                                                  style: GoogleFonts.lato(
                                                      color: Color(0XFF000000),
                                                      fontSize: 14,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  buildCounter: (BuildContext
                                                              context,
                                                          {int currentLength,
                                                          int maxLength,
                                                          bool isFocused}) =>
                                                      null,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                    hintText: hintText,
                                                    hintStyle: GoogleFonts.lato(
                                                        color: AppColors.grey40,
                                                        fontSize: 14,
                                                        letterSpacing: 0.25,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  await _submitForm();
                                                  await _generateInteractTelemetryData(
                                                      EnglishLang
                                                          .platformRatingSubmit);
                                                  await _triggerEndTelemetryEvent();

                                                  setState(() {
                                                    submit = true;
                                                    isClosePopUpShown = true;
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 3000),
                                                        () async {
                                                      if (isClosePopUpShown) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        await Provider.of<
                                                                    InAppReviewRespository>(
                                                                context,
                                                                listen: false)
                                                            .setOtherPopupVisibleStatus(
                                                                false);
                                                      }
                                                    });
                                                  });
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Color(
                                                                0XFF1B4CA1))),
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .mStaticSubmit,
                                                    style: GoogleFonts.lato(
                                                        color: AppColors
                                                            .scaffoldBackground,
                                                        fontSize: 14,
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Center(),
                          ],
                        )
                      : ConfirmationPopUp(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(seconds: 1), // Duration for the animation
      curve: Curves.fastOutSlowIn, // Animation curve (e.g., ease-in-out)
      child: getAnimatedWidget(),
    );
  }
}

class ConfirmationPopUp extends StatelessWidget {
  const ConfirmationPopUp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27.0, 0, 27.0, 30),
      child: Text(AppLocalizations.of(context).mRatingThanksForFeedBack,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
              fontSize: 16,
              letterSpacing: 0.12,
              fontWeight: FontWeight.w400,
              color: Color(0XFF1B2133))),
    );
  }
}
