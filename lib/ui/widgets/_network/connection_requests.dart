import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:provider/provider.dart';
import '../title_bold_widget.dart';
import '../title_regular_grey60.dart';
import './../../../constants/index.dart';
import './../../../respositories/index.dart';
import './../../../services/index.dart';
import './../../../ui/pages/index.dart';
import './../../../util/faderoute.dart';
import './../../../util/helper.dart';
import './../../../localization/_langs/english_lang.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

//ignore: must_be_immutable
class ConnectionRequests extends StatefulWidget {
  final connectionRequests;
  bool isShow;
  bool isFromHome;
  final parentAction;

  ConnectionRequests(this.connectionRequests, this.isShow,
      {this.isFromHome = false, this.parentAction});
  @override
  _ConnectionRequestsState createState() => _ConnectionRequestsState();
}

class _ConnectionRequestsState extends State<ConnectionRequests> {
  dynamic _response;
  List _tempData = [];
  List _filteredData = [];
  String _dropdownValue = EnglishLang.lastAdded;
  bool _pageInitialized = false;
  List<LocalizationText> dropdownItems = [];
  dynamic _data;

  @override
  void initState() {
    super.initState();
    setState(() {
      _data = widget.connectionRequests;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dropdownItems =
        LocalizationText.getNetworkConnectionRequestFilter(context: context);
  }

  /// Get connection request response
  Future<List> _getUserNames(context) async {
    try {
      if (!_pageInitialized) {
        List ids = [];
        if (widget.connectionRequests != null) {
          for (int i = 0; i < _data.data.length; i++) {
            ids.add(_data.data[i]['id']);
          }
        }
        if (ids.length > 0) {
          _tempData =
              await Provider.of<NetworkRespository>(context, listen: false)
                  .getUsersNames(ids);
          _filteredData = _tempData;
        }
        setState(() {
          _pageInitialized = true;
        });
      }
      if (_dropdownValue == EnglishLang.sortByName) {
        setState(() {
          _filteredData.sort((a, b) => (a['profileDetails']['personalDetails']
                      ['firstname'] +
                  (a['profileDetails']['personalDetails']['surname'] != null
                      ? a['profileDetails']['personalDetails']['surname']
                      : ''))
              .toLowerCase()
              .compareTo((b['profileDetails']['personalDetails']['firstname'] +
                      (b['profileDetails']['personalDetails']['surname'] != null
                          ? b['profileDetails']['personalDetails']['surname']
                          : ''))
                  .toLowerCase()));
        });
      } else if (_dropdownValue == EnglishLang.lastAdded) {
        setState(() {
          _filteredData = _tempData.toList();
        });
      }
      // print('_filteredData: ' + _filteredData.toString());
      return _filteredData;
    } catch (err) {
      return err;
    }
  }

  /// Post accept / reject
  postRequestStatus(context, status, connectionId, connectionDepartment) async {
    try {
      _response = await NetworkService.postAcceptReject(
          status, connectionId, connectionDepartment);

      if (_response['result']['message'] == 'Successful') {
        if (status == 'Approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .mNetworkConnectionRequestAccepted),
              backgroundColor: AppColors.positiveLight,
            ),
          );
        }

        if (status == 'Rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .mStaticConnectionRequestRejected),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() {
          _tempData.removeWhere((data) => data['id'] == connectionId);
          widget.parentAction();
        });
        try {
          final dataNode =
              await Provider.of<NetworkRespository>(context, listen: false)
                  .getCrList();

          setState(() {
            _data = dataNode;
          });
        } catch (err) {
          return err;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).mStaticErrorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (err) {
      return err;
    }

    return _response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUserNames(context),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.length == 0) {
              return !widget.isFromHome
                  ? Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: SvgPicture.asset(
                                    'assets/img/connections.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                AppLocalizations.of(context).mStaticNoRequests,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.5,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                AppLocalizations.of(context)
                                    .mStaticNoRequestText,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 1.5,
                                  letterSpacing: 0.25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)
                                .mNetworkNoConnectionRequests,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
            } else {
              return Container(
                // margin: EdgeInsets.only(bottom: 65),

                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        Column(
                          children: [
                            if (widget.isShow)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 18.0, 15.0, 15.0),
                                    child: SizedBox(
                                      width: 150,
                                      child: Text(
                                        _filteredData.length.toString() +
                                            ' ' +
                                            AppLocalizations.of(context)
                                                .mStaticConnectionRequests,
                                        style: GoogleFonts.lato(
                                          color: AppColors.greys60,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 130,
                                    margin: EdgeInsets.only(right: 16, top: 8),
                                    child: DropdownButton<String>(
                                      value: _dropdownValue != null
                                          ? _dropdownValue
                                          : null,
                                      icon:
                                          Icon(Icons.arrow_drop_down_outlined),
                                      iconSize: 26,
                                      elevation: 16,
                                      hint: Container(
                                          width: 80,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: 16),
                                          child: Text(
                                            '${AppLocalizations.of(context).mCommonSortBy} ',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      style:
                                          TextStyle(color: AppColors.greys87),
                                      underline: Container(
                                        // height: 2,
                                        color: AppColors.lightGrey,
                                      ),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return dropdownItems.map<Widget>(
                                            (LocalizationText item) {
                                          return Row(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 15.0, 0, 15.0),
                                                  child: SizedBox(
                                                    width: 80,
                                                    child: Text(
                                                      item.displayText,
                                                      style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.greys87,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                            ],
                                          );
                                        }).toList();
                                      },
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _dropdownValue = newValue;
                                          // _sortMembers(_dropdownValue);
                                        });
                                      },
                                      items: dropdownItems
                                          .map<DropdownMenuItem<String>>(
                                              (LocalizationText value) {
                                        return DropdownMenuItem<String>(
                                          value: value.value,
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              value.displayText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        AnimationLimiter(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i <
                                      (widget.isFromHome
                                          ? (_filteredData.length > 1 ? 2 : 1)
                                          : _filteredData.length);
                                  i++)
                                AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          FadeRoute(
                                            page: ChangeNotifierProvider<
                                                NetworkRespository>(
                                              create: (context) =>
                                                  NetworkRespository(),
                                              child: NetworkProfile(
                                                  _filteredData[i]['id']),
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          color: Colors.white,
                                          margin: EdgeInsets.only(bottom: 5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: _filteredData
                                                                .length >
                                                            1
                                                        ? BorderSide(
                                                            color: AppColors
                                                                .lightBackground,
                                                            width: 2.0)
                                                        : BorderSide.none,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(15.0),
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                                  .networkBg[
                                                              Random().nextInt(
                                                                  AppColors
                                                                      .networkBg
                                                                      .length)],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            _filteredData[i][
                                                                        'profileDetails'] !=
                                                                    null
                                                                ? Helper.getInitials(_filteredData[i]['profileDetails']
                                                                            ['personalDetails']
                                                                        [
                                                                        'firstname'] +
                                                                    ' ' +
                                                                    (_filteredData[i]['profileDetails']['personalDetails']['surname'] !=
                                                                            null
                                                                        ? _filteredData[i]['profileDetails']['personalDetails']
                                                                            ['surname']
                                                                        : ''))
                                                                : 'UN',
                                                            style: GoogleFonts
                                                                .lato(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Wrap(
                                                            children: [
                                                              TitleBoldWidget(
                                                                _filteredData[i]
                                                                            [
                                                                            'profileDetails'] !=
                                                                        null
                                                                    ? _filteredData[i]['profileDetails']['personalDetails']
                                                                            [
                                                                            'firstname'] +
                                                                        ' ' +
                                                                        (_filteredData[i]['profileDetails']['personalDetails']['surname'] !=
                                                                                null
                                                                            ? _filteredData[i]['profileDetails']['personalDetails']['surname']
                                                                            : '')
                                                                    : 'UN',
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.25,
                                                              ),
                                                              (_filteredData[i][
                                                                              'profileDetails']
                                                                          [
                                                                          'verifiedKarmayogi'] ==
                                                                      true)
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        size:
                                                                            20,
                                                                        color: AppColors
                                                                            .positiveLight,
                                                                      ),
                                                                    )
                                                                  : Center()
                                                            ],
                                                          ),
                                                          TitleRegularGrey60(
                                                            _filteredData[i][
                                                                        'rootOrgName'] !=
                                                                    null
                                                                ? _filteredData[
                                                                        i][
                                                                    'rootOrgName']
                                                                : '',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              postRequestStatus(
                                                                  context,
                                                                  EnglishLang
                                                                      .rejected,
                                                                  _filteredData[
                                                                      i]['id'],
                                                                  _filteredData[
                                                                          i][
                                                                      'rootOrgName']);
                                                            },
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/img/decline_icon.svg',
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  4.0,
                                                                  15.0,
                                                                  20.0,
                                                                  15.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              postRequestStatus(
                                                                  context,
                                                                  EnglishLang
                                                                      .approved,
                                                                  _filteredData[
                                                                      i]['id'],
                                                                  _filteredData[
                                                                          i][
                                                                      'rootOrgName']);
                                                            },
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/img/accept_icon.svg',
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // (_filteredData.length > 2 && i==1 && widget.isFromHome) ?ElevatedButton(
                                              //   onPressed: () {
                                              //     widget.parentAction(2);
                                              //   },
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: AppColors.appBarBackground,
                                              //           elevation: 0),
                                              //   child: Padding(
                                              //     padding:
                                              //         const EdgeInsets.only(
                                              //             top: 24,
                                              //             bottom: 24),
                                              //     child: Align(
                                              //       alignment:
                                              //           Alignment.center,
                                              //       child:
                                              //           TitleRegularGrey60(
                                              //         AppLocalizations.of(
                                              //                 context)
                                              //             .showAll,
                                              //         color: AppColors
                                              //             .darkBlue,
                                              //         fontSize: 14,
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ) : Center()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            }
          } else {
            return PageLoader(
              bottom: 150,
            );
          }
          // EmptyState({
          //   'isNetwork': true,
          //   'message': 'No connections',
          //   'messageHeading':
          //       'Looks like there are no connection  \n    requests at the moment'
          // });
        });
  }
}
