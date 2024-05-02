import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/_models/profile_model.dart';
import '../../../respositories/_respositories/profile_repository.dart';
import './../../../constants/index.dart';
import './../../../respositories/index.dart';
import './../../../services/_services/network_service.dart';
import './../../../util/helper.dart';
import './../../../util/faderoute.dart';
import './../../../ui/pages/index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//ignore: must_be_immutable
class FromMyMDO extends StatefulWidget {
  final fromMyMDO;

  FromMyMDO(this.fromMyMDO);
  @override
  _FromMyMDOState createState() => _FromMyMDOState();
}

class _FromMyMDOState extends State<FromMyMDO> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic _response;

  List _data = [];
  List<dynamic> _requestedConnections = [];

  @override
  void initState() {
    super.initState();
    _getRequestedConnections();
    setState(() {
      _data = widget.fromMyMDO;
    });
  }

  _getRequestedConnections() async {
    final response =
        await Provider.of<NetworkRespository>(context, listen: false)
            .getRequestedConnections();
    if (mounted) {
      setState(() {
        _requestedConnections = response;
      });
    }
    // print(_requestedConnections.toString());
  }

  /// Post connection request
  createConnectionRequest(id) async {
    try {
      List<Profile> profileDetailsFrom;
      profileDetailsFrom =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      List<Profile> profileDetailsTo;
      profileDetailsTo =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById(id);
      _response = await NetworkService.postConnectionRequest(
          id, profileDetailsFrom, profileDetailsTo);
      if (_response['result']['message'] == 'Successful') {
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).mStaticConnectionRequestSent),
            backgroundColor: AppColors.positiveLight,
            // duration: const Duration(milliseconds: 2000),
            // behavior: SnackBarBehavior.floating,
          ),
        );
        await _getRequestedConnections();
        try {
          final dataNode =
              await Provider.of<NetworkRespository>(context, listen: false)
                  .getAllUsersFromMDO();

          setState(() {
            _data = dataNode;
          });
        } catch (err) {
          return err;
        }
      } else {
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).mStaticErrorMessage),
            backgroundColor: Theme.of(context).errorColor,
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
    if (_data.length > 0) {
      return Container(
        key: _scaffoldKey,
        width: double.infinity,
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: [
                SizedBox(
                  height: 250.0,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, index) => Container(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                        padding: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(05),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.grey04,
                                blurRadius: 8.0,
                                spreadRadius: 0.0)
                          ],
                        ),
                        child: AnimationLimiter(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              for (var i = 0;
                                  i < (_data.length > 4 ? 5 : _data.length);
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
                                                  _data[i]['id']),
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 8,
                                                  top: 32),
                                              width: 161.0,
                                              height: 176,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.grey08,
                                                    blurRadius: 6.0,
                                                    spreadRadius: 0,
                                                    offset: Offset(
                                                      3,
                                                      3,
                                                    ),
                                                  ),
                                                ],
                                                border: Border.all(
                                                    color: AppColors.grey08),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 40, 20, 0),
                                                      child: SizedBox(
                                                        height: 40,
                                                        child: Text(
                                                          (Helper.capitalize(_data[i]['personalDetails']['firstname'] !=
                                                                          null
                                                                      ? _data[i]
                                                                              ['personalDetails']
                                                                          [
                                                                          'firstname']
                                                                      : ''
                                                                          .toString()) +
                                                                  ' ' +
                                                                  (_data[i]['personalDetails']
                                                                              [
                                                                              'surname'] !=
                                                                          null
                                                                      ? Helper.capitalize(
                                                                          _data[i]['personalDetails']
                                                                              ['surname'])
                                                                      : ''))
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.lato(
                                                            color: AppColors
                                                                .greys87,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing: 0.25,
                                                            height: 1.429,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 20, right: 20),
                                                    child: Text(
                                                      _data[i][
                                                              'employmentDetails']
                                                          ['departmentName'],
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.lato(
                                                          color:
                                                              AppColors.greys60,
                                                          fontSize: 12,
                                                          letterSpacing: 0.25,
                                                          height: 1.429,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4,
                                                            left: 12,
                                                            right: 12),
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        if (!_requestedConnections
                                                            .any((element) =>
                                                                element['id'] ==
                                                                _data[i]['id']
                                                                    .toString())) {
                                                          createConnectionRequest(
                                                              _data[i]['id']);
                                                        }
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        splashFactory: _requestedConnections
                                                                .any((element) =>
                                                                    element[
                                                                        'id'] ==
                                                                    _data[i][
                                                                            'id']
                                                                        .toString())
                                                            ? NoSplash
                                                                .splashFactory
                                                            : null,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .grey16)),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Visibility(
                                                            visible: !_requestedConnections
                                                                .any((element) =>
                                                                    element[
                                                                        'id'] ==
                                                                    _data[i][
                                                                            'id']
                                                                        .toString()),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/img/connect_icon.svg',
                                                              width: 20.0,
                                                              height: 20.0,
                                                            ),
                                                          ),
                                                          !_requestedConnections
                                                                  .any((element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      _data[i][
                                                                              'id']
                                                                          .toString())
                                                              ? SizedBox(
                                                                  width: 6)
                                                              : Center(),
                                                          SizedBox(
                                                            width: 75,
                                                            child: Text(
                                                              !_requestedConnections.any((element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      _data[i][
                                                                              'id']
                                                                          .toString())
                                                                  ? AppLocalizations.of(
                                                                          context)
                                                                      .mStaticConnect
                                                                  : AppLocalizations.of(
                                                                          context)
                                                                      .mStaticConnectionRequestSent,
                                                              style: GoogleFonts.lato(
                                                                  color: !_requestedConnections.any((element) =>
                                                                          element[
                                                                              'id'] ==
                                                                          _data[i]['id']
                                                                              .toString())
                                                                      ? AppColors
                                                                          .darkBlue
                                                                      : AppColors
                                                                          .grey40,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                                top: 10,
                                                child: Center(
                                                  child: _data[i]['profileImageUrl'] !=
                                                              null &&
                                                          _data[i][
                                                                  'profileImageUrl'] !=
                                                              ''
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(63),
                                                          child: Container(
                                                            height: 64,
                                                            width: 64,
                                                            color: AppColors
                                                                .grey04,
                                                            child: Image(
                                                              height: 48,
                                                              width: 48,
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                              image: NetworkImage(
                                                                  _data[i][
                                                                      'profileImageUrl']),
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                height: 48,
                                                                width: 48,
                                                                color: AppColors
                                                                    .grey04,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 48,
                                                          width: 48,
                                                          decoration: BoxDecoration(
                                                              color: AppColors
                                                                      .networkBg[
                                                                  Random().nextInt(
                                                                      AppColors
                                                                          .networkBg
                                                                          .length)],
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: CircleAvatar(
                                                            radius: 32,
                                                            backgroundColor: AppColors
                                                                    .networkBg[
                                                                Random().nextInt(
                                                                    AppColors
                                                                        .networkBg
                                                                        .length)],
                                                            child: Text(
                                                              Helper.getInitials((_data[i]['personalDetails'][
                                                                              'firstname'] !=
                                                                          null
                                                                      ? _data[i]
                                                                              ['personalDetails']
                                                                          [
                                                                          'firstname']
                                                                      : '') +
                                                                  ' ' +
                                                                  (_data[i]['personalDetails']
                                                                              [
                                                                              'surname'] !=
                                                                          null
                                                                      ? _data[i]
                                                                              ['personalDetails']
                                                                          ['surname']
                                                                      : '')),
                                                              style: GoogleFonts.lato(
                                                                  color: AppColors
                                                                      .avatarText,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.25,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                        ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: [
                Column(
                  children: [Center()],
                )
              ],
            )
          ],
        ),
      );
    }
  }
}
