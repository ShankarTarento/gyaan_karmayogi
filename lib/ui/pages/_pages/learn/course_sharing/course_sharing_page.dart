import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/chips_input.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/course_sharing_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_buttons/animated_container.dart';
import '../../../../../constants/_constants/api_endpoints.dart';
import '../../../../../constants/_constants/color_constants.dart';
import '../../../../../feedback/widgets/_microSurvey/page_loader.dart';
import '../../../../../respositories/_respositories/profile_repository.dart';
import '../../../../../util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../widgets/title_regular_grey60.dart';

class CourseSharingPage extends StatefulWidget {
  final int formId;
  final String courseId;
  final String courseName;
  final String coursePosterImageUrl;
  final String courseProvider;
  final String primaryCategory;
  final Function(String) callback;

  CourseSharingPage(
      this.formId,
      this.courseId,
      this.courseName,
      this.coursePosterImageUrl,
      this.courseProvider,
      this.primaryCategory,
      this.callback);
  @override
  _CourseSharingPageState createState() => _CourseSharingPageState();
}

class _CourseSharingPageState extends State<CourseSharingPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final ProfileService profileService = ProfileService();
  final ProfileRepository profileRepository = ProfileRepository();
  List<CourseSharingUserDataModel> selectedRecipients =
      <CourseSharingUserDataModel>[];
  List<CourseSharingUserDataModel> recipientList =
      <CourseSharingUserDataModel>[];
  int searchSize = 250;
  int maxRecipient = 30;
  bool showDialogWidget = false;
  String dialogType = "warning";
  String dialogMessage = "";

  @override
  void initState() {
    super.initState();
  }

  Future<List> _getRecipientList(String query, int limit) async {
    try {
      var response = await profileRepository.getRecipientList(query, limit);
      if (response != null) {
        recipientList = [];
        recipientList = response
            .map((userData) => CourseSharingUserDataModel.fromJson(userData))
            .toList();
      }
    } catch (err) {
      debugPrint("ERROR_LOG====> $err");
      throw err;
    }
  }

  Widget getAnimatedWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 26.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey40,
                        ),
                        child: Icon(Icons.close,
                            color: AppColors.whiteGradientOne, size: 16),
                      ),
                    )),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 16),
                child: Image(
                  image: AssetImage('assets/img/karmasahayogi.png'),
                  height: 160,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).mContentSharePageHeading,
                      style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontSize: 16,
                          letterSpacing: 0.12,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: ChipsInput<CourseSharingUserDataModel>(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    top: 4.0,
                                    left: 46), // Move hint text to the top
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                    color: AppColors.darkBlue
                                        .withOpacity(1.0), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                    color: AppColors.darkBlue
                                        .withOpacity(1.0), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                prefixStyle: GoogleFonts.lato(
                                    color: AppColors.darkBlue.withOpacity(1.0),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.25),
                                hintStyle: GoogleFonts.lato(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.25),
                              ),
                              findSuggestions: _findSuggestions,
                              onChanged: _onChanged,
                              chipBuilder: (BuildContext context,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state,
                                  CourseSharingUserDataModel profile) {
                                return Container(
                                  // alignment: Alignment.centerLeft,
                                  child: InputChip(
                                    key: ObjectKey(profile),
                                    label: Text(
                                      profile.firstName,
                                      style: GoogleFonts.lato(
                                          color: AppColors.darkBlue
                                              .withOpacity(1.0),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          letterSpacing: 0.25),
                                    ),
                                    deleteIcon: Icon(
                                      Icons.close_sharp,
                                      color:
                                          AppColors.darkBlue.withOpacity(1.0),
                                      size: 24.0, // Adjust icon size
                                    ),
                                    backgroundColor: AppColors.grey08,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          16.0), // Adjust border radius
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    onDeleted: () {
                                      setState(() {
                                        selectedRecipients.remove(profile);
                                        state.deleteChip(selectedRecipients);
                                      });
                                    },
                                    onSelected: (_) => _onChipTapped(profile),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                );
                              },
                              suggestionBuilder: (BuildContext context,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state,
                                  CourseSharingUserDataModel profile) {
                                return ListTile(
                                  key: ObjectKey(profile),
                                  leading: (((profile
                                                  .profileDetails
                                                  .personalDetails
                                                  .profileImageUrl) ??
                                              "") !=
                                          '')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(63),
                                          child: Image(
                                            height: 32,
                                            width: 32,
                                            fit: BoxFit.fitWidth,
                                            image: NetworkImage(profile
                                                        .profileDetails
                                                        .personalDetails
                                                        .profileImageUrl !=
                                                    null
                                                ? profile
                                                    .profileDetails
                                                    .personalDetails
                                                    .profileImageUrl
                                                : ''),
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox.shrink(),
                                          ),
                                        )
                                      : Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.profilebgGrey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              Helper.getInitialsNew(
                                                  (profile.firstName != null
                                                          ? profile.firstName
                                                          : '') +
                                                      ' ' +
                                                      (profile.firstName != null
                                                          ? profile.firstName
                                                          : '')),
                                              style: GoogleFonts.lato(
                                                  color: AppColors.avatarText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ),
                                  title: Text(profile.firstName,
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing: 0.25)),
                                  subtitle: Text(profile.maskedEmail,
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          letterSpacing: 0.25)),
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    state.resetSuggestion();
                                    if (alreadyInList(profile.userId)) {
                                      setState(() {
                                        showDialogWidget = true;
                                        dialogType = "warning";
                                        dialogMessage = AppLocalizations.of(
                                                context)
                                            .mContentSharePageSimilarEmailWarning;
                                      });
                                      Future.delayed(Duration(seconds: 3), () {
                                        if (mounted)
                                          setState(() {
                                            showDialogWidget = false;
                                          });
                                      });
                                    } else {
                                      if (selectedRecipients.length.toInt() <
                                          maxRecipient.toInt()) {
                                        print(
                                            'TEST_LOG======profile=====>${profile}');
                                        setState(() {
                                          selectedRecipients.add(profile);
                                        });
                                        state.selectSuggestion(
                                            selectedRecipients);
                                      } else {
                                        setState(() {
                                          showDialogWidget = true;
                                          dialogType = "warning";
                                          dialogMessage = AppLocalizations.of(
                                                  context)
                                              .mContentSharePageEmailLimitWarning;
                                        });
                                        Future.delayed(Duration(seconds: 3),
                                            () {
                                          if (mounted)
                                            setState(() {
                                              showDialogWidget = false;
                                            });
                                        });
                                      }
                                    }
                                  },
                                );
                              },
                              onPerformAction: (TextInputAction action,
                                  String text,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state) {
                                if (action == TextInputAction.done) {
                                  _validateEmail(text, state);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width) * 0.7,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mContentSharePageNote,
                                  style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 12,
                                      letterSpacing: 0.25,
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Text(
                                "${selectedRecipients.length}/${maxRecipient} emails",
                                style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (showDialogWidget) _showDialog(),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(
                                    text:
                                        "${ApiUrl.baseUrl}/app/toc/${widget.courseId}"));
                                setState(() {
                                  showDialogWidget = true;
                                  dialogType = "success";
                                  dialogMessage = AppLocalizations.of(context)
                                      .mContentSharePageLinkCopied;
                                });
                                Future.delayed(Duration(seconds: 3), () {
                                  if (mounted)
                                    setState(() {
                                      showDialogWidget = false;
                                    });
                                });
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context).mCopyLink,
                                        style: GoogleFonts.lato(
                                            color: AppColors.darkBlue
                                                .withOpacity(1.0),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            letterSpacing: 0.5)),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.link,
                                      color:
                                          AppColors.darkBlue.withOpacity(1.0),
                                      size: 20,
                                    )
                                  ]),
                            ),
                            SizedBox(
                              width: 26,
                            ),
                            ButtonClickEffect(
                                onTap: () async {
                                  if ((selectedRecipients ?? []).isNotEmpty) {
                                    if (isLoading) return;
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await submitForm();
                                  } else {
                                    setState(() {
                                      showDialogWidget = true;
                                      dialogType = "warning";
                                      dialogMessage = AppLocalizations.of(
                                              context)
                                          .mContentSharePageEmptyEmailWarning;
                                    });
                                    Future.delayed(Duration(seconds: 3), () {
                                      if (mounted)
                                        setState(() {
                                          showDialogWidget = false;
                                        });
                                    });
                                  }
                                },
                                opacity: 1.0,
                                child: Container(
                                  width: 80,
                                  child: isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PageLoader(),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)
                                                    .mStaticSend,
                                                style: GoogleFonts.lato(
                                                    color: AppColors.avatarText,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    letterSpacing: 0.5)),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.send,
                                              color: AppColors.avatarText,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                )),
                          ],
                        ))
                  ],
                )),
          ),
        ),
      ],
    );
  }

  void _validateEmail(
      String value, ChipsInputState<CourseSharingUserDataModel> state) {
    RegExp regExp = RegExp(
        r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");
    if (value.isNotEmpty) {
      String matchedString = regExp.stringMatch(value) ?? "";
      if (matchedString.isNotEmpty && matchedString.length == value.length) {
        if (alreadyInList(value)) {
          setState(() {
            showDialogWidget = true;
            dialogType = "warning";
            dialogMessage = AppLocalizations.of(context)
                .mContentSharePageSimilarEmailWarning;
          });
          Future.delayed(Duration(seconds: 3), () {
            if (mounted)
              setState(() {
                showDialogWidget = false;
              });
          });
        } else {
          if (selectedRecipients.length.toInt() < maxRecipient.toInt()) {
            CourseSharingUserDataModel profile = CourseSharingUserDataModel(
                firstName: value,
                profileDetails: ProfileDetails(
                    personalDetails: PersonalDetails(
                        profileImageUrl: "", primaryEmail: value)),
                maskedEmail: value,
                userId: value);

            setState(() {
              selectedRecipients.add(profile);
            });
            state.selectSuggestion(selectedRecipients);
          } else {
            setState(() {
              showDialogWidget = true;
              dialogType = "warning";
              dialogMessage = AppLocalizations.of(context)
                  .mContentSharePageEmailLimitWarning;
            });
            Future.delayed(Duration(seconds: 3), () {
              if (mounted)
                setState(() {
                  showDialogWidget = false;
                });
            });
          }
        }
      } else {
        setState(() {
          showDialogWidget = true;
          dialogType = "warning";
          dialogMessage =
              AppLocalizations.of(context).mContentSharePageInvalidEmailError;
        });
        Future.delayed(Duration(seconds: 3), () {
          if (mounted)
            setState(() {
              showDialogWidget = false;
            });
        });
      }
    }
  }

  void _onChipTapped(CourseSharingUserDataModel profile) {}

  void _onChanged(List<CourseSharingUserDataModel> data) {}

  Future<List<CourseSharingUserDataModel>> _findSuggestions(
      String query) async {
    if (selectedRecipients.length.toInt() < maxRecipient.toInt()) {
      if (query.length != 0 && query.length >= 1) {
        await _getRecipientList(query, searchSize);
        return recipientList;
      } else {
        return [];
      }
    } else {
      recipientList = [];
      setState(() {
        showDialogWidget = true;
        dialogType = "warning";
        dialogMessage =
            AppLocalizations.of(context).mContentSharePageEmailLimitWarning;
      });
      Future.delayed(Duration(seconds: 3), () {
        if (mounted)
          setState(() {
            showDialogWidget = false;
          });
      });
    }
  }

  bool alreadyInList(String userId) {
    for (int i = 0; i < selectedRecipients.length; i++) {
      if (selectedRecipients[i].userId.toString() == userId.toString()) {
        return true;
      }
    }
    return false; // Return the original email if the format is invalid
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: Duration(seconds: 1), // Duration for the animation
        curve: Curves.fastOutSlowIn, // Animation curve (e.g., ease-in-out)
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? (MediaQuery.of(context).size.height)
                : (MediaQuery.of(context).size.width),
            child: getAnimatedWidget(),
          ),
        ));
  }

  submitForm() async {
    var recipients = [];

    for (int i = 0; i < selectedRecipients.length; i++) {
      var _recipient = {};
      _recipient["userId"] = selectedRecipients[i].userId;
      _recipient["email"] =
          selectedRecipients[i].profileDetails.personalDetails.primaryEmail;
      recipients.add(_recipient);
    }
    var formResponse = await profileService.shareCourse(
        widget.formId,
        recipients,
        widget.courseId,
        widget.courseName,
        widget.coursePosterImageUrl,
        widget.courseProvider,
        widget.primaryCategory);
    if (formResponse == "success") {
      widget.callback(formResponse);
      Navigator.of(context).pop();
    } else {
      setState(() {
        showDialogWidget = true;
        dialogType = "error";
        dialogMessage =
            AppLocalizations.of(context).mContentSharePageSharingError;
      });
      Future.delayed(Duration(seconds: 3), () {
        if (mounted)
          setState(() {
            showDialogWidget = false;
          });
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _showDialog() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: (dialogType == "success")
              ? AppColors.positiveLight
              : AppColors.negativeLight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              child: TitleRegularGrey60(
                dialogMessage,
                fontSize: 14,
                color: AppColors.appBarBackground,
                maxLines: 3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
            child: Icon(
              (dialogType == "success") ? Icons.check : Icons.info_outline,
              color: AppColors.appBarBackground,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
