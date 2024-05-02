import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';

class EditProfileTags extends StatelessWidget {
  const EditProfileTags({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget child) {
      return profileRepository.profileDetails.tags.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                AppLocalizations.of(context).mEditProfileNoTagsAvailable,
                style: TextStyle(color: AppColors.grey40),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: profileRepository.profileDetails.tags
                    .map((tag) => Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.grey04,
                            border: Border.all(color: AppColors.grey40),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Text(tag)))
                    .toList(),
              ),
            );
    });
  }
}
