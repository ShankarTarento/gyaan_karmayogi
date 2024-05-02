import 'dart:convert';

import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';

class AssistantService {
  Future<dynamic> getInputTextFromAudio(
      String audioBase64, String selectedLanguage) async {
    String url = ApiUrl.asrApiUrl;

    String serviceId = (selectedLanguage == EnglishLang.english
        ? AILanguageModel.english
        : AILanguageModel.hindi);

    // String selectedLocale = (selectedLanguage == EnglishLang.english
    //     ? Locale.english
    //     : Locale.hindi);

    Map<String, String> headers = {
      "Authorization": Env.vegaAsrApiKey,
      "Content-Type": "application/json; charset=utf-8",
    };

    Map data = selectedLanguage == EnglishLang.hindi
        ? {
            "pipelineTasks": [
              {
                "taskType": "asr",
                "config": {
                  "language": {"sourceLanguage": ""},
                  "serviceId": serviceId,
                  "audioFormat": "flac",
                  "samplingRate": 16000
                }
              },
              {
                "taskType": "translation",
                "config": {
                  "language": {"sourceLanguage": "hi", "targetLanguage": "en"},
                  "serviceId": AILanguageModel.hindiToEnglish
                }
              }
            ],
            "inputData": {
              "input": [
                {"source": ""}
              ],
              "audio": [
                {"audioContent": audioBase64}
              ]
            }
          }
        : {
            "pipelineTasks": [
              {
                "taskType": "asr",
                "config": {
                  "language": {"sourceLanguage": ""},
                  "serviceId": serviceId,
                  "audioFormat": "flac",
                  "samplingRate": 16000
                }
              },
            ],
            "inputData": {
              "input": [
                {"source": ""}
              ],
              "audio": [
                {"audioContent": audioBase64}
              ]
            }
          };

    var body = jsonEncode(data);

    // log('Request body:' + body.toString());

    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    String displayText;
    String translated;
    if (response.statusCode == 200) {
      var content = json.decode(utf8.decode(response.bodyBytes));

      if (selectedLanguage == EnglishLang.english) {
        content['pipelineResponse'].forEach((element) {
          if (element['taskType'] == 'asr') {
            translated = element['output'][0]['source'];
            displayText = translated;
          }
        });
      } else {
        content['pipelineResponse'].forEach((element) {
          if (element['taskType'] == 'translation') {
            translated = element['output'][0]['target'];
          } else if (element['taskType'] == 'asr') {
            displayText = element['output'][0]['source'];
          }
        });
      }
    } else {
      throw response.statusCode;
    }

    Map inputText = {'displayText': displayText, 'translatedText': translated};

    return inputText;
  }
}
