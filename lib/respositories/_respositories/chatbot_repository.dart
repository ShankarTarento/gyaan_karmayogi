import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/chat_message_model.dart';
import 'package:karmayogi_mobile/services/_services/chatbot_service.dart';

class ChatbotRepository extends ChangeNotifier {
  ChatbotService chatbotService = ChatbotService();
  final _storage = FlutterSecureStorage();
  List<ChatMessageModel> _infoChatHistory = [];
  List<ChatMessageModel> _issuesChatHistory = [];
  var _infoFaqData;
  var _issuesFaqData;
  var _data;
  List<dynamic> dropdownItems = [
    {"value": "en", "viewValue": "English"},
    {"value": "hi", "viewValue": "हिंदी"},
    {"value": "ta", 'viewValue': "தமிழ்"},
    {"value": "te", 'viewValue': "తెలుగు"},
    {"value": "bn", 'viewValue': "বাংলা"},
    {"value": "gu", 'viewValue': "ગુજરાતી"},
    {"value": "kn", 'viewValue': "ಕನ್ನಡ"},
    {"value": "ml", 'viewValue': "മലയാളം"},
    {"value": "mr", 'viewValue': "मराठी"},
    {"value": "or", 'viewValue': "ଓଡିଆ"},
    {"value": "pa", 'viewValue': "ਪੰਜਾਬੀ"},
    {"value": "as", 'viewValue': "অসমীয়া"},
  ];
  dynamic _selectedLanguage;
  List<dynamic> _infoQandA = [];
  List<dynamic> _infoSuggestions = [];
  List<dynamic> _infoBottomSuggestions = [];

  List<dynamic> _issuesQandA = [];
  List<dynamic> _issuesSuggestions = [];
  List<dynamic> _issuesBottomSuggestions = [];
  List<dynamic> _languages;

  dynamic get selectedLanguage => _selectedLanguage;

  List<dynamic> get infoQandA => _infoQandA;
  List<dynamic> get infoSuggestions => _infoSuggestions;
  List<dynamic> get infoBottomSuggestions => _infoBottomSuggestions;

  List<dynamic> get issuesQandA => _issuesQandA;
  List<dynamic> get issuesSuggestions => _issuesSuggestions;
  List<dynamic> get issuesBottomSuggestions => _issuesBottomSuggestions;
  List<dynamic> get languages => _languages;

  List<ChatMessageModel> get infoChatHistory => _infoChatHistory;
  List<ChatMessageModel> get issueChatHistory => _issuesChatHistory;

  setLanguageDropDownValue(dynamic selectedLanguage) async {
    _selectedLanguage = selectedLanguage;
    await _storage.write(
        key: Storage.faqSelectedLanguage, value: jsonEncode(_selectedLanguage));
    updateChatHistory(isClear: true);
    notifyListeners();
  }

  setAppLanguageDropDownValue(dynamic selectedLanguage) async {
    _selectedLanguage = selectedLanguage;
    await _storage.write(
        key: Storage.selectedAppLanguage, value: jsonEncode(_selectedLanguage));

    notifyListeners();
  }

  Future<List<dynamic>> getFaqAvailableLanguages() async {
    try {
      String availableLanguages =
          await _storage.read(key: Storage.faqAvailableLanguages);
      var response;
      if (availableLanguages.toString() == null.toString()) {
        response = await chatbotService.getFaqAvailableLang();
        await _storage.write(
            key: Storage.faqAvailableLanguages, value: jsonEncode(response));
      } else {
        List data = jsonDecode(availableLanguages);
        response = data;
      }

      _languages = response;
      notifyListeners();
    } catch (_) {
      return _;
    }
    return _languages;
  }

  Future<void> getAlData() async {
    // To get information FAQs in English
    final infoFaqEn = await chatbotService.getFaqData(
        configType: FaqConfigType.info, lang: ChatBotLocale.english);
    await _storage.write(key: Storage.infoFaqEn, value: jsonEncode(infoFaqEn));

    // To get information FAQs in Hindi
    final infoFaqHi = await chatbotService.getFaqData(
        configType: FaqConfigType.info, lang: ChatBotLocale.hindi);
    await _storage.write(key: Storage.infoFaqHi, value: jsonEncode(infoFaqHi));

    // To get issues FAQs in English
    final issuesFaqEn = await chatbotService.getFaqData(
        configType: FaqConfigType.issue, lang: ChatBotLocale.english);
    await _storage.write(
        key: Storage.issuesFaqEn, value: jsonEncode(issuesFaqEn));

    // To get issues FAQs in Hindi
    final issuesFaqHi = await chatbotService.getFaqData(
        configType: FaqConfigType.issue, lang: ChatBotLocale.hindi);
    await _storage.write(
        key: Storage.issuesFaqHi, value: jsonEncode(issuesFaqHi));

    // Setting the value to know the data has fetched
    await _storage.write(key: Storage.hasFetchedFaqData, value: 'true');
  }

  Future<dynamic> getFaqData({bool isLoggedIn = false}) async {
    String language;
    final String deviceLocale = Platform.localeName.split('_').first.toString();
    String selectedLanguage =
        await _storage.read(key: Storage.faqSelectedLanguage);
    if (selectedLanguage == null) {
      if (deviceLocale == ChatBotLocale.hindi) {
        language = ChatBotLocale.hindi;
      } else {
        language = ChatBotLocale.english;
      }
    } else {
      language = jsonDecode(selectedLanguage)['value'];
    }
    try {
      await getFaqInfoData(
          categoryType: FaqConfigType.info,
          language: language,
          isLoggedIn: isLoggedIn);
      await getFaqIssuesData(
          categoryType: FaqConfigType.issue,
          language: language,
          isLoggedIn: isLoggedIn);

      notifyListeners();
    } catch (_) {
      return _;
    }
    return _data;
  }

  Future<dynamic> getFaqInfoData(
      {String categoryType,
      String language = ChatBotLocale.english,
      bool isLoggedIn = false}) async {
    try {
      var data;
      if (language == ChatBotLocale.english) {
        String infoFaqEn = await _storage.read(key: Storage.infoFaqEn);
        data = jsonDecode(infoFaqEn);
      } else if (language == ChatBotLocale.hindi) {
        String infoFaqHi = await _storage.read(key: Storage.infoFaqHi);
        data = jsonDecode(infoFaqHi);
      }
      _infoFaqData = data;
      _infoQandA = _infoFaqData['quesMap'];
      _infoSuggestions = _infoFaqData['recommendationMap'];

      List priorityListOfRecommendation = _infoSuggestions;
      List infoBottomSuggestions = _infoFaqData['categoryMap'];

      priorityListOfRecommendation.sort(
          (a, b) => (a['priority'] as int).compareTo(b['priority'] as int));

      _infoBottomSuggestions.isNotEmpty ? _infoBottomSuggestions.clear() : null;
      priorityListOfRecommendation.forEach((recommendation) {
        var value = infoBottomSuggestions.firstWhere(
            (element) => (element['catId'] == recommendation['catId'] &&
                (isLoggedIn
                    ? recommendation['categoryType'] != EnglishLang.NotLoggedIn
                    : recommendation['categoryType'] != EnglishLang.loggedIn)),
            orElse: () => -1);
        if (value != -1) {
          _infoBottomSuggestions.add(value);
        }
      });
      // notifyListeners();
    } catch (_) {
      return _;
    }
    return _infoFaqData;
  }

  Future<dynamic> getFaqIssuesData(
      {String categoryType,
      String language = ChatBotLocale.english,
      bool isLoggedIn = false}) async {
    try {
      var data;
      if (language == ChatBotLocale.english) {
        String issuesFaqEn = await _storage.read(key: Storage.issuesFaqEn);
        data = jsonDecode(issuesFaqEn);
      } else if (language == ChatBotLocale.hindi) {
        String issuesFaqHi = await _storage.read(key: Storage.issuesFaqHi);
        data = jsonDecode(issuesFaqHi);
      }
      // final response = await chatbotService.getFaqData(
      //     configType: categoryType, lang: language);
      _issuesFaqData = data;
      _issuesQandA = _issuesFaqData['quesMap'];
      _issuesSuggestions = _issuesFaqData['recommendationMap'];

      List priorityListOfRecommendation = _issuesSuggestions;
      List issueBottomSuggestions = _issuesFaqData['categoryMap'];

      priorityListOfRecommendation.sort(
          (a, b) => (a['priority'] as int).compareTo(b['priority'] as int));

      _issuesBottomSuggestions.isNotEmpty
          ? _issuesBottomSuggestions.clear()
          : null;
      priorityListOfRecommendation.forEach((recommendation) {
        var value = issueBottomSuggestions.firstWhere(
            (element) => (element['catId'] == recommendation['catId'] &&
                (isLoggedIn
                    ? recommendation['categoryType'] != EnglishLang.NotLoggedIn
                    : recommendation['categoryType'] != EnglishLang.loggedIn)),
            orElse: () => -1);
        if (value != -1) {
          _issuesBottomSuggestions.add(value);
        }
      });
      // notifyListeners();
    } catch (_) {
      return _;
    }
    return _issuesFaqData;
  }

  updateChatHistory(
      {bool isIssues,
      List<ChatMessageModel> chatList,
      bool isClear = false}) async {
    if (isClear) {
      _infoChatHistory = [];
      _issuesChatHistory = [];
    } else if (isIssues) {
      _issuesChatHistory = chatList;
    } else {
      _infoChatHistory = chatList;
    }
    notifyListeners();
  }
}
