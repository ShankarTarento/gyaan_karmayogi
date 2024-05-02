import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowFlashLightWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onFlashClicled;

  ShowFlashLightWidget(
    this.isFlashOn,
    this.onFlashClicled, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: SizedBox(
          height: 80,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                    onPressed: null,
                    iconSize: 34,
                    icon: isFlashOn
                        ? const Icon(Icons.flash_off, color: Colors.grey)
                        : const Icon(Icons.flash_on, color: Colors.grey)),
                isFlashOn
                    ? Text(AppLocalizations.of(context).mStaticOffFlash)
                    : Text(AppLocalizations.of(context).mStaticOnFlash),
              ],
            ),
          ),
        ),
        onTap: onFlashClicled);
  }
}
