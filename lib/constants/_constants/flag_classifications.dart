import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/flag_classification_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<FlagClassificationItem> FLAG_CLASSIFICATIONS({BuildContext context}) => [
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason1,
        description: AppLocalizations.of(context).mDiscussReportReason1,
      ),
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason2,
        description: AppLocalizations.of(context).mDiscussReportReason2Des,
      ),
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason3,
        description: AppLocalizations.of(context).mDiscussReportReason3Des,
      ),
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason4,
        description: AppLocalizations.of(context).mDiscussReportReason4Des,
      ),
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason5,
        description: AppLocalizations.of(context).mDiscussReportReason5Des,
      ),
      FlagClassificationItem(
        type: AppLocalizations.of(context).mDiscussReportReason6,
        description: AppLocalizations.of(context).mDiscussReportReason6Des,
      ),
    ];
