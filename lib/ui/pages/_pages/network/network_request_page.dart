import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/network_hub.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/index.dart';
import '../../../../respositories/index.dart';
import '../../../../services/index.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import '../../../widgets/index.dart';

class NetworkRequestPage extends StatefulWidget {
  final parentAction;
  const NetworkRequestPage({Key key, this.parentAction}) : super(key: key);

  @override
  _NetworkRequestPageState createState() => _NetworkRequestPageState();
}

class _NetworkRequestPageState extends State<NetworkRequestPage> {
  final TelemetryService telemetryService = TelemetryService();

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  int _start = 0;
  List allEventsData;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    // _getConnectionRequest(context);
    _getPymk(context);
    if (_start == 0) {
      allEventsData = [];
      _generateTelemetryData();
    }
    // _startTimer();
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.networkHomePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.networkHomePageUri,
        env: TelemetryEnv.network);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  void dispose() async {
    super.dispose();
  }

  /// Get connection request response
  Future<void> _getConnectionRequest(context) async {
    try {
      return await Provider.of<NetworkRespository>(context, listen: false)
          .getCrList();
    } catch (err) {
      return err;
    }
  }

  // Future<dynamic> _getFromMyMDO(context) async {
  //   try {
  //     dynamic _networks = [];
  //     _networks = await Provider.of<NetworkRespository>(context, listen: false)
  //         .getAllUsersFromMDO();

  //     return _networks;
  //   } catch (err) {
  //     return err;
  //   }
  // }

  /// Get PYMK response
  Future<void> _getPymk(context) async {
    try {
      return Provider.of<NetworkRespository>(context, listen: false)
          .getPymkList();
    } catch (err) {
      return err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          FutureBuilder(
            future: _getConnectionRequest(context),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.only(top: 16),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 16.0, 15.0, 15.0),
                        child: Text(
                          AppLocalizations.of(context).mStaticRecentRequests,
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Wrap(
                        children: [
                          ConnectionRequests(
                            snapshot.data,
                            false,
                            isFromHome: true,
                            parentAction: widget.parentAction,
                          )
                        ],
                      ),
                      Visibility(
                        visible: snapshot.data.data.length > 0,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            FadeRoute(
                                page: NetworkHub(
                              title: EnglishLang.requests,
                            )),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context).mLearnShowAll,
                              style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return PageLoader(
                  bottom: 150,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
