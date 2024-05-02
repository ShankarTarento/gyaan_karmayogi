import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileTab {
  final String title;

  EditProfileTab({
    this.title,
  });

  static List<EditProfileTab> getItems(context) => [
        EditProfileTab(
          title: AppLocalizations.of(context).mEditProfileMandatoryDetails,
        ),
        EditProfileTab(
          title: AppLocalizations.of(context).mEditProfileOtherDetails,
        ),
        EditProfileTab(
          title: AppLocalizations.of(context).mEditProfileEhrmsDetails,
        ),
      ];

  static List<EditProfileTab> getItemsWithoutEhrms(context) => [
        EditProfileTab(
          title: AppLocalizations.of(context).mEditProfileMandatoryDetails,
        ),
        EditProfileTab(
          title: AppLocalizations.of(context).mEditProfileOtherDetails,
        ),
      ];
}
