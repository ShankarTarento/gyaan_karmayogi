import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rounded_button.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import '../../../models/index.dart';
import './../../../constants/index.dart';
import '../../pages/_pages/home_page/home_page.dart';
import './../../../ui/widgets/_home/home_silver_list.dart';
import './../../../ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/homeScreen';
  final int index;
  final Profile profileInfo;
  final profileParentAction;

  HomeScreen({Key key, this.index, this.profileInfo, this.profileParentAction})
      : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<bool> _onBackPressed() {
    return showModalBottomSheet(
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
        builder: (context) => SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            height: 6,
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration: BoxDecoration(
                              color: AppColors.grey16,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 15),
                            child: Text(
                              AppLocalizations.of(context).mHomeExitApp,
                              style: GoogleFonts.montserrat(
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 15),
                          child: GestureDetector(
                            onTap: () async {
                              String userId = await Telemetry.getUserId();
                              await TelemetryDbHelper.triggerEvents(userId,
                                  forceTrigger: true);
                              try {
                                SystemNavigator.pop();
                              } catch (e) {
                                Navigator.of(context).pop(true);
                              }
                            },
                            child: RoundedButton(
                                buttonLabel: AppLocalizations.of(context)
                                    .mHomeComfirmExit,
                                bgColor: Colors.white,
                                textColor: AppColors.primaryThree),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 15),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: RoundedButton(
                                buttonLabel: AppLocalizations.of(context)
                                    .mHomeCancelExit,
                                bgColor: AppColors.primaryThree,
                                textColor: Colors.white),
                          ),
                        ),
                      ])),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.index == 0
        ? WillPopScope(
            child: Scaffold(
              body: CustomScrollView(
                slivers: <Widget>[
                  HomeAppBarNew(
                    profileInfo: widget.profileInfo,
                    index: widget.index,
                    profileParentAction: widget.profileParentAction,
                  ),
                  HomeSilverList(
                    child: Container(
                      color: Color.fromRGBO(241, 244, 244, 1),
                      child: widget.index == 0
                          ? HomePage(
                              index: widget.index,
                            )
                          : Center(),
                    ),
                  )
                ],
              ),
              // floatingActionButtonLocation:
              //     FloatingActionButtonLocation.centerFloat,
              // floatingActionButton: Chatbotbtn()
            ),
            onWillPop: _onBackPressed,
          )
        : Center();
  }
}
