import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:provider/provider.dart';
import '../index.dart';
import './../../../constants/index.dart';
import './../../../respositories/index.dart';
import './../../../ui/pages/index.dart';
import './../../../util/faderoute.dart';
import './../../../util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MyConnectionCard extends StatefulWidget {
  final establishedConnections;
  final bool isRecommended;

  MyConnectionCard(this.establishedConnections, {this.isRecommended = false});
  @override
  _MyConnectionCardState createState() => _MyConnectionCardState();
}

class _MyConnectionCardState extends State<MyConnectionCard> {
  List _tempData = [];
  List _filteredData = [];
  dynamic _data;
  String _dropdownValue = EnglishLang.lastAdded;
  bool _pageInitialized = false;
  List<LocalizationText> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _data = widget.establishedConnections;
    });

    // print(ids.toString());
  }

  @override
  void didChangeDependencies() {
    dropdownItems =
        LocalizationText.getNetworkConnectionRequestFilter(context: context);
    super.didChangeDependencies();
  }

  /// Get connection request response
  Future<List> _getUserNames(context) async {
    try {
      if (!_pageInitialized) {
        List ids = [];
        if (_data != null) {
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
      return _filteredData;
    } catch (err) {
      return err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUserNames(context),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.length == 0)
              return widget.isRecommended
                  ? Center()
                  : Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: SvgPicture.asset(
                                    'assets/img/connections.svg',
                                    alignment: Alignment.center,
                                    // width: MediaQuery.of(context).size.width,
                                    // height: MediaQuery.of(context).size.height,
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
                    );
            else
              return Container(
                margin: EdgeInsets.only(top: 4.0, bottom: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 18.0, 15.0, 10.0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              "${_filteredData.length} ${_filteredData.length == 1 ? AppLocalizations.of(context).mCommonConnection : AppLocalizations.of(context).mCommonConnections}",
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                          width: 130,
                          margin: EdgeInsets.only(right: 16, top: 8),
                          child: DropdownButton<String>(
                            value:
                                _dropdownValue != null ? _dropdownValue : null,
                            icon: Icon(Icons.arrow_drop_down_outlined),
                            iconSize: 26,
                            elevation: 16,
                            hint: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 16),
                              child: SizedBox(
                                width: 80,
                                child: Text(
                                  '${AppLocalizations.of(context).mCommonSortBy} ',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.greys87,
                              overflow: TextOverflow.ellipsis,
                            ),
                            underline: Container(
                              // height: 2,
                              color: AppColors.lightGrey,
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return dropdownItems
                                  .map<Widget>((LocalizationText item) {
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
                                              color: AppColors.greys87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                            items: dropdownItems.map<DropdownMenuItem<String>>(
                                (LocalizationText value) {
                              return DropdownMenuItem<String>(
                                value: value.value,
                                child: SizedBox(
                                  width: 100,
                                  child: Text(
                                    value.displayText,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: (MediaQuery.of(context).size.width > 700)
                          ? EdgeInsets.only(left: 16)
                          : EdgeInsets.zero,
                      child: AnimationLimiter(
                        child: Wrap(
                          children: [
                            for (int i = 0; i < _filteredData.length; i++)
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
                                        width: (MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                700)
                                            ? 350
                                            : MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            bottom: 5.0,
                                            right: (MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    700)
                                                ? 16
                                                : 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: AppColors
                                                          .lightBackground,
                                                      width: 2.0),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    child: Container(
                                                      height: 48,
                                                      width: 48,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                                .networkBg[
                                                            Random().nextInt(
                                                                AppColors
                                                                    .networkBg
                                                                    .length)],
                                                        borderRadius: BorderRadius
                                                            .all(const Radius
                                                                .circular(4.0)),
                                                      ),
                                                      child: Center(
                                                        child: _filteredData[i]['profileDetails'] != null &&
                                                                (_filteredData[i]
                                                                            ['profileDetails'][
                                                                        'photo'] !=
                                                                    null)
                                                            ? Container(
                                                                child:
                                                                    _filteredData[i]['profileDetails']['photo'].length !=
                                                                            0
                                                                        ? (ClipRRect(
                                                                            borderRadius: BorderRadius.circular(50),
                                                                            child: Image.memory(Helper.getByteImage(_filteredData[i]['profileDetails']['photo']))))
                                                                        : (Text(
                                                                            Helper.getInitials(_filteredData[i]['profileDetails']['personalDetails']['firstname'] +
                                                                                ' ' +
                                                                                _filteredData[i]['profileDetails']['personalDetails']['surname']),
                                                                            style:
                                                                                GoogleFonts.lato(
                                                                              color: Colors.white,
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          )))
                                                            : Text(
                                                                // item['name'] != null
                                                                //     ? Helper.getInitials(
                                                                //         item['name'] +
                                                                //             ' ')
                                                                //     : 'UN',
                                                                Helper.getInitials(_filteredData[i]['profileDetails']
                                                                            [
                                                                            'personalDetails']
                                                                        [
                                                                        'firstname'] +
                                                                    ' ' +
                                                                    (_filteredData[i]['profileDetails']['personalDetails']['surname'] !=
                                                                            null
                                                                        ? _filteredData[i]['profileDetails']['personalDetails']
                                                                            [
                                                                            'surname']
                                                                        : '')),
                                                                style:
                                                                    GoogleFonts
                                                                        .lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >
                                                                    700)
                                                                ? 220
                                                                : (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    150),
                                                            child: Wrap(
                                                              children: [
                                                                Text(
                                                                  _filteredData[i]['profileDetails']
                                                                              [
                                                                              'personalDetails'] !=
                                                                          null
                                                                      ? _filteredData[i]['profileDetails']['personalDetails']
                                                                              [
                                                                              'firstname'] +
                                                                          ' ' +
                                                                          (_filteredData[i]['profileDetails']['personalDetails']['surname'] != null
                                                                              ? _filteredData[i]['profileDetails']['personalDetails']['surname']
                                                                              : '')
                                                                      : 'UN',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: GoogleFonts.lato(
                                                                      color: AppColors
                                                                          .greys87,
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                                (_filteredData[i]['profileDetails']
                                                                            [
                                                                            'verifiedKarmayogi'] ==
                                                                        true)
                                                                    ? Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 8),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .check_circle,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              AppColors.positiveLight,
                                                                        ),
                                                                      )
                                                                    : Center()
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0),
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >
                                                                    700)
                                                                ? 220
                                                                : (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    150),
                                                            child: Text(
                                                              _filteredData[i][
                                                                          'rootOrgName'] !=
                                                                      null
                                                                  ? _filteredData[
                                                                          i][
                                                                      'rootOrgName']
                                                                  : '',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.lato(
                                                                  color: AppColors
                                                                      .greys60,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.start,
                                            //   children: [
                                            //     IconButton(
                                            //       onPressed: () {},
                                            //       icon: Icon(
                                            //         Icons.more_vert,
                                            //         color: AppColors.greys60,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
          } else {
            return PageLoader(
              bottom: 175,
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
