class NewCompetencyModel {
  String courseId;
  List<CompetencyArea> competencyArea;

  NewCompetencyModel({this.courseId, this.competencyArea});

  factory NewCompetencyModel.fromJson(Map<String, dynamic> json) {
    var competencyAreasJson = json['competencies_v5'] as List;
    List<CompetencyArea> competencyAreas = competencyAreasJson
        .map((areaJson) => CompetencyArea.fromJson(areaJson))
        .toList();

    return NewCompetencyModel(
      courseId: json['courseId'],
      competencyArea: competencyAreas,
    );
  }
}

class CompetencyArea {
  String name;
  String id;
  List<CompetencyTheme> competencyTheme;

  CompetencyArea({this.name, this.id, this.competencyTheme});

  factory CompetencyArea.fromJson(Map<String, dynamic> json) {
    var competencyThemesJson = json['competencies_v5'] as List;
    List<CompetencyTheme> competencyThemes = competencyThemesJson
        .map((themeJson) => CompetencyTheme.fromJson(themeJson))
        .toList();

    return CompetencyArea(
      name: json['competencyArea'],
      id: json['competencyAreaId'].toString(),
      competencyTheme: competencyThemes,
    );
  }
}

class CompetencyTheme {
  List<CompetencySubTheme> subTheme;
  String id;
  String name;

  CompetencyTheme({this.subTheme, this.id, this.name});

  factory CompetencyTheme.fromJson(Map<String, dynamic> json) {
    var competencySubThemesJson = json['competencies_v5'] as List;
    List<CompetencySubTheme> competencySubThemes = competencySubThemesJson
        .map((subThemeJson) => CompetencySubTheme.fromJson(subThemeJson))
        .toList();

    return CompetencyTheme(
      id: json['competencyThemeId'].toString(),
      name: json['competencyTheme'],
      subTheme: competencySubThemes,
    );
  }
}

class CompetencySubTheme {
  String id;
  String name;

  CompetencySubTheme({this.id, this.name});

  factory CompetencySubTheme.fromJson(Map<String, dynamic> json) {
    return CompetencySubTheme(
      id: json['competencySubThemeId'].toString(),
      name: json['competencySubTheme'],
    );
  }
}
