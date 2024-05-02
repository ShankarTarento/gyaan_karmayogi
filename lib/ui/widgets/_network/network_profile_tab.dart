import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkProfileTab {
  final String title;

  NetworkProfileTab({
    this.title,
  });

  static List<NetworkProfileTab> items({@required BuildContext context}) => [
        NetworkProfileTab(
          title: AppLocalizations.of(context).mNetworkUserProfile,
        ),
        NetworkProfileTab(
          title: AppLocalizations.of(context).mStaticDiscussions,
        ),
        NetworkProfileTab(
          title: AppLocalizations.of(context).mNetworkUserUpvotes,
        ),
      ];
}
