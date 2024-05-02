import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/feedback/widgets/_microSurvey/page_loader.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import './../../../../util/helper.dart';
import './../../../../constants/index.dart';
import './../../../../models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResourcesItem extends StatefulWidget {
  final KnowledgeResource knowledgeResource;
  final parentAction;
  final parentActionForSaved;
  ResourcesItem(this.knowledgeResource,
      {this.parentAction, this.parentActionForSaved});

  @override
  _ResourcesItemState createState() {
    return _ResourcesItemState();
  }
}

class _ResourcesItemState extends State<ResourcesItem>
    with TickerProviderStateMixin {
  bool selectionStatus = false;
  Map<int, double> _progress = {};
  Map<int, double> _fileSize = {};
  bool bookmark;
  AnimationController _iconAnimationController;
  bool _multiItemContent = false;

  @override
  void initState() {
    super.initState();
    bookmark = widget.knowledgeResource.bookmark;
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  Future<dynamic> downloadFile(String fileType, String url, index) async {
    Permission _permision = Permission.storage;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        _permision = Permission.photos;
      }
    }
    await Helper.requestPermission(_permision);
    if (url == '') {
      _displayDialog(false, '', parentContext: context);
      return;
    }
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String filename = '${Helper.getFileName(url)}_$timestamp';
    if (fileType.contains('/')) {
      fileType = fileType.split('/').last;
    }
    var httpClient = http.Client();
    var request = new http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);
    // String dir = (await getApplicationDocumentsDirectory()).path;
    // String dir = APP_DOWNLOAD_FOLDER;
    String path = await Helper.getDownloadPath();
    await Directory('$path').create(recursive: true);

    List<List<int>> chunks = [];
    int downloaded = 0;
    _progress[index] = 0;
    // _displayDialog(_progress);
    response.asStream().listen((http.StreamedResponse r) {
      // print('r.contentLength: ' + r.contentLength.toString());
      if (r.contentLength == null) {
        _displayDialog(false, '', parentContext: context);
        return;
      }
      r.stream.listen((List<int> chunk) {
        // Display percentage of completion
        // debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');
        setState(() {
          _fileSize[index] = r.contentLength / (1000);
          _progress[index] = (downloaded / r.contentLength);
        });
        // debugPrint('downloadPercentage: ${_progress.toString()}');
        chunks.add(chunk);
        downloaded += chunk.length;
        // print(downloaded.toString());
      }, onDone: () async {
        // Display percentage of completion
        // debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');
        setState(() {
          _progress[index] = (downloaded / r.contentLength);
        });
        try {
          // debugPrint('downloadPercentage: ${_progress.toString()}');
          // Save the file
          // String filePath = '$dir/$filename.$fileType';
          String filePath = '$path/$filename.$fileType';
          // File file = new File(filePath);
          final Uint8List bytes = Uint8List(r.contentLength);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          await File(filePath).writeAsBytes(bytes);

          // await file.writeAsBytes(bytes);
          // setState(() {
          //   _progress[index] = 1;
          // });
          _displayDialog(true, filePath, parentContext: context);
        } catch (e) {
          _displayDialog(false, '', parentContext: context);
        }
        return;
      });
    });
  }

  String _getFileIcon(String fileExtension) {
    if (fileExtension.contains('/')) {
      fileExtension = fileExtension.split('/').last;
    }
    switch (fileExtension) {
      case 'jpg':
        return 'assets/img/jpg.svg';
        break;
      case 'jpeg':
        return 'assets/img/jpg.svg';
        break;
      case 'png':
        return 'assets/img/png.svg';
        break;
      case 'pdf':
        return 'assets/img/pdf.svg';
        break;
      case 'mp4':
        return 'assets/img/video.svg';
        break;
      case 'ppt':
        return 'assets/img/ppt.svg';
        break;
      case 'xlsx':
        return 'assets/img/excel.svg';
        break;
      case 'doc':
        return 'assets/img/doc.svg';
        break;
      default:
        return 'assets/img/default.svg';
    }
  }

  Future<bool> _displayDialog(bool isSuccess, String filePath,
      {@required BuildContext parentContext}) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Stack(
              children: [
                Positioned(
                    child: Align(
                        // alignment: FractionalOffset.center,
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          // margin: EdgeInsets.only(left: 20, right: 20),
                          width: double.infinity,
                          height: filePath != '' ? 190.0 : 140,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 15),
                                  child: Text(
                                    isSuccess
                                        ? AppLocalizations.of(parentContext)
                                            .mStaticFileDownloadingCompleted
                                        : AppLocalizations.of(parentContext)
                                            .mStaticErrorOccurred,
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  )),
                              filePath != ''
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () => _openFile(filePath),
                                        child: roundedButton(
                                          AppLocalizations.of(parentContext)
                                              .mStaticOpen,
                                          AppColors.primaryThree,
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Center(),
                              // Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(false),
                                  child: roundedButton(
                                      AppLocalizations.of(parentContext)
                                          .mStaticClose,
                                      Colors.white,
                                      AppColors.primaryThree),
                                ),
                              ),
                            ],
                          ),
                        )))
              ],
            ));
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: MediaQuery.of(context).size.width - 50,
      padding: EdgeInsets.all(10),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
        border: bgColor == Colors.white
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey08,
            blurRadius: 6.0,
            spreadRadius: 0,
            offset: Offset(
              3,
              3,
            ),
          ),
        ],
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _resourceItemView(),
    );
  }

  Widget _cardImageView({String imgEndPoint = ''}) {
    imgEndPoint = imgEndPoint.replaceAll(' ', '');
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: CachedNetworkImage(
          height: 200,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill,
          imageUrl: ApiUrl.baseUrl +
              '/assets/instances/eagle/banners/hubs/knowledgeresource/thumbnails/$imgEndPoint.png',
          placeholder: (context, url) => PageLoader(),
          errorWidget: (context, url, error) => CachedNetworkImage(
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
                imageUrl: ApiUrl.baseUrl + '/assets/icons/Events_default.png',
                placeholder: (context, url) => PageLoader(),
                errorWidget: (context, url, error) => SvgPicture.asset(
                  'assets/img/pdf_download.svg',
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              )),
    );
  }

  Widget _resourceItemView() {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          child: _cardImageView(imgEndPoint: widget.knowledgeResource.name),
        ),
        SizedBox(
          height: 8.0,
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.knowledgeResource.name != null)
                Container(
                  child: Text(
                    widget.knowledgeResource.name,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              if (widget.knowledgeResource.description != null)
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.knowledgeResource.description,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (widget.knowledgeResource.raw['additionalProperties'] != null)
                Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      if (widget.knowledgeResource.files != null)
                        Row(
                          children: [
                            widget.knowledgeResource.krFiles
                                        .where(
                                            (item) => item['fileType'] == 'jpg')
                                        .toList()
                                        .length !=
                                    0
                                ? Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/img/jpg.svg',
                                        width: 24.0,
                                        height: 24.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 18),
                                        child: Text(
                                          widget.knowledgeResource.krFiles
                                              .where((item) =>
                                                  item['fileType'] == 'jpg')
                                              .toList()
                                              .length
                                              .toString(),
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            widget.knowledgeResource.krFiles
                                        .where(
                                            (item) => item['fileType'] == 'png')
                                        .toList()
                                        .length !=
                                    0
                                ? Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/img/png.svg',
                                        width: 24.0,
                                        height: 24.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 18),
                                        child: Text(
                                          widget.knowledgeResource.krFiles
                                              .where((item) =>
                                                  item['fileType'] == 'png')
                                              .toList()
                                              .length
                                              .toString(),
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            widget.knowledgeResource.krFiles
                                        .where(
                                            (item) => item['fileType'] == 'pdf')
                                        .toList()
                                        .length !=
                                    0
                                ? Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/img/pdf.svg',
                                        width: 24.0,
                                        height: 24.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 18),
                                        child: Text(
                                          widget.knowledgeResource.krFiles
                                              .where((item) =>
                                                  item['fileType'] == 'pdf')
                                              .toList()
                                              .length
                                              .toString(),
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      // if (widget.knowledgeResource.urls != null)
                      //   _link(widget.knowledgeResource.urls.length),
                    ],
                  ),
                ),
              if ((widget.knowledgeResource.raw['additionalProperties'] !=
                      null &&
                  widget.knowledgeResource.raw['additionalProperties']
                      .isNotEmpty))
                _resourceAccessView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resourceAccessView() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 8.0),
            width: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey08,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: _multiItemContent
                    ? ExpansionTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Recent",
                                style: GoogleFonts.lato(
                                    decoration: TextDecoration.none,
                                    color: AppColors.primaryThree,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        children: <Widget>[
                          _fileItemList(),
                          if (widget.knowledgeResource.urls != null)
                            _linkItemList(),
                          SizedBox(
                            height: 8.0,
                          )
                        ],
                      )
                    : Column(
                        children: [
                          if (widget.knowledgeResource.urls != null)
                            _linkItem(0),
                          if (widget.knowledgeResource.files != null)
                            _fileItem(0),
                        ],
                      ))),
      ],
    );
  }

  Widget _fileItem(int index) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
            onTap: () => downloadFile(
                widget.knowledgeResource.krFiles[index]['fileType'],
                Env.portalBaseUrl +
                    '/content-store/' +
                    widget.knowledgeResource.krFiles[index]['name'],
                index),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              margin: EdgeInsets.only(top: 5.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.knowledgeResource.files != null)
                      Container(
                          child: Text(
                        getFileNameFromUrl(
                            widget.knowledgeResource.files[index]),
                        style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      )),
                    if (widget.knowledgeResource.files != null)
                      Container(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              _getFileIcon(widget.knowledgeResource
                                  .krFiles[index]['fileType']),
                              width: 24.0,
                              height: 24.0,
                            ),
                            Spacer(),
                            Text(
                              _fileSize[index] != null
                                  ? _fileSize[index].toStringAsFixed(2) + 'Kb'
                                  : '',
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    _progress[index] != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: LinearProgressIndicator(
                              backgroundColor: AppColors.lightGrey,
                              value: _progress[index],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryThree),
                            ),
                          )
                        : Center(),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _fileItemList() {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.knowledgeResource.files != null
            ? widget.knowledgeResource.files.length
            : 0,
        itemBuilder: (context, index) {
          return Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(
              top: 8,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryThree,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: _fileItem(index),
          );
        },
      ),
    );
  }

  Widget _linkItem(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {
            if (widget.knowledgeResource.urls[index]['value'] != '') {
              _launchURL(widget.knowledgeResource.urls[index]['value']);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.link,
                      color: AppColors.primaryThree,
                    ),
                  ),
                  if (widget.knowledgeResource.urls[index]['name'] != null)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 8.0),
                        child: Text(
                          widget.knowledgeResource.urls[index]['name'],
                          style: GoogleFonts.lato(
                              color: AppColors.primaryThree,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkItemList() {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.knowledgeResource.urls.length,
        itemBuilder: (context, index) {
          return Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(
              top: 8,
            ),
            decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryThree,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: _linkItem(index),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      throw '$url: $e';
    }
  }

  String getFileNameFromUrl(String url) {
    File file = new File(url);
    String fullFileName = file.path.split('/').last;
    List<String> fileNameParts = fullFileName.split('_');
    if (fileNameParts.length > 1) {
      return fileNameParts.sublist(1).join('_');
    } else {
      return fullFileName;
    }
  }
}
