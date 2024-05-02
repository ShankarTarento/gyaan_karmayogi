import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import './../../../localization/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BigTip(
        title: Text(AppLocalizations.of(context).mStaticErrorOccurred),
        subtitle:
            Text(AppLocalizations.of(context).mStaticPageNotAvailableText),
        action: InkWell(
            child: Text(AppLocalizations.of(context).mStaticGoBack),
            onTap: () => Navigator.pop(context)),
        child: Icon(Icons.error_outline),
      ),
    );
  }
}
