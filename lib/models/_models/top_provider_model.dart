import 'dart:convert';

TopProviderModel topProviderModelFromJson(String str) =>
    TopProviderModel.fromJson(json.decode(str));

String topProviderModelToJson(TopProviderModel data) =>
    json.encode(data.toJson());

class TopProviderModel {
  String clientImageUrl;
  String clientName;

  TopProviderModel({
    this.clientImageUrl,
    this.clientName,
  });

  factory TopProviderModel.fromJson(Map<String, dynamic> json) =>
      TopProviderModel(
          clientImageUrl: json["clientImageUrl"],
          clientName: json["clientName"]);

  Map<String, dynamic> toJson() =>
      {"clientImageUrl": clientImageUrl, "clientName": clientName};
}
