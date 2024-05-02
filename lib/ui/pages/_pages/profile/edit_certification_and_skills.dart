import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCertificationAndSkillsPage extends StatefulWidget {
  final profileDetails;
  final scaffoldKey;
  static final GlobalKey<_EditCertificationAndSkillsPageState>
      certificationSkillsDetailsGlobalKey = GlobalKey();
  EditCertificationAndSkillsPage({
    Key key,
    this.profileDetails,
    this.scaffoldKey,
  }) : super(key: certificationSkillsDetailsGlobalKey);

  @override
  _EditCertificationAndSkillsPageState createState() =>
      _EditCertificationAndSkillsPageState();
}

class _EditCertificationAndSkillsPageState
    extends State<EditCertificationAndSkillsPage> {
  final ProfileService profileService = ProfileService();

  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _professionalInterests = [];
  List<String> _hobbies = [];
  Map _profileData;
  // var _profileDetails;

  final TextEditingController _skillCoursesController = TextEditingController();
  final TextEditingController _certificationDetailsController =
      TextEditingController();
  final TextEditingController _professionalInterestController =
      TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();

  final FocusNode _skillCoursesFocus = FocusNode();
  final FocusNode _certificationDetailsFocus = FocusNode();
  final FocusNode _professionalDetailFocus = FocusNode();
  final FocusNode _hobbiesFocus = FocusNode();

  // final GlobalKey<TagsState> _tagStateKey1 = GlobalKey<TagsState>();
  // final GlobalKey<TagsState> _tagStateKey2 = GlobalKey<TagsState>();

  @override
  void initState() {
    super.initState();
    _populateFields(widget.profileDetails);
  }

  _populateFields(profileDetails) {
    String professionalInterests =
        profileDetails[0].interests['professional'] != null
            ? profileDetails[0].interests['professional'].join(',')
            : '';
    String hobbies = profileDetails[0].interests['hobbies'] != null
        ? profileDetails[0].interests['hobbies'].join(',')
        : '';
    setState(() {
      _skillCoursesController.text =
          profileDetails[0].skills['additionalSkills'];
      _certificationDetailsController.text =
          profileDetails[0].skills['certificateDetails'];
      if (professionalInterests != '' && professionalInterests != null) {
        _professionalInterests = professionalInterests.split(',');
      }
      if (hobbies != '' && hobbies != null) {
        _hobbies = hobbies.split(',');
      }
    });
  }

  Future<void> saveProfile() async {
    _profileData = {
      'academics': widget.profileDetails[0].education,
      "interests": {
        "professional": _professionalInterests,
        "hobbies": _hobbies
      },
      "skills": {
        "additionalSkills": _skillCoursesController.text,
        "certificateDetails": _certificationDetailsController.text
      },
      "competencies": widget.profileDetails[0].competencies
    };

    var response;
    try {
      response = await profileService.updateProfileDetails(_profileData);
      FocusManager.instance.primaryFocus.unfocus();
      var snackBar;
      if (response['params']['errmsg'] == null ||
          response['params']['errmsg'] == '') {
        snackBar = SnackBar(
          content: Container(
              child: Text(
            AppLocalizations.of(context)
                .mStaticCertificationAndSkillsUpdatedText,
          )),
          backgroundColor: AppColors.positiveLight,
        );
      } else {
        snackBar = SnackBar(
          content: Container(child: Text(response['params']['errmsg'])),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
      ScaffoldMessenger.of(widget.scaffoldKey.currentContext)
          .showSnackBar(snackBar);
    } catch (err) {
      return err;
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _addProfessionalInterests() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _professionalInterests.add(_professionalInterestController.text);
          _professionalInterests.toSet().toList();
        });
        _professionalInterestController.clear();
      },
      child: Text(
        AppLocalizations.of(context).mStaticAdd,
        style: GoogleFonts.lato(
          color: AppColors.primaryThree,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _addHobbies() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hobbies.add(_hobbiesController.text);
          _hobbies.toSet().toList();
        });
        _hobbiesController.clear();
      },
      child: Text(
        AppLocalizations.of(context).mStaticAdd,
        style: GoogleFonts.lato(
          color: AppColors.primaryThree,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _certificationDetailsController.dispose();
    _hobbiesController.dispose();
    _professionalInterestController.dispose();
    _skillCoursesController.dispose();
    _certificationDetailsFocus.dispose();
    _hobbiesFocus.dispose();
    _professionalDetailFocus.dispose();
    _skillCoursesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: _getProfileDetails(),
      // builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      future: Future.delayed(Duration(milliseconds: 1500)),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (true) {
          return SingleChildScrollView(
              // child: SizedBox()
              child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 5),
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    AppLocalizations.of(context).mStaticCertification,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.25,
                        height: 1.5),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                margin: EdgeInsets.only(top: 5.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .mStaticAdditionalSkillAcquired,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            // Icon(Icons.check_circle_outline)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: _skillCoursesFocus,
                            onFieldSubmitted: (term) {
                              _fieldFocusChange(context, _skillCoursesFocus,
                                  _certificationDetailsFocus);
                            },
                            controller: _skillCoursesController,
                            style: GoogleFonts.lato(fontSize: 14.0),
                            minLines: 6,
                            maxLines: 10,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                              hintText:
                                  AppLocalizations.of(context).mCommonTypeHere,
                              hintStyle: GoogleFonts.lato(
                                  color: AppColors.grey40,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryThree, width: 1.0),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .mStaticProvideCertificationDetails,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            // Icon(Icons.check_circle_outline)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: _certificationDetailsFocus,
                            controller: _certificationDetailsController,
                            style: GoogleFonts.lato(fontSize: 14.0),
                            minLines: 6,
                            maxLines: 10,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                              hintText:
                                  AppLocalizations.of(context).mCommonTypeHere,
                              hintStyle: GoogleFonts.lato(
                                  color: AppColors.grey40,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryThree, width: 1.0),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 5),
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    AppLocalizations.of(context).mStaticSkills,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.25,
                        height: 1.5),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                margin: EdgeInsets.only(top: 5.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .mStaticProfessionalInterests,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  height: 1.5),
                            ),
                            // Icon(Icons.check_circle_outline)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.lightBackground,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: 40.0,
                          child: Focus(
                            child: TextFormField(
                              textInputAction: TextInputAction.go,
                              textCapitalization: TextCapitalization.sentences,
                              focusNode: _professionalDetailFocus,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context,
                                    _certificationDetailsFocus,
                                    _professionalDetailFocus);
                              },
                              controller: _professionalInterestController,
                              style: GoogleFonts.lato(fontSize: 14.0),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey16)),
                                hintText: AppLocalizations.of(context)
                                    .mCommonTypeHere,
                                suffix: _addProfessionalInterests(),
                                hintStyle: GoogleFonts.lato(
                                    color: AppColors.grey40,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryThree,
                                      width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          children: [
                            for (var i in _professionalInterests)
                              Container(
                                margin: const EdgeInsets.only(right: 15.0),
                                child: InputChip(
                                  padding: EdgeInsets.all(10.0),
                                  backgroundColor: AppColors.lightOrange,
                                  label: Text(
                                    i,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                  deleteIcon: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Positioned(
                                        top: -3.5,
                                        left: -4.5,
                                        right: 0,
                                        child: Icon(Icons.cancel,
                                            size: 25.0,
                                            color: AppColors.grey40),
                                      ),
                                    ],
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _professionalInterests.removeAt(
                                          _professionalInterests.indexOf(i));
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).mStaticHobbies,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            // Icon(Icons.check_circle_outline)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.lightBackground,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: 40.0,
                          child: Focus(
                            child: TextFormField(
                              textInputAction: TextInputAction.go,
                              textCapitalization: TextCapitalization.sentences,
                              focusNode: _hobbiesFocus,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(context,
                                    _professionalDetailFocus, _hobbiesFocus);
                              },
                              controller: _hobbiesController,
                              style: GoogleFonts.lato(fontSize: 14.0),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey16)),
                                hintText: AppLocalizations.of(context)
                                    .mCommonTypeHere,
                                suffix: _addHobbies(),
                                hintStyle: GoogleFonts.lato(
                                    color: AppColors.grey40,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryThree,
                                      width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          children: [
                            for (var i in _hobbies)
                              Container(
                                margin: const EdgeInsets.only(right: 15.0),
                                child: InputChip(
                                  padding: EdgeInsets.all(10.0),
                                  backgroundColor: AppColors.lightOrange,
                                  label: Text(
                                    i,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                  deleteIcon: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Positioned(
                                        top: -3.5,
                                        left: -4.5,
                                        right: 0,
                                        child: Icon(Icons.cancel,
                                            size: 25.0,
                                            color: AppColors.grey40),
                                      ),
                                    ],
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _hobbies.removeAt(_hobbies.indexOf(i));
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 150,
              )
            ],
          ));
        }
        // else {
        //   return PageLoader(
        //     bottom: 50,
        //   );
        // }
      },
    );
  }
}
