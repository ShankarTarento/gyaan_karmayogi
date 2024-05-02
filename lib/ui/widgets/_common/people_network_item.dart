import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/faderoute.dart';
import '../../../util/helper.dart';
import '../../pages/index.dart';

class PeopleNetworkItem extends StatelessWidget {
  final Suggestion suggestion;
  final networkFromSearch;
  final ValueChanged<String> parentAction1;
  final parentAction2;
  final List<dynamic> requestedConnections;

  const PeopleNetworkItem(
      {Key key,
      this.suggestion,
      this.networkFromSearch,
      this.parentAction1,
      this.parentAction2,
      this.requestedConnections})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isConnectionNotRequested = (!requestedConnections.any((element) =>
        element['id'] ==
        (suggestion != null
            ? suggestion.id.toString()
            : networkFromSearch['id'])));
    return InkWell(
        onTap: () => Navigator.push(
              context,
              FadeRoute(
                page: ChangeNotifierProvider<NetworkRespository>(
                  create: (context) => NetworkRespository(),
                  child: NetworkProfile(suggestion != null
                      ? suggestion.id
                      : networkFromSearch['id']),
                ),
              ),
            ),
        child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 32),
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
                  border: Border.all(color: AppColors.grey08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                          child: SizedBox(
                            height: 40,
                            child: Text(
                              (networkFromSearch != null)
                                  ? ((networkFromSearch['profileDetails'] != null &&
                                          (networkFromSearch['profileDetails']
                                                  ['personalDetails'] !=
                                              null))
                                      ? (Helper.capitalize(networkFromSearch['profileDetails']['personalDetails']['firstname'] != null ? networkFromSearch['profileDetails']['personalDetails']['firstname'] : '') +
                                              ' ' +
                                              Helper.capitalize(networkFromSearch['profileDetails']
                                                              ['personalDetails']
                                                          ['surname'] !=
                                                      null
                                                  ? networkFromSearch['profileDetails']
                                                          ['personalDetails']
                                                      ['surname']
                                                  : ''))
                                          .toString()
                                          .trim()
                                      : 'Unknown user')
                                  : (Helper.capitalize(suggestion.firstName != null ? suggestion.firstName : '') +
                                          ' ' +
                                          Helper.capitalize(suggestion.lastName))
                                      .toString()
                                      .trim(),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.25,
                                height: 1.429,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 40,
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          (networkFromSearch != null)
                              ? ((networkFromSearch['profileDetails'] != null &&
                                      (networkFromSearch['profileDetails']
                                                  ['employmentDetails'] !=
                                              null &&
                                          networkFromSearch['profileDetails']
                                                      ['employmentDetails']
                                                  ['departmentName'] !=
                                              null))
                                  ? networkFromSearch['profileDetails']
                                      ['employmentDetails']['departmentName']
                                  : '')
                              : ((suggestion.department != null)
                                  ? (suggestion.department.toString())
                                  : ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontSize: 12,
                              letterSpacing: 0.25,
                              height: 1.429,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            bottom: 4, left: 12, right: 12),
                        child: OutlinedButton(
                          onPressed: () {
                            if (suggestion != null &&
                                (!requestedConnections.any((element) =>
                                    element['id'] == suggestion.id))) {
                              parentAction1(suggestion.id);
                              parentAction2(suggestion.id,
                                subType: TelemetrySubType.suggestedConnections,
                                primaryCategory : TelemetryObjectType.user,
                                clickId: TelemetryIdentifier.cardContent);
                            } else {
                              if (networkFromSearch != null &&
                                  !requestedConnections.any((element) =>
                                      element['id'] ==
                                      networkFromSearch['id'])) {
                                parentAction1(networkFromSearch['id']);
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            splashFactory: (requestedConnections.any(
                                    (element) =>
                                        element['id'] ==
                                        (suggestion != null
                                            ? suggestion.id.toString()
                                            : networkFromSearch['id'])))
                                ? NoSplash.splashFactory
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: AppColors.grey16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: isConnectionNotRequested,
                                child: SvgPicture.asset(
                                  'assets/img/connect_icon.svg',
                                  width: 20.0,
                                  height: 20.0,
                                ),
                              ),
                              isConnectionNotRequested
                                  ? SizedBox(width: 6)
                                  : Center(),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  isConnectionNotRequested
                                      ? AppLocalizations.of(context)
                                          .mStaticConnect
                                      : AppLocalizations.of(context)
                                          .mStaticConnectionRequestSent,
                                  style: GoogleFonts.lato(
                                      color: (!requestedConnections.any(
                                              (element) =>
                                                  element['id'] ==
                                                  (suggestion != null
                                                      ? suggestion.id.toString()
                                                      : networkFromSearch[
                                                          'id'])))
                                          ? AppColors.darkBlue
                                          : AppColors.grey40,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ])),
            Positioned(
                top: 0,
                left: 50,
                child: Center(
                  child: networkFromSearch != null
                      ? ((networkFromSearch['profileDetails'] != null &&
                              (networkFromSearch['profileDetails']
                                          ['profileImageUrl'] !=
                                      null &&
                                  networkFromSearch['profileDetails']
                                          ['profileImageUrl'] !=
                                      ''))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(63),
                              child: Container(
                                height: 64,
                                width: 48,
                                color: AppColors.grey04,
                                child: Image(
                                  height: 48,
                                  width: 48,
                                  fit: BoxFit.fitWidth,
                                  image: NetworkImage(
                                      networkFromSearch['profileDetails']
                                          ['profileImageUrl']),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 48,
                                    width: 48,
                                    color: AppColors.grey04,
                                  ),
                                ),
                              ))
                          : CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.networkBg[
                                  Random().nextInt(AppColors.networkBg.length)],
                              child: Text(
                                (networkFromSearch['profileDetails']['personalDetails'] !=
                                        null)
                                    ? Helper.getInitials((networkFromSearch['profileDetails']
                                                            ['personalDetails']
                                                        ['firstname'] !=
                                                    null
                                                ? networkFromSearch['profileDetails']
                                                        ['personalDetails']
                                                    ['firstname']
                                                : '')
                                            .trim() +
                                        ' ' +
                                        (networkFromSearch['profileDetails']
                                                            ['personalDetails']
                                                        ['surname'] !=
                                                    null
                                                ? networkFromSearch['profileDetails']
                                                    ['personalDetails']['surname']
                                                : '')
                                            .trim())
                                    : 'UN',
                                style: GoogleFonts.montserrat(
                                    color: AppColors.avatarText,
                                    fontSize: 20.0,
                                    letterSpacing: 0.12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ))
                      : (suggestion.photo != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                  Helper.getByteImage(suggestion.photo)))
                          : CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.networkBg[
                                  Random().nextInt(AppColors.networkBg.length)],
                              child: Text(
                                  Helper.getInitials(
                                      (suggestion.firstName != null
                                                  ? suggestion.firstName
                                                  : '')
                                              .trim() +
                                          ' ' +
                                          suggestion.lastName.trim()),
                                  style: GoogleFonts.montserrat(
                                      color: AppColors.avatarText,
                                      fontSize: 20.0,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w600)),
                            )),
                )),
          ],
        ));
  }
}
