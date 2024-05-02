import 'dart:convert';

OverlayThemeModel overrideThemeChangesFromJson(String str) =>
    OverlayThemeModel.fromJson(json.decode(str));

class OverlayThemeModel {
  final bool isEnabled;
  final int animationDuration;
  final String logoUrl;
  final String logoText;
  final List<dynamic> backgroundColors;

  OverlayThemeModel({
    this.isEnabled,
    this.animationDuration,
    this.logoUrl,
    this.logoText,
    this.backgroundColors,
  });
  factory OverlayThemeModel.fromJson(Map<String, dynamic> json) =>
      OverlayThemeModel(
        isEnabled: json["isEnabled"] ?? false,
        animationDuration: json["animationDuration"] ?? 0,
        logoUrl: json["logoUrl"] ?? '',
        logoText: json["logoText"] ?? '',
        backgroundColors: json["backgroundColors"] ?? [],
      );
  factory OverlayThemeModel.defaultData() => OverlayThemeModel(
        isEnabled: false,
        animationDuration: 0,
        logoUrl: '',
        logoText: '',
        backgroundColors: [],
      );
  factory OverlayThemeModel.sampleData() => OverlayThemeModel(
          isEnabled: true,
          animationDuration: 10,
          logoUrl: 'assets/animations/mobile_animation_file.json',
          logoText: '75th Republic Day',
          backgroundColors: [
            '0XFFF8DACE',
            '0XFFFFFFFF',
            '0XFFCBEED2',
          ]);
}
