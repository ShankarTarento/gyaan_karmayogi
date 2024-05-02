import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../models/_models/blended_program_unenroll_response_model.dart';
import '../../../../services/index.dart';
import '../../../../util/helper.dart';

class CourseOverviewBlendedProgramWidget extends StatefulWidget {
  final course;
  final ValueChanged<Batch> batchSelectionParentAction;
  final bool enbleDropdown;
  final EnrolmentStatus enrollmentStatus;
  final Map<String, dynamic> enrolledBatch;
  final String wfId, selectedBatchId;
  final ValueChanged<String> enrollStatusParentAction;
  final bool enableRequestWithdrawBtn;
  const CourseOverviewBlendedProgramWidget(
      {Key key,
      this.course,
      this.batchSelectionParentAction,
      this.enbleDropdown,
      this.enrollmentStatus,
      this.enrolledBatch,
      this.wfId,
      this.enrollStatusParentAction,
      this.enableRequestWithdrawBtn,
      this.selectedBatchId})
      : super(key: key);

  @override
  State<CourseOverviewBlendedProgramWidget> createState() =>
      _CourseOverviewBlendedProgramWidgetState();
}

class _CourseOverviewBlendedProgramWidgetState
    extends State<CourseOverviewBlendedProgramWidget> {
  final LearnService learnService = LearnService();
  var _selectedBatch;
  String _dropdownValue;
  EnrolmentStatus enrolmentState = EnrolmentStatus.withdrawn;
  List<String> dropdownItems = [];
  List batches = [];
  String batchName = '';
  String batchStartDate = '';
  String batchEndDate = '';
  String enrollmentEndDate = '';
  int status = -1;
  int dropdownIndex = 0;
  bool dropdownValueChanged = false;
  bool enableDropdown;
  bool get showLocation => _selectedBatch != null
      ? _selectedBatch.batchAttributes != null
          ? _selectedBatch.batchAttributes.batchLocationDetails != null
          : false
      : false;
  // final DateFormat formatter = DateFormat(IntentType.dateFormat);

  @override
  void initState() {
    super.initState();
    enableDropdown = widget.enbleDropdown;
    getSelectedBatch();
    addBatchesToDropdown();
  }

  void getSelectedBatch() {
    var batches = widget.course['batches'];
    for (int i = 0; i < batches.length; i++) {
      if (isValidBatch(DateTime.parse(batches[i].enrollmentEndDate))) {
        _dropdownValue =
            '${batches[i].name} - ${Helper.getDateTimeInFormat(batches[i].startDate)} - ${Helper.getDateTimeInFormat(batches[i].endDate)}';
        break;
      }
    }
  }

  void addBatchesToDropdown() {
    dropdownItems.clear();
    if (widget.course['batches'] != null) {
      batches = widget.course['batches'];
      if (widget.enrollmentStatus == EnrolmentStatus.enrolled ||
          widget.enrollmentStatus == EnrolmentStatus.waiting) {
        batches.removeWhere(
            (batch) => widget.enrolledBatch['applicationId'] != batch.batchId);
      }
      // _setSelectedBatch(batches.first);
      batches.forEach((batch) {
        dropdownItems.add(
            '${batch.name} - ${Helper.getDateTimeInFormat(batch.startDate)} - ${Helper.getDateTimeInFormat(batch.endDate)}');
        if ((widget.enrollmentStatus == EnrolmentStatus.enrolled ||
                widget.enrollmentStatus == EnrolmentStatus.waiting) &&
            widget.enrolledBatch['applicationId'] == batch.batchId) {
          _dropdownValue =
              '${batch.name} - ${Helper.getDateTimeInFormat(batch.startDate)} - ${Helper.getDateTimeInFormat(batch.endDate)}';
          _setSelectedBatch(batch);
        } else if ((widget.enrollmentStatus == EnrolmentStatus.rejected ||
                widget.enrollmentStatus == EnrolmentStatus.removed) &&
            widget.enrolledBatch['applicationId'] == batch.batchId) {
          _dropdownValue =
              '${batch.name} - ${Helper.getDateTimeInFormat(batch.startDate)} - ${Helper.getDateTimeInFormat(batch.endDate)}';
          _setSelectedBatch(batch);
        } else if (widget.enrolledBatch == null &&
            widget.selectedBatchId == null) {
          _dropdownValue =
              '${batch.name} - ${Helper.getDateTimeInFormat(batch.startDate)} - ${Helper.getDateTimeInFormat(batch.endDate)}';
          _setSelectedBatch(batch);
        } else if (widget.selectedBatchId != null &&
            isValidBatch(DateTime.parse(batch.enrollmentEndDate))) {
          if (widget.selectedBatchId == batch.batchId) {
            _dropdownValue =
                '${batch.name} - ${Helper.getDateTimeInFormat(batch.startDate)} - ${Helper.getDateTimeInFormat(batch.endDate)}';
            _setSelectedBatch(batch);
          }
        }
      });
    }
  }

  Future<void> unenrollBlendedCourse() async {
    String courseId = widget.course['identifier'];
    String batchId = _selectedBatch.batchId;
    BlendedProgramUnenrollResponseModel enrolList =
        await learnService.requestUnenroll(
            batchId: batchId,
            courseId: courseId,
            wfId: widget.wfId,
            state: widget.enrolledBatch['currentStatus'],
            action: WFBlendedProgramStatus.WITHDRAW.name);
    setState(() {
      widget.enrollStatusParentAction('Confirm');
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (!dropdownValueChanged || (widget.enrollmentStatus != enrolmentState)) {
    //   enrolmentState = widget.enrollmentStatus;
    //   addBatchesToDropdown();
    // }
    enrolmentState = widget.enrollmentStatus;
    dropdownIndex = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
          child: Text(
            AppLocalizations.of(context).mStaticRequestToEnrollProgram,
            style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.12,
                height: 1.5,
                color: AppColors.greys87),
          ),
        ),
        dropdownItems != null
            ? dropdownItems.length > 0
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: AppColors.appBarBackground),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.black26,
                              )),
                          child: DropdownButton<String>(
                            value: _dropdownValue ?? dropdownItems.first,
                            icon: Icon(Icons.arrow_drop_down_outlined),
                            iconSize: 26,
                            elevation: 16,
                            isExpanded: true,
                            style: TextStyle(color: AppColors.greys87),
                            underline: Container(
                              // height: 2,
                              color: AppColors.lightGrey,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            selectedItemBuilder: (BuildContext context) {
                              int index = 0;
                              return dropdownItems.map<Widget>((String item) {
                                var enrollmentEndDate = DateTime.parse(widget
                                    .course['batches'][index++]
                                    .enrollmentEndDate);
                                bool isItValidBatch =
                                    isValidBatch(enrollmentEndDate);
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 15.0, 0, 15.0),
                                    child: Text(
                                      item,
                                      style: GoogleFonts.lato(
                                        color: _dropdownValue == item ||
                                                isItValidBatch
                                            ? AppColors.greys87
                                            : AppColors.grey40,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ));
                              }).toList();
                            },
                            onChanged: (enableDropdown &&
                                    _dropdownValue != null)
                                ? (String newValue) {
                                    List values = newValue.split(' - ');
                                    setState(() {
                                      _dropdownValue = newValue;
                                      dropdownValueChanged = true;
                                      int index = batches.indexWhere((batch) {
                                        return (batch.name == values[0] &&
                                            Helper.getDateTimeInFormat(
                                                    batch.startDate) ==
                                                values[1] &&
                                            Helper.getDateTimeInFormat(
                                                    batch.endDate) ==
                                                values[2]);
                                      });
                                      _setSelectedBatch(batches[index]);
                                    });
                                  }
                                : null,
                            items: dropdownItems
                                .map<DropdownMenuItem<String>>((String value) {
                              var enrollmentEndDate = DateTime.parse(widget
                                  .course['batches'][dropdownIndex++]
                                  .enrollmentEndDate);
                              var dateDiff = isValidBatch(enrollmentEndDate);

                              return DropdownMenuItem<String>(
                                enabled: !dateDiff ? false : true,
                                value: value,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        value,
                                        style: GoogleFonts.lato(
                                          color: !dateDiff
                                              ? AppColors.grey40
                                              : AppColors.greys87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Visibility(
                          visible: enrolmentState != EnrolmentStatus.enrolled &&
                              enrolmentState != EnrolmentStatus.waiting &&
                              enrolmentState != EnrolmentStatus.removed &&
                              enrolmentState != EnrolmentStatus.rejected,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                      .mStaticEnrolLateDateTxt,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.12,
                                      height: 1.5,
                                      color: AppColors.greys87),
                                ),
                                Text(
                                  enrollmentEndDate != ''
                                      ? Helper.getDateTimeInFormat(
                                          enrollmentEndDate)
                                      : '',
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.12,
                                      height: 1.5,
                                      color: AppColors.greys87),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: enrolmentState == EnrolmentStatus.removed ||
                              enrolmentState == EnrolmentStatus.rejected,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/img/icon_error.svg',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Text(
                                    '${AppLocalizations.of(context).mCourseBatchEnrollRemoveMsg} ${enrolmentState.name}.',
                                    style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.12,
                                        height: 1.5,
                                        color: AppColors.greys87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: enrolmentState == EnrolmentStatus.waiting,
                            child: _withdrawBtn(context)),
                        SizedBox(
                          height: 8,
                        ),
                        Visibility(
                          visible: showLocation,
                          child: Text(
                            AppLocalizations.of(context)
                                .mStaticBatchLocationTitle,
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.12,
                                height: 1.5,
                                color: AppColors.greys87),
                          ),
                        ),
                        Visibility(
                          visible: showLocation,
                          child: SizedBox(
                            height: 8,
                          ),
                        ),
                        Visibility(
                          visible: showLocation,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  'assets/img/location.svg',
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  showLocation
                                      ? _selectedBatch
                                          .batchAttributes.batchLocationDetails
                                      : ''.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.12,
                                      height: 1.5,
                                      color: AppColors.greys87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Visibility(
                          visible: enrolmentState == EnrolmentStatus.enrolled,
                          child: Flexible(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(
                                  'assets/img/approved.svg',
                                  width: 22,
                                  height: 22,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .mStaticEnrolmentApprovedDesc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.12,
                                      height: 1.5,
                                      color: AppColors.greys60),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: enrolmentState == EnrolmentStatus.waiting,
                          child: Flexible(
                            child: Text(
                              AppLocalizations.of(context)
                                  .mStaticEnrolmentRequestInReviewDesc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.12,
                                  height: 1.5,
                                  color: AppColors.greys60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center()
            : Center()
      ],
    );
  }

  Widget _withdrawBtn(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.black26,
          )),
      child: TextButton(
        onPressed: !widget.enableRequestWithdrawBtn
            ? null
            : () async => await _showBottomSheet(context),
        child: Text(
          AppLocalizations.of(context).mStaticEnrolmentWithdrawDesc,
          style: GoogleFonts.lato(
              color: widget.enableRequestWithdrawBtn
                  ? AppColors.primaryThree
                  : AppColors.lightSelected,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

  Future<Widget> _showBottomSheet(BuildContext context) async {
    return await showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30, 16, 16),
                  child: Text(
                    AppLocalizations.of(context)
                        .mStaticEnrolmentWithdrawConfirm,
                    style: GoogleFonts.lato(
                        color: AppColors.primaryTwo,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.12),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22),
                  child: Text(
                    AppLocalizations.of(context)
                        .mStaticEnrolmentWithdrawConfirmDesc,
                    style: GoogleFonts.lato(
                        color: AppColors.primaryTwo,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: BorderSide(
                                        color: AppColors.primaryThree,
                                        width: 1.5))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.appBarBackground),
                          ),
                          // padding: EdgeInsets.all(15.0),
                          child: Text(
                            AppLocalizations.of(context).mStaticCancel,
                            style: GoogleFonts.lato(
                              color: AppColors.primaryThree,
                              fontSize: 14.0,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await unenrollBlendedCourse();
                            setState(() {
                              Navigator.of(context).pop();
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.primaryThree),
                          ),
                          // padding: EdgeInsets.all(15.0),
                          child: Text(
                            AppLocalizations.of(context).mStaticWithdraw,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 14.0,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
                SizedBox(
                  height: 23,
                ),
              ],
            ));
  }

  void _setSelectedBatch(batch) {
    _selectedBatch = batch;
    batchName = batch.name;
    batchStartDate = batch.startDate;
    enrollmentEndDate = batch.enrollmentEndDate;
    batchEndDate = batch.endDate;
    status = batch.status;
    widget.batchSelectionParentAction(batch);
  }

  bool isValidBatch(var enrollmentEndDate) {
    var dateDiff = enrollmentEndDate.difference(DateTime.now()).inDays;
    return dateDiff >= 0;
  }
}
