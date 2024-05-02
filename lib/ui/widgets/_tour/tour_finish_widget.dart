import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourFinishWidget extends StatefulWidget {
  final Function returnCallback;

  TourFinishWidget({this.returnCallback});
  @override
  State<TourFinishWidget> createState() => _TourWidgetState();
}

class _TourWidgetState extends State<TourFinishWidget> {
  final ProfileService profileService = ProfileService();

  bool showGetStart = true;

  @override
  void initState() {
    super.initState();
    autoClose();
  }

  void autoClose() {
    Future.delayed(Duration(milliseconds: GetStarted.autoCloseDuration),
        () async {
      if (showGetStart) {
        await finishGetStarted();
      }
    });
  }

  Future<void> finishGetStarted() async {
    final _storage = FlutterSecureStorage();
    setState(() {
      showGetStart = !showGetStart;
    });
    try {
      var response = await profileService.updateGetStarted();
      if (response['params']['status'].toString().toLowerCase() == 'success') {
        _storage.write(key: Storage.getStarted, value: GetStarted.finished);
      }
    } catch (e) {}
    if (widget.returnCallback != null) {
      widget.returnCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showGetStart
        ? GestureDetector(
            onTap: finishGetStarted,
            child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.7),
                child: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Center(
                                            child: Column(children: [
                                          Image(
                                            image: AssetImage(
                                                'assets/img/karmasahayogi.png'),
                                            height: 160,
                                          ),
                                          Column(children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft: Radius
                                                              .circular(4),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4)),
                                                  color: Color(0XFF1B4CA1),
                                                ),
                                                child: Column(children: [
                                                  Container(
                                                    width: 500,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(4),
                                                              topRight: Radius
                                                                  .circular(4)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Image(
                                                      image: AssetImage(
                                                          'assets/img/karmayogi_bharat_symbol.png'),
                                                      height: 160,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          47, 10, 47, 20),
                                                      child: Column(children: [
                                                        Text(
                                                            AppLocalizations
                                                                    .of(context)
                                                                .mLearnCongratulations,
                                                            style: GoogleFonts.montserrat(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.95),
                                                                fontSize: 20,
                                                                letterSpacing:
                                                                    0.12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                height: 1.5)),
                                                        SizedBox(height: 5),
                                                        Text(
                                                            AppLocalizations
                                                                    .of(context)
                                                                .mStaticCongratulationsDesc,
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: GoogleFonts.lato(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.95),
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    0.25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height: 1.5))
                                                      ]))
                                                ]))
                                          ])
                                        ]))
                                      ]))
                            ])))))
        : Center();
  }
}
