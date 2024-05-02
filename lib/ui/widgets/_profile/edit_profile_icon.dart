import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileIcon extends StatefulWidget {
  final fetchProfileDetailsAction;
  const EditProfileIcon({Key key, this.fetchProfileDetailsAction})
      : super(key: key);

  @override
  State<EditProfileIcon> createState() => _EditProfileIconState();
}

class _EditProfileIconState extends State<EditProfileIcon> {
  final _storage = FlutterSecureStorage();
  ValueNotifier<File> _selectedFile = ValueNotifier(null);
  ValueNotifier<bool> _inProcess = ValueNotifier(false);
  ValueNotifier<String> _imageUrl = ValueNotifier('');

  Future<dynamic> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    _inProcess.value = true;
    XFile image = await picker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: AppColors.primaryThree,
            toolbarTitle: EnglishLang.cropImage,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.grey.shade900,
            backgroundColor: Colors.white,
          ));
      uploadImage(cropped);
      _selectedFile.value = cropped;
      _inProcess.value = false;
    } else {
      _inProcess.value = false;
    }
  }

  Future<void> uploadImage(File selectedFile) async {
    var response = await Provider.of<ProfileRepository>(context, listen: false)
        .profilePhotoUpdate(selectedFile);
    if (response.runtimeType == int) {
      // print('Image upload failed!');
    } else {
      _imageUrl.value = Helper.convertPortalImageUrl(response);
      Map profileData = {"profileImageUrl": _imageUrl.value};
      await ProfileService().updateProfileDetails(profileData);
      await widget.fetchProfileDetailsAction();
      await _storage.write(
          key: Storage.profileImageUrl, value: _imageUrl.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(alignment: Alignment.center, child: _getImageWidget()),
        ValueListenableBuilder(
            valueListenable: _inProcess,
            builder: (BuildContext context, bool inProcess, Widget child) {
              return inProcess
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Center();
            })
      ],
    );
  }

  Widget _getImageWidget() {
    return ValueListenableBuilder(
        valueListenable: _selectedFile,
        builder: (BuildContext context, File selectedFile, Widget child) {
          return selectedFile != null
              ? Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.file(
                      _selectedFile.value,
                      height: MediaQuery.of(context).size.width * 0.35,
                      width: MediaQuery.of(context).size.width * 0.35,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        photoOptions(context);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey08,
                                blurRadius: 3,
                                spreadRadius: 0,
                                offset: Offset(
                                  3,
                                  3,
                                ),
                              ),
                            ],
                          ),
                          height: 48,
                          width: 48,
                          child: Icon(
                            Icons.edit,
                            color: AppColors.greys60,
                          )),
                    ),
                  )
                ])
              : Consumer<ProfileRepository>(
                  builder: (context, profileRepository, _) {
                  return profileRepository.profileDetails.profileImageUrl !=
                              null &&
                          profileRepository.profileDetails.profileImageUrl != ''
                      ? Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: ValueListenableBuilder(
                                valueListenable: _imageUrl,
                                builder: (BuildContext context,
                                    String imageBase64, Widget child) {
                                  return Image(
                                    height: MediaQuery.of(context).size.width *
                                        0.35,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    fit: BoxFit.fitWidth,
                                    image: NetworkImage(imageBase64.isNotEmpty
                                        ? imageBase64
                                        : profileRepository
                                            .profileDetails.profileImageUrl),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            SizedBox.shrink(),
                                  );
                                }),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                photoOptions(context);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.grey08,
                                        blurRadius: 3,
                                        spreadRadius: 0,
                                        offset: Offset(
                                          3,
                                          3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  height: 48,
                                  width: 48,
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.greys60,
                                  )),
                            ),
                          )
                        ])
                      : Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.grey16,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: SvgPicture.asset(
                                    'assets/img/connections_empty.svg',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover),
                              ),
                              InkWell(
                                onTap: () {
                                  photoOptions(context);
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          color: AppColors.primaryThree,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3.5,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .mStaticAddAPhoto,
                                              style: GoogleFonts.lato(
                                                  color: AppColors.primaryThree,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w700),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                });
        });
  }

  Future<bool> photoOptions(contextMain) {
    return showDialog(
        context: context,
        builder: (context) => Stack(
              children: [
                Positioned(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 120.0,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    _getImage(ImageSource.camera);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.photo_camera,
                                        color: AppColors.primaryThree,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mStaticTakeAPicture,
                                          style: GoogleFonts.montserrat(
                                              decoration: TextDecoration.none,
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    _getImage(ImageSource.gallery);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.photo),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mStaticGoToFiles,
                                          style: GoogleFonts.montserrat(
                                              decoration: TextDecoration.none,
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )))
              ],
            ));
  }
}
