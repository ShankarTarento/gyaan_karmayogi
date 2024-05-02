class BrowseV5CompetencyCardModel {
  final String competencyArea;
  final String competencyAreaDescription;
  final int competencyAreaId;
  final String competencyTheme;
  final String competencyThemeDescription;
  final int competencyThemeId;
  final String competencyThemeType;
  final String competencySubTheme;
  final int competencySubThemeId;
  final String competencySubThemeDescription;
  final rawDetails;

  BrowseV5CompetencyCardModel(
      {this.competencyArea,
      this.competencyAreaDescription,
      this.competencyAreaId,
      this.competencyTheme,
      this.competencyThemeDescription,
      this.competencyThemeId,
      this.competencyThemeType,
      this.competencySubTheme,
      this.competencySubThemeId,
      this.competencySubThemeDescription,
      this.rawDetails});

  factory BrowseV5CompetencyCardModel.fromJson(Map<String, dynamic> json) {
    return BrowseV5CompetencyCardModel(
      competencyArea: json['competencyArea'] ?? '',
      competencyAreaDescription: json['competencyAreaDescription'] ?? '',
      competencyAreaId: json['competencyAreaId'] ?? 0,
      competencyThemeDescription: json['competencyThemeDescription'] ?? '',
      competencyThemeId: json['competencyThemeId'] ?? 0,
      competencyThemeType: json['competencyThemeType'] ?? '',
      competencySubTheme: json['competencySubTheme'] ?? '',
      competencySubThemeId: json['competencySubThemeId'] ?? 0,
      competencySubThemeDescription:
          json['competencySubThemeDescription'] ?? '',
      competencyTheme: json['competencyTheme'] ?? '',
      rawDetails: json,
    );
  }
}
