import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SavedOpeningsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                        AppLocalizations.of(context).mStaticSavedOpenings)))
          ],
        ),
      ),
    );
  }
}
