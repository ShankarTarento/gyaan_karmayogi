import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/sign_up/field_request_page.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectFromBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final String fieldName;
  final bool isInReview;
  final String selected;
  final String degreeType;
  final Function(String value) onSelected;
  final String Function(String) validator;
  final VoidCallback callBack;
  const SelectFromBottomSheet(
      {Key key,
      this.controller,
      this.fieldName,
      this.isInReview = false,
      this.selected,
      this.onSelected,
      this.degreeType,
      this.validator,
      this.callBack})
      : super(key: key);

  @override
  State<SelectFromBottomSheet> createState() => _SelectFromBottomSheetState();
}

class _SelectFromBottomSheetState extends State<SelectFromBottomSheet> {
  TextEditingController _searchController = TextEditingController();
  ValueNotifier<List<dynamic>> _filteredItems = ValueNotifier([]);
  ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tooltip(
          message: widget.isInReview ? 'This field is under review' : '',
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            padding: EdgeInsets.only(top: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.fieldName ==
                    AppLocalizations.of(context).mStaticDegres
                ? InkWell(
                    onTap: _isLoading.value
                        ? null
                        : () async {
                            _searchController?.clear();
                            _isLoading.value = true;
                            await _showListOfOptions(context, widget.fieldName);
                          },
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)),
                          border: Border.all(color: AppColors.grey16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, bottom: 16),
                          child: Text(
                            widget.selected,
                            style: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontSize: 14,
                            ),
                          ),
                        )),
                  )
                : TextFormField(
                    readOnly: true,
                    onTap: widget.isInReview || _isLoading.value
                        ? null
                        : () async {
                            _searchController?.clear();
                            _isLoading.value = true;
                            await _showListOfOptions(context, widget.fieldName);
                          },
                    textInputAction: TextInputAction.next,
                    controller: widget.controller,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: widget.validator,
                    style: GoogleFonts.lato(fontSize: 14.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
                      border: const OutlineInputBorder(),
                      enabled: !widget.isInReview,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey16)),
                      hintText: AppLocalizations.of(context).mStaticSelectHere,
                      hintStyle: GoogleFonts.lato(
                          color: AppColors.grey40,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey16)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: AppColors.primaryThree, width: 1.0),
                      ),
                    ),
                  ),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (BuildContext context, bool isLoading, Widget child) {
              return isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator()),
                    )
                  : SizedBox();
            })
      ],
    );
  }

  Widget _options(String listType, dynamic item) {
    Color _color;
    switch (listType) {
      case EnglishLang.group:
        _color = widget.controller.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.nationality:
        _color = widget.controller.text == item.country
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.location:
        _color = widget.controller.text == item.country
            ? AppColors.lightSelected
            : Colors.white;
        break;
      default:
        _color = widget.controller.text == item
            ? AppColors.lightSelected
            : Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          // height: 52,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 4),
            child: Text(
              listType == EnglishLang.group
                  ? item.name
                  : (listType == EnglishLang.nationality ||
                          listType == EnglishLang.location)
                      ? item.country
                      : item,
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.25,
                  height: 1.5),
            ),
          )),
    );
  }

  void _setListItem(String listType, dynamic item) {
    switch (listType) {
      case EnglishLang.group:
        widget.controller.text = item.name;
        break;
      case EnglishLang.nationality:
        widget.controller.text = item.country;
        break;
      case EnglishLang.location:
        widget.controller.text = item.country;
        break;
      case EnglishLang.degres:
        widget.onSelected(item);
        break;
      default:
        widget.controller.text = item;
        break;
    }
    if (widget.callBack != null) {
      widget.callBack();
    }
  }

  void _filterItems(List items, String value,
      {bool isGroup = false, bool isNationalities = false}) {
    _filteredItems.value = items
        .where((item) => (isGroup
                ? item.name
                : isNationalities
                    ? item.country
                    : item)
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();
  }

  Future<bool> _showListOfOptions(contextMain, String listType) async {
    List<dynamic> items = [];
    switch (listType) {
      case EnglishLang.group:
        items = await EditProfileMandatoryHelper().getGroups(context);
        break;
      case EnglishLang.designation:
        items = await EditProfileMandatoryHelper().getDesignations(context);
        break;
      case EnglishLang.nationality:
        items = Provider.of<ProfileRepository>(context, listen: false)
            .nationalities;
        break;
      case EnglishLang.location:
        items = Provider.of<ProfileRepository>(context, listen: false)
            .nationalities;
        break;
      case EnglishLang.organisationName:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getOrganisations();
        items = items.map((item) => item.toString()).toList();
        items.sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
        break;
      case EnglishLang.industry:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getIndustries();
        break;
      case EnglishLang.payBand:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getGradePay();
        items.sort(((a, b) => int.parse(a).compareTo(int.parse(b))));
        break;
      case EnglishLang.service:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getServices();
        break;
      case EnglishLang.cadre:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getCadre();
        break;
      case EnglishLang.degres:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getDegrees(widget.degreeType);
        break;
    }
    _filterItems(items, '',
        isGroup: listType == EnglishLang.group,
        isNationalities: listType == EnglishLang.nationality ||
            listType == EnglishLang.location);
    _isLoading.value = false;
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
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.white,
                      child: Material(
                          color: Colors.white,
                          child: Column(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                height: 6,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  color: AppColors.grey16,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    height: 48,
                                    child: TextFormField(
                                        onChanged: (value) {
                                          _filterItems(items, value,
                                              isGroup:
                                                  listType == EnglishLang.group,
                                              isNationalities: listType ==
                                                      EnglishLang.nationality ||
                                                  listType ==
                                                      EnglishLang.nationality);
                                        },
                                        controller: _searchController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        style: GoogleFonts.lato(fontSize: 14.0),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              16.0, 14.0, 0.0, 10.0),
                                          hintText: 'Search',
                                          hintStyle: GoogleFonts.lato(
                                              color: AppColors.greys60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryThree,
                                                width: 1.0),
                                          ),
                                          counterStyle: TextStyle(
                                            height: double.minPositive,
                                          ),
                                          counterText: '',
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(false);
                                            _searchController.text = '';
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: AppColors.greys60,
                                            size: 24,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              height: 8,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.grey08,
                            ),
                            ValueListenableBuilder(
                                valueListenable: _filteredItems,
                                builder: (BuildContext context,
                                    List<dynamic> filteredItems, Widget child) {
                                  return Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.only(top: 10),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              (filteredItems.length > 0
                                                  ? 0.685
                                                  : 0.6),
                                      child: filteredItems.length > 0
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: filteredItems.length,
                                              itemBuilder: (BuildContext
                                                          context,
                                                      index) =>
                                                  InkWell(
                                                      onTap: () {
                                                        _setListItem(
                                                            listType,
                                                            filteredItems[
                                                                index]);
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: _options(
                                                          listType,
                                                          filteredItems[
                                                              index])))
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(32.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                      EnglishLang
                                                          .noResultFromSearch,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.lato(
                                                          color:
                                                              AppColors.greys60,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          height: 1.5,
                                                          letterSpacing: 0.25,
                                                          fontSize: 16)),
                                                  Visibility(
                                                    visible: listType ==
                                                            EnglishLang
                                                                .position ||
                                                        listType ==
                                                            EnglishLang
                                                                .designation,
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Consumer<
                                                                          ProfileRepository>(builder: (BuildContext
                                                                              context,
                                                                          ProfileRepository
                                                                              profileRepository,
                                                                          Widget
                                                                              child) {
                                                                        dynamic
                                                                            personalData =
                                                                            profileRepository.profileDetails.personalDetails;
                                                                        return FieldRequestPage(
                                                                          fullName: profileRepository
                                                                              .profileDetails
                                                                              .firstName,
                                                                          mobile:
                                                                              personalData['mobile'].toString(),
                                                                          email: profileRepository
                                                                              .profileDetails
                                                                              .primaryEmail,
                                                                          phoneVerified:
                                                                              personalData['phoneVerified'],
                                                                          isEmailVerified:
                                                                              false,
                                                                          fieldValue:
                                                                              _searchController.text,
                                                                          parentAction:
                                                                              () {},
                                                                          fieldName:
                                                                              EnglishLang.position,
                                                                        );
                                                                      })));
                                                        },
                                                        child: Text(EnglishLang
                                                            .requestForHelp)),
                                                  )
                                                ],
                                              ),
                                            ));
                                }),
                          ])),
                    )),
              );
            }));
  }
}
