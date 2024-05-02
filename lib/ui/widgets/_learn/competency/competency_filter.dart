import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';

import '../../../../models/index.dart';

class CompetencyFilter with ChangeNotifier {
  final List<CBPFilterModel> competencyfilters = [
    CBPFilterModel(category: CompetencyFilterCategory.competencyArea, filters: [
      Filter(name: CompetencyAreas.behavioural),
      Filter(name: CompetencyAreas.domain),
      Filter(name: CompetencyAreas.functional),
    ]),
    // CBPFilterModel(category: CompetencyFilterCategory.competencySubtheme, filters: []),
  ];

  List<CBPFilterModel> get filters => competencyfilters;

  void toggleFilter(String category, int index) {
    competencyfilters.forEach((element) {
      if (element.category.toLowerCase() == category.toLowerCase()) {
        element.filters[index].isSelected = !element.filters[index].isSelected;
      }
    });
    notifyListeners();
  }

  void addFilters(List<Map<String, dynamic>> filterList) {
    if (filterList != null && filterList.isNotEmpty) {
      competencyfilters.forEach((element) {
        filterList.forEach((item) {
          if (item['category'].toString() == element.category) {
            item['values'].forEach((filter) {
              var response = element.filters.firstWhere(
                  (filterItem) =>
                      filterItem.name.toLowerCase() ==
                      filter['name'].toString().toLowerCase(),
                  orElse: () => Filter(name: ''));
              if (response.name == '') {
                element.filters.add(
                    Filter(name: filter['name'], providerId: filter['id']));
              }
            });
          }
        });
      });
      notifyListeners();
    }
  }

  void addCategory(category) {
    var data = competencyfilters.firstWhere(
        (element) =>
            element.category.toLowerCase() == category.toString().toLowerCase(),
        orElse: () => CBPFilterModel(category: '', filters: []));
    if (data.filters.isEmpty) {
      competencyfilters.add(CBPFilterModel(category: category, filters: []));
    }
    notifyListeners();
  }

  void removeFilter(String category) {
    competencyfilters.removeWhere(
        (element) => element.category.toLowerCase() == category.toLowerCase());
    notifyListeners();
  }

  void searchFilters(List<Map<String, dynamic>> filterList) {
    if (filterList != null && filterList.isNotEmpty) {
      competencyfilters.forEach((element) {
        filterList.forEach((item) {
          if (item['category'].toString() == element.category) {
            if (element.filters.isNotEmpty) {}
            element.filters.removeWhere((filterItem) {
              var response = item['values'].firstWhere(
                (value) =>
                    filterItem.name.toLowerCase() ==
                    value['name'].toString().toLowerCase(),
                orElse: () => <String,
                    dynamic>{}, // Provide an empty map with the correct type
              );
              if (response.isEmpty) {
                return true;
              } else {
                return false;
              }
            });
            item['values'].forEach((filter) {
              var response = element.filters.firstWhere(
                  (filterItem) =>
                      filterItem.name.toLowerCase() ==
                      filter['name'].toString().toLowerCase(),
                  orElse: () => Filter(name: ''));
              if (response.name == '') {
                element.filters.add(
                    Filter(name: filter['name'], providerId: filter['id']));
              }
            });
          }
        });
      });
      notifyListeners();
    }
  }
}
