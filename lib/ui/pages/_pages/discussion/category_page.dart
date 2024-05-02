import 'dart:async';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import './../../../../respositories/index.dart';
import './../../../../ui/widgets/_discussion/category_card.dart';
import './../../../../util/faderoute.dart';
import './../../../../ui/pages/index.dart';
import './../../../../ui/widgets/_common/page_loader.dart';
import './../../../../localization/index.dart';
// import './../../../../constants/index.dart';
import './../../../../services/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryPage extends StatefulWidget {
  final int tabIndex;
  CategoryPage({Key key, this.tabIndex}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
    _getCategoryList(context);

    if (_start == 0) {
      allEventsData = [];
      _generateTelemetryData();
    }
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
        TelemetryPageIdentifier.categoriesPageUri,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.categoriesPageUri,
        env: TelemetryEnv.discuss);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.categoriesPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.categoryCard,
        env: TelemetryEnv.discuss,
        objectType: TelemetrySubType.categoryCard);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
    allEventsData.add(eventData);
  }

  /// Get category list
  Future<void> _getCategoryList(context) async {
    try {
      return await Provider.of<CategoryRepository>(context, listen: false)
          .getListOfCategories();
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
          future: _getCategoryList(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AnimationLimiter(
                child: Column(
                  children: [
                    Wrap(
                      children: [
                        for (var i = 0; i < snapshot.data.length; i++)
                          AnimationConfiguration.staggeredList(
                            position: i,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: InkWell(
                                  onTap: () {
                                    _generateInteractTelemetryData(
                                        snapshot.data[i].cid.toString());
                                    Navigator.push(
                                      context,
                                      // FadeRoute(
                                      //     page: DiscussionFilterPage(
                                      //         isCategory: true,
                                      //         id: item.cid,
                                      //         title: item.title)),
                                      FadeRoute(
                                          page: FilteredDiscussionsPage(
                                        isCategory: true,
                                        id: snapshot.data[i].cid,
                                        title: snapshot.data[i].title,
                                        backToTitle:
                                            AppLocalizations.of(context)
                                                .mStaticBackToCategories,
                                      )),
                                    );
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: CategoryCard(snapshot.data[i]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              );
            } else {
              return PageLoader(
                bottom: 175,
              );
            }
          }),
    );
  }
}
