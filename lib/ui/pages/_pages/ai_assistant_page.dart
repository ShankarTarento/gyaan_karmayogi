import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/_constants/vega_help.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/vega_help_model.dart';
import 'package:karmayogi_mobile/services/_services/assistant_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';
import './../../../services/index.dart';
import './../../../ui/widgets/_assistant/chat_message.dart';
import './../../../ui/widgets/_assistant/recently_searched.dart';
import './../../../ui/widgets/_assistant/voice_search_results.dart';
import 'package:record/record.dart';

class AiAssistantPage extends StatefulWidget {
  static const route = AppUrl.aiAssistantPage;
  final int index;
  final String searchKeyword;
  final bool isPublic;
  final bool isFromTextSearchPage;
  AiAssistantPage(
      {Key key,
      this.searchKeyword,
      this.index,
      this.isPublic = false,
      this.isFromTextSearchPage = false})
      : super(key: key);

  @override
  _AiAssistantPageState createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final SuggestionService suggestionService = SuggestionService();
  String _searchKeyword;
  bool _isListening = false;
  bool _isNewSearchKey = true;
  bool _hasPressedMore = false;
  String _audioDownloadPath;
  Timer _timer;
  int _start = 0;
  String _selectedLanguage = EnglishLang.english;
  final _commandController = TextEditingController();
  final AssistantService assistantService = AssistantService();
  bool _isLoading = false;

  List recentlySearchedNames = [
    'Raman Srivastava',
    'Communication Skills',
    'Administrative Law'
  ];

  List<String> dropdownItems = [EnglishLang.english, EnglishLang.hindi];
  String _dropdownValue = EnglishLang.english;
  Record _record;

  @override
  void initState() {
    super.initState();
    if (VegaConfiguration.isEnabled && widget.index == 2) {
      _record = Record();
      _isListening = false;
    }
  }

  Future<void> _deleteFileIfAlreadyExist(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw e;
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 5) {
          setState(() {
            timer.cancel();
            _stopRecord();
            _timer.cancel();
            _start = 0;
          });
        } else {
          setState(() {
            _start++;
          });
        }
      },
    );
  }

  Future _startRecord() async {
    String path = await Helper.getFilePath();
    await _deleteFileIfAlreadyExist(File('$path/input-audio.wav'));
    try {
      // Start recording
      await _record.start(
        path: '$path/input-audio.wav',
        encoder: Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
      );
      _startTimer();
      setState(() {
        _isLoading = false;
        _isListening = true;
        _textController.text = '...';
        _audioDownloadPath = "$path/input-audio.wav";
      });
    } catch (e) {
      throw e;
    }
  }

  Future _stopRecord() async {
    await _record.stop();
    final file = File(_audioDownloadPath);
    setState(() {
      _isLoading = true;
      _isListening = false;
      _timer.cancel();
      _start = 0;
    });

    List<int> fileBytes = file.readAsBytesSync();
    String base64String = base64.encode(fileBytes);

    //To get the corresponding text for the audio
    final response = await assistantService.getInputTextFromAudio(
        base64String, _selectedLanguage);
    setState(() {
      _textController.text = response['displayText'].toString().isEmpty
          ? '...'
          : response['displayText'].toString();
      _isListening = false;
      _isLoading = false;
      _searchResults(
          response['translatedText'].toString().isEmpty
              ? '...'
              : response['translatedText'].toString(),
          isVoice: true);
      _isLoading = false;
    });
  }

  _navigateToSubPage(context) async {
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        setState(() {
          _isNewSearchKey = false;
        });
      }
    });
  }

  Widget buildRecentlySearchedList(BuildContext context, int index) {
    final recent = recentlySearchedNames[index];
    return Center(child: RecentlySearched(recent));
  }

  void _searchResults(String searchKey, {bool isVoice = false}) async {
    if (mounted) {
      setState(() {
        _commandController.clear();
        if (!isVoice) {
          _textController.text = searchKey;
        }
        _searchKeyword = searchKey;
        _isNewSearchKey = true;
      });
    }
  }

  _getListData() {
    List<Widget> widgets = [];
    List<dynamic> intents = VEGA_BOTTOM_SUGGESTIONS;
    for (int i = 0; i < intents.length; i++) {
      widgets.add(Container(
          padding: EdgeInsets.only(left: 12, bottom: 1),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _commandController.clear();
                _searchKeyword = intents[i];
                _isNewSearchKey = false;
                Future.delayed(Duration(milliseconds: 100), () async {
                  _searchResults(_searchKeyword);
                });
              });
            },
            child: Text(
              intents[i],
            ),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21.0)),
                textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
                elevation: 0,
                foregroundColor: AppColors.greys87,
                backgroundColor: intents[i] == _textController.text
                    ? AppColors.primaryOne.withOpacity(0.2)
                    : Colors.white,
                side: intents[i] == _textController.text
                    ? null
                    : BorderSide(width: 1.0, color: AppColors.grey16)),
          )));
    }
    widgets.add(Container(
        padding: EdgeInsets.only(left: 12, bottom: 1),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _hasPressedMore = !_hasPressedMore;
            });
          },
          child: Text("More"),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21.0)),
              textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.greys87,
              side: BorderSide(width: 1.0, color: AppColors.grey16) // NEW
              ),
        )));

    return widgets;
  }

  _showHelpWidget() {
    List<VegaHelpItem> helpItem = VEGA_HELP_ITEMS;
    List<Widget> widgets = [];

    _getEachIntents(List<dynamic> intents) {
      List<Widget> widgets = [];
      for (var i = 0; i < intents.length; i++) {
        widgets.add(ElevatedButton(
          onPressed: () {
            setState(() {
              _commandController.clear();
              _searchKeyword = intents[i];
              _isNewSearchKey = false;
              Future.delayed(Duration(milliseconds: 100), () async {
                _searchResults(_searchKeyword);
              });
              _hasPressedMore = !_hasPressedMore;
            });
          },
          child: Text(intents[i]),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21.0)),
              textStyle: GoogleFonts.lato(
                letterSpacing: 0.5,
                fontSize: 16,
              ),
              elevation: 0,
              padding: EdgeInsets.all(10),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.greys87,
              side: BorderSide(width: 1.0, color: AppColors.grey16)
              // minimumSize: const Size.fromHeight(40), // NEW
              ),
        ));
      }
      return widgets;
    }

    for (var i = 0; i < helpItem.length; i++) {
      widgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            helpItem[i].heading,
            style: GoogleFonts.lato(
                fontSize: 18,
                color: AppColors.greys87,
                fontWeight: FontWeight.w600),
          ),
          helpItem[i].description != ''
              ? SizedBox(
                  height: 8,
                )
              : Center(),
          helpItem[i].description != ''
              ? Text(helpItem[i].description)
              : Center(),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: _getEachIntents(helpItem[i].intents),
            ),
          )
        ],
      ));
    }
    return widgets;
  }

  Future<void> _requestPermission() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                color: AppColors.primaryThree,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4.0),
                  topLeft: Radius.circular(4.0),
                ),
              ),
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                    Text(
                      'Grand a permission',
                      style: GoogleFonts.lato(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'To record a voice, allow iGOT Karmayogi to access to your microphone. Tap Settings > Permission, and turn Microphone on.',
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: 0.25,
                    height: 1.25),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Not now')),
          TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await AppSettings.openAppSettings();
              },
              child: Text('Settings'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _commandController.dispose();
    _timer?.cancel();
    if (widget.index == 2) {
      _record.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (VegaConfiguration.isEnabled && widget.index == 2)
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        pinned: false,
                        automaticallyImplyLeading: !_hasPressedMore,
                        leadingWidth: MediaQuery.of(context).size.width,
                        centerTitle: false,
                        leading: _hasPressedMore
                            ? IconButton(
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.centerRight,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _hasPressedMore = false;
                                  });
                                },
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  (widget.isPublic ||
                                          widget.isFromTextSearchPage)
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Icon(Icons.arrow_back),
                                          ))
                                      : Center(),
                                  Container(
                                    margin: EdgeInsets.only(right: 16),
                                    alignment: Alignment.centerRight,
                                    child: DropdownButton<String>(
                                      value: _dropdownValue != null
                                          ? _dropdownValue
                                          : null,
                                      icon:
                                          Icon(Icons.arrow_drop_down_outlined),
                                      iconSize: 26,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: AppColors.greys87),
                                      underline: Container(
                                        // height: 2,
                                        color: AppColors.lightGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return dropdownItems
                                            .map<Widget>((String item) {
                                          return Row(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 15.0, 0, 15.0),
                                                  child: Text(
                                                    item,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.greys87,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ))
                                            ],
                                          );
                                        }).toList();
                                      },
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _selectedLanguage = newValue;
                                          _dropdownValue = newValue;
                                        });
                                      },
                                      items: dropdownItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ];
                  },
                  body: !_hasPressedMore
                      ? Container(
                          color: Colors.white,
                          height: double.infinity,
                          child: ListView(
                            children: [
                              _textController.text.isNotEmpty
                                  ? IntrinsicHeight(
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        (_textController.text != '...' ||
                                                !_isListening)
                                            ? ChatMessage(
                                                _textController.text,
                                                isLoading: _isLoading,
                                              )
                                            : ChatMessage('...')
                                      ],
                                    ))
                                  : Center(),
                              // FutureBuilder(
                              //     future: Future.delayed(Duration(milliseconds: 5)),
                              //     builder: (BuildContext context, AsyncSnapshot snapshot) {
                              //       // print(_searchKeyword);
                              //       return AllSearchPage(_searchKeyword);
                              //     }),
                              _isNewSearchKey
                                  ? VoiceSearchResults(
                                      _searchKeyword,
                                      isPublic: widget.isPublic,
                                      selectedLanguage: _selectedLanguage,
                                    )
                                  : Center()
                            ],
                          ))
                      : Container(
                          color: Colors.white,
                          height: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _showHelpWidget(),
                            ),
                          ),
                        )),
            ),
            floatingActionButtonLocation: widget.isFromTextSearchPage
                ? FloatingActionButtonLocation.endFloat
                : (!widget.isPublic
                    ? FloatingActionButtonLocation.endDocked
                    : FloatingActionButtonLocation.endFloat),
            floatingActionButton: !_hasPressedMore
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 64,
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: ListView(
                          padding: EdgeInsets.only(left: 16),
                          scrollDirection: Axis.horizontal,
                          children: _getListData(),
                        ),
                      ),
                      (_isListening == true)
                          ? Container(
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(35, 8, 0, 16),
                                child: Container(
                                    height: 48,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                await _stopRecord();
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, right: 10),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: AppColors.greys60,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 38,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  150,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                  EnglishLang.vegaIsListening,
                                                  style: GoogleFonts.lato(
                                                    color: AppColors.greys87,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Spacer(),
                                        Container(
                                          width: 46,
                                          child: FloatingActionButton(
                                            backgroundColor:
                                                AppColors.negativeLight,
                                            child: SvgPicture.asset(
                                              'assets/img/karma_yogi.svg',
                                              width: 25.0,
                                              height: 25.0,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              _textController.text = '...';
                                            },
                                            heroTag: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.grey08,
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(28)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.24),
                                          blurRadius: 16.0,
                                          spreadRadius: 0,
                                          offset: Offset(
                                            0,
                                            8,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(35, 8, 0, 16),
                                child: Container(
                                    height: 48,
                                    // color: Colors.white,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            style: GoogleFonts.lato(
                                                fontSize: 14.0),
                                            controller: _commandController,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.search,
                                                size: 25,
                                                color: AppColors.grey40,
                                              ),
                                              suffixIcon: _commandController
                                                      .text.isNotEmpty
                                                  ? IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _commandController
                                                              .clear();
                                                        });
                                                      },
                                                      icon: Icon(Icons.clear))
                                                  : null,
                                              hintText: EnglishLang.askVega,
                                              hintStyle: GoogleFonts.lato(
                                                  color: AppColors.greys60,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                setState(() {
                                                  _isNewSearchKey = false;
                                                  _searchKeyword = value;
                                                  _textController.text = '...';
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        // Spacer(),
                                        Container(
                                          height: 55,
                                          width: 46,
                                          child: FloatingActionButton(
                                            backgroundColor:
                                                AppColors.primaryThree,
                                            child: Icon(_commandController
                                                    .text.isNotEmpty
                                                ? Icons.arrow_forward
                                                : Icons.mic_rounded),
                                            onPressed: () async {
                                              if (_commandController
                                                  .text.isEmpty) {
                                                if (await Permission.microphone
                                                    .request()
                                                    .isGranted) {
                                                  // await Permission.mediaLibrary
                                                  //     .request();
                                                  await _startRecord();
                                                  await _navigateToSubPage(
                                                      context);
                                                } else if (await Permission
                                                    .microphone
                                                    .request()
                                                    .isPermanentlyDenied) {
                                                  await Permission.microphone
                                                      .request();
                                                  // await Permission.mediaLibrary
                                                  //     .request();
                                                  await _requestPermission();
                                                }
                                              } else {
                                                Future.delayed(Duration.zero,
                                                    () async {
                                                  _searchResults(
                                                      _searchKeyword);
                                                });
                                              }
                                            },
                                            heroTag: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.grey08,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(28)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.grey08,
                                            blurRadius: 20.0,
                                            spreadRadius: 2,
                                            offset: Offset(
                                              3,
                                              3,
                                            ),
                                          ),
                                        ])),
                              ),
                            ),
                    ],
                  )
                : Center())
        : Center();
  }
}
