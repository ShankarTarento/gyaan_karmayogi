import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/_models/chat_message_model.dart';
import '../../widgets/_common/page_loader.dart';

class ChatAssistantPage extends StatefulWidget {
  final String loggedInStatus;
  final bool isIssues;
  final bool isLanguageChanged;
  ChatAssistantPage(this.loggedInStatus,
      {this.isIssues = false, this.isLanguageChanged = false});
  @override
  ChatAssistantPageState createState() => ChatAssistantPageState();
}

class ChatAssistantPageState extends State<ChatAssistantPage> {
  bool _hasPressedMore = false;
  int countLimit = 5;
  List<ChatMessageModel> chatMessages;
  List<ChatMessageModel> infoChatMessages = [];
  List<ChatMessageModel> issuesMessages = [];
  bool start = true;
  List suggestionMap = [], qAndaMap = [], categoryList = [];
  List priorityList = [];
  List qAnda;
  String selectedQuestion = '';
  ScrollController _scrollController = ScrollController();
  bool _showMore = false;
  // bool _pageInitialized = false;
  String _userName;
  String profileImageUrl;
  final _storage = FlutterSecureStorage();

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _getChatHistory();
    _getData(isIssue: widget.isIssues);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getChatHistory();

    if (widget.isLanguageChanged) {
      updateChatAssistantPageWidget();
    }
  }

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        contentId,
        subtype,
        env: TelemetryEnv.home,
        objectType: subtype);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  void dispose() async {
    super.dispose();
  }

  _getChatHistory() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      infoChatMessages = Provider.of<ChatbotRepository>(context, listen: false)
          .infoChatHistory;
      issuesMessages = Provider.of<ChatbotRepository>(context, listen: false)
          .issueChatHistory;
    });
  }

  _getData({bool isIssue}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userName = await _storage.read(key: Storage.firstName);
      profileImageUrl = await _storage.read(key: Storage.profileImageUrl);
      await getqAndaMap(isIssue: isIssue);
      await getSuggestionList(isIssue: isIssue);
    });
  }

  Future<void> getSuggestionList({bool isIssue = false}) async {
    suggestionMap = [];
    final res = isIssue
        ? Provider.of<ChatbotRepository>(context, listen: false)
            .issuesSuggestions
        : Provider.of<ChatbotRepository>(context, listen: false)
            .infoSuggestions;
    suggestionMap = res;
    List list = suggestionMap.isNotEmpty
        ? getPriorityQuestions(suggestionMap, 1, '')
        : [];
    list = list.toSet().toList();
    if (start) {
      if (widget.isIssues && issuesMessages.length > 0) {
        chatMessages = issuesMessages;
        scrollToBottom();
      } else if (!widget.isIssues && infoChatMessages.length > 0) {
        chatMessages = infoChatMessages;
        scrollToBottom();
      } else {
        chatMessages = [
          ChatMessageModel(
              title:
                  AppLocalizations.of(context).mStaticHereSomeFrequentlyAsked,
              response: '',
              isUser: false,
              timestamp: DateTime.now(),
              suggestions: [],
              isBottomSuggestions: false,
              categoryList: []),
        ];
        chatMessages[0].suggestions = list;
      }
    }
    setState(() {});
  }

  Future<void> getqAndaMap({bool isIssue = false}) async {
    final res = isIssue
        ? Provider.of<ChatbotRepository>(context, listen: false).issuesQandA
        : Provider.of<ChatbotRepository>(context, listen: false).infoQandA;
    setState(() {
      qAnda = res;
    });
  }

  updateChatAssistantPageWidget() async {
    setState(() {
      start = true;
    });
    await _getData(isIssue: widget.isIssues);
  }

  List getPriorityQuestions(res, priority, catId) {
    priorityList = [];
    res.forEach((element) {
      if ((catId != null && catId != '') && element['catId'] == catId) {
        element['recommendedQues'].forEach((value) {
          qAnda.forEach((item) {
            if (item['quesId'] == value['quesID']) {
              priorityList.add(item);
            }
          });
        });
      } else if (catId == '' &&
          (element['categoryType'] == widget.loggedInStatus ||
              element['categoryType'] == EnglishLang.both)) {
        element['recommendedQues'].forEach((value) {
          if (value['priority'] == 1) {
            qAnda.forEach((item) {
              if (item['quesId'] == value['quesID']) {
                priorityList.add(item);
              }
            });
          }
        });
      }
    });
    return priorityList;
  }

  void updateSecondPriorityMEssage(questionList) {
    List pList = [];
    suggestionMap.forEach((element) {
      element['recommendedQues'].forEach((value) {
        if (value['quesID'] == questionList['quesId']) {
          value['recommendedQues'].forEach((item) {
            qAnda.forEach((items) {
              if (items['quesId'] == item['quesID']) {
                pList.add({
                  'quesId': items['quesId'],
                  'quesValue': items['quesValue']
                });
              }
            });
          });
        }
      });
    });
    qAnda.forEach((items) {
      if (items['quesId'] == questionList['quesId']) {
        updateChatmessage('', items['quesValue'], true, DateTime.now(), []);
        updateChatmessage(
            pList.length > 0
                ? AppLocalizations.of(context).mStaticQuestionsRelated
                : '',
            items['ansVal'],
            false,
            DateTime.now(),
            pList);
      }
    });
  }

  updateChatmessage(title, response, isUser, timestamp, suggestion,
      {bool isBottomSuggestion = false, var categories}) {
    chatMessages.add(ChatMessageModel(
        title: title,
        response: response,
        isUser: isUser,
        timestamp: timestamp,
        suggestions: suggestion,
        categoryList: categories,
        isBottomSuggestions: isBottomSuggestion));
    Provider.of<ChatbotRepository>(context, listen: false)
        .updateChatHistory(isIssues: widget.isIssues, chatList: chatMessages);
  }

  void scrollToBottom() {
    Timer(Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    });
  }

  Future<List<dynamic>> getCategory(context) async {
    try {
      return widget.isIssues
          ? Provider.of<ChatbotRepository>(context, listen: false)
              .issuesBottomSuggestions
          : Provider.of<ChatbotRepository>(context, listen: false)
              .infoBottomSuggestions;
    } catch (err) {
      print(err);
      return err;
    }
  }

  _getListData(categoryList) {
    List<Widget> widgets = [];

    categoryList.length > countLimit
        ? widgets.add(Container(
            padding: EdgeInsets.only(left: 12, bottom: 1),
            child: ElevatedButton(
              onPressed: () {
                updateChatmessage(
                    '',
                    AppLocalizations.of(context).mStaticShowAllCatgories,
                    true,
                    DateTime.now(), []);
                updateChatmessage(
                    AppLocalizations.of(context).mStaticShowingAllCatgories,
                    '',
                    false,
                    DateTime.now(),
                    [],
                    isBottomSuggestion: true,
                    categories: categoryList);
                scrollToBottom();
                setState(() {
                  _showMore = false;
                });
              },
              child: Text(AppLocalizations.of(context).mStaticShowAllCatgories,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                      height: 1.5)),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.0)),
                  textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
                  elevation: 0,
                  backgroundColor: AppColors.grey04,
                  foregroundColor: AppColors.greys87,
                  side: BorderSide(width: 1.0, color: AppColors.grey16) // NEW
                  ),
            )))
        : null;

    for (int i = 0; i < categoryList.length; i++) {
      widgets.add(Container(
          height: 50,
          padding: EdgeInsets.only(left: 12, bottom: 1),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                updateChatmessage(
                    '', categoryList[i]['catName'], true, DateTime.now(), []);
                List list = suggestionMap.isNotEmpty
                    ? getPriorityQuestions(
                        suggestionMap, 1, categoryList[i]['catId'])
                    : [];
                list = list.toSet().toList();
                if (list.isNotEmpty)
                  updateChatmessage(
                      AppLocalizations.of(context).mStaticShowingMoreQuestions,
                      '',
                      false,
                      DateTime.now(),
                      list);
                scrollToBottom();
              });
            },
            child: Text(
              categoryList[i]['catName'],
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  height: 1.5),
            ),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21.0)),
                textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
                elevation: 0,
                foregroundColor: AppColors.grey04,
                backgroundColor: AppColors.grey04,
                side: BorderSide(width: 1.0, color: AppColors.grey16)),
          )));
    }
    return widgets;
  }

  Widget chatbotMessage(
      ChatMessageModel message, context, chatIndex, islastIndex) {
    // _showItems = false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 12),
          child: Image.asset(
            'assets/img/KS.png',
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              (message.response != null && message.response != '')
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, top: 16),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        width: MediaQuery.of(context).size.width / 1.6,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16)),
                          border: Border.all(
                              color: Color.fromRGBO(0, 0, 0, 0.08), width: 1),
                        ),
                        child: HtmlWidget(
                          message.response
                              .toString()
                              .replaceFirst(EnglishLang.teamsLinkKeyword,
                                  EnglishLang.htmlTeamsLink)
                              .replaceFirst(EnglishLang.emailLinkKeyword,
                                  EnglishLang.htmlEmailLink),
                          textStyle: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 0.25,
                              height: 1.5),
                        ),
                      ),
                    )
                  : Center(),
              // (message.title != '' && message.title != null)
              //     ? Align(
              //         alignment: Alignment.centerLeft,
              //         child: Container(
              //           margin: const EdgeInsets.symmetric(
              //               vertical: 16, horizontal: 8),
              //           // padding: const EdgeInsets.all(12),
              //           width: MediaQuery.of(context).size.width / 1.6,
              //           child: Text(
              //             message.title,
              //             style: GoogleFonts.lato(
              //                 color: AppColors.greys87,
              //                 fontWeight: FontWeight.w700,
              //                 fontSize: 14,
              //                 letterSpacing: 0.25,
              //                 height: 1.5),
              //           ),
              //         ),
              //       )
              //     : Center(),

              // list.isNotEmpty
              message.suggestions.isNotEmpty
                  ? FutureBuilder(builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12, left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                for (var i = 0;
                                    i <
                                        (message.suggestions.length >
                                                    countLimit &&
                                                !_showMore
                                            ? countLimit
                                            : message.suggestions.length);
                                    i++)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 6, 6, 6),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _generateInteractTelemetryData(
                                              message.suggestions[i]['quesId'],
                                              TelemetrySubType.question);
                                          updateSecondPriorityMEssage(
                                              message.suggestions[i]);
                                          start = false;
                                          selectedQuestion =
                                              message.suggestions[i]['quesId'];
                                          scrollToBottom();
                                        });
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 10, 16, 10),
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (selectedQuestion ==
                                                        message.suggestions[i]
                                                            ['quesId']) &&
                                                    !islastIndex
                                                ? Color(0XFF1B4CA1)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: (selectedQuestion ==
                                                          message.suggestions[i]
                                                              ['quesId']) &&
                                                      !islastIndex
                                                  ? Color(0XFF1B4CA1)
                                                  : Colors.grey,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: Text(
                                              message.suggestions[i]
                                                  ['quesValue'],
                                              style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.w400,
                                                  color: (selectedQuestion ==
                                                              message.suggestions[
                                                                      i]
                                                                  ['quesId']) &&
                                                          !islastIndex
                                                      ? AppColors.avatarText
                                                      : AppColors.greys87,
                                                  fontSize: 14,
                                                  letterSpacing: 0.25,
                                                  height: 1.5)),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            message.suggestions.length > countLimit &&
                                    !_showMore
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showMore = !_showMore;
                                      });
                                      scrollToBottom();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          12, 6, 8, 16),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 10, 16, 10),
                                      decoration: BoxDecoration(
                                        color: Color(0XFF1B4CA1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 4,
                                        children: [
                                          Icon(
                                            _showMore
                                                ? Icons.expand_less
                                                : Icons.add,
                                            color: AppColors.avatarText,
                                            size: 20,
                                          ),
                                          Text(
                                            _showMore
                                                ? AppLocalizations.of(context)
                                                    .mStaticShowLess
                                                : AppLocalizations.of(context)
                                                    .mStaticShowMore,
                                            style: GoogleFonts.lato(
                                              color: AppColors.avatarText,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Center()
                          ],
                        ),
                      );
                    })
                  : Center(),
              message.isBottomSuggestions
                  ? FutureBuilder(builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                for (var i = 0;
                                    i < message.categoryList.length;
                                    i++)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 6, 6, 6),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _generateInteractTelemetryData(
                                              message.categoryList[i]['catId'],
                                              TelemetrySubType.category);
                                          updateChatmessage(
                                              '',
                                              message.categoryList[i]
                                                  ['catName'],
                                              true,
                                              DateTime.now(),
                                              []);

                                          List list = suggestionMap.isNotEmpty
                                              ? getPriorityQuestions(
                                                  suggestionMap,
                                                  1,
                                                  message.categoryList[i]
                                                      ['catId'])
                                              : [];
                                          if (list.isNotEmpty) {
                                            // print('here....$list');
                                            updateChatmessage(
                                              '',
                                              '',
                                              false,
                                              DateTime.now(),
                                              list,
                                            );
                                          }
                                          start = false;
                                          selectedQuestion =
                                              message.categoryList[i]['catId'];
                                          scrollToBottom();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 10, 16, 10),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (selectedQuestion ==
                                                      message.categoryList[i]
                                                          ['catId'] &&
                                                  !islastIndex)
                                              ? Color(0XFF1B4CA1)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: (selectedQuestion ==
                                                        message.categoryList[i]
                                                            ['catId'] &&
                                                    !islastIndex)
                                                ? Color(0XFF1B4CA1)
                                                : Colors.grey,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0),
                                          ),
                                        ),
                                        child: Text(
                                            message.categoryList[i]['catName'],
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w400,
                                                color: (selectedQuestion ==
                                                            message.categoryList[
                                                                i]['catId'] &&
                                                        !islastIndex)
                                                    ? AppColors.avatarText
                                                    : AppColors.greys87,
                                                fontSize: 14,
                                                letterSpacing: 0.25,
                                                height: 1.5)),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                  : Center(),
            ],
          ),
        ),
      ],
    );
  }

  Widget userMessage(message) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 24, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.6,
            ),
            decoration: BoxDecoration(
              color: message.isUser ? Color(0XFF1B4CA1) : Colors.grey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
            ),
            child: Text(
              message.response,
              style: GoogleFonts.lato(
                  color: AppColors.avatarText,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.25,
                  height: 1.5),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.grey40),
            child: Center(
              child: profileImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(63),
                      child: Image(
                        height: 40,
                        width: 40,
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(profileImageUrl),
                        errorBuilder: (context, error, stackTrace) =>
                            SizedBox.shrink(),
                      ),
                    )
                  : _userName != null
                      ? Text(
                          Helper.getInitialsNew(_userName),
                          style: GoogleFonts.lato(
                              color: AppColors.avatarText,
                              fontWeight: FontWeight.w600,
                              fontSize: 20.0),
                        )
                      : Icon(
                          Icons.person,
                          color: AppColors.appBarBackground,
                        ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getChatHistory();
    _getData(isIssue: widget.isIssues);
    return qAnda != null && qAnda.isNotEmpty
        ? Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * .8,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(bottom: 50),
                child: chatMessages != null
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 10),
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = chatMessages[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: message.isUser
                                ? userMessage(message)
                                : chatbotMessage(message, context, index,
                                    index == (chatMessages.length - 1)),
                          );
                        },
                      )
                    : Center(),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: !_hasPressedMore
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60,
                        color: AppColors.scaffoldBackground,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: FutureBuilder(
                            future: getCategory(context),
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> categories = snapshot.data;
                                return ListView(
                                  // padding: EdgeInsets.only(left: 16),
                                  scrollDirection: Axis.horizontal,
                                  children: _getListData(categories),
                                );
                              } else {
                                return PageLoader();
                              }
                            }),
                      ),
                    ],
                  )
                : Center(child: PageLoader()))
        : Center();
  }
}
