import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GetVerifiedKarmayogiInfo extends StatelessWidget {
  const GetVerifiedKarmayogiInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(AppLocalizations.of(context)
                .mEditProfileGetVerifiedKarmayogiInfo),
          ),
        ],
      ),
    );
  }
}
