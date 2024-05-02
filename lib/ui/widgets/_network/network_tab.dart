import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './../../../localization/index.dart';

class NetworkTab {
  final String title;

  NetworkTab({
    this.title,
  });

  static List<NetworkTab> items({@required BuildContext context}) => [
        NetworkTab(
          title: AppLocalizations.of(context).mStaticHome,
        ),
        NetworkTab(
          title: AppLocalizations.of(context).mNetworkTabYourConnections,
        ),
        NetworkTab(
          title: AppLocalizations.of(context).mNetworkTabConnectionRequests,
        ),
        NetworkTab(
          title: AppLocalizations.of(context).mNetworkTabFromYourMdo,
        ),
        NetworkTab(
          title: AppLocalizations.of(context).mNetworkTabRecommendedConnections,
        ),
      ];
}
