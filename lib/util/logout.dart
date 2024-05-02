import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:karmayogi_mobile/services/_services/logout_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rounded_button.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Logout extends StatelessWidget {
  final BuildContext contextMain;
  const Logout({Key key, @required this.contextMain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> doLogout(context) async {
      final _storage = FlutterSecureStorage();
      String parichayToken =
          await _storage.read(key: Storage.parichayAuthToken);
      // print('Parichay token: $parichayToken');

      String userId = await Telemetry.getUserId();
      await TelemetryDbHelper.triggerEvents(userId, forceTrigger: true);

      try {
        final keyCloakLogoutResponse = await LogoutService.doKeyCloakLogout();
        if (keyCloakLogoutResponse == 204) {
          if (parichayToken != null) {
            final parichayLogoutResponse =
                await LogoutService.doParichayLogout();
            if (parichayLogoutResponse == 200) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppUrl.onboardingScreen, (r) => false);
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, AppUrl.onboardingScreen, (r) => false);
          }
        }
      } catch (e) {
        throw e;
      } finally {
        await Provider.of<LoginRespository>(context, listen: false).clearData();
      }
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
        width: double.infinity,
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
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: Text(
                  AppLocalizations.of(context).mSettingDoYouWantToLogout,
                  style: GoogleFonts.montserrat(
                      decoration: TextDecoration.none,
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
                doLogout(contextMain);
              },
              child: RoundedButton(
                  buttonLabel: AppLocalizations.of(context).mSettingYeslogout,
                  bgColor: Colors.white,
                  textColor: AppColors.primaryThree),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: RoundedButton(
                  buttonLabel: AppLocalizations.of(context).mCommonNoTakeMeBack,
                  bgColor: AppColors.primaryThree,
                  textColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
