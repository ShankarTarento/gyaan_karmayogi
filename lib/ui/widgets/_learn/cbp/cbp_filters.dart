import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';

import '../../../../models/index.dart';

class CBPFilter with ChangeNotifier {
  final List<CBPFilterModel> _cbpfilters = [
    CBPFilterModel(category: CBPFilterCategory.contentType, filters: [
      Filter(name: PrimaryCategory.course),
      Filter(name: PrimaryCategory.curatedProgram),
      Filter(name: PrimaryCategory.blendedProgram),
      Filter(name: PrimaryCategory.standaloneAssessment),
      Filter(name: PrimaryCategory.moderatedCourses)
    ]),
    CBPFilterModel(category: CBPFilterCategory.status, filters: [
      Filter(name: CBPCourseStatus.inProgress),
      Filter(name: CBPCourseStatus.notStarted),
      Filter(name: CBPCourseStatus.completed)
    ]),
    CBPFilterModel(category: CBPFilterCategory.timeDuration, filters: [
      Filter(name: CBPFilterTimeDuration.upcoming7days),
      Filter(name: CBPFilterTimeDuration.upcoming30days),
      Filter(name: CBPFilterTimeDuration.upcoming3months),
      Filter(name: CBPFilterTimeDuration.upcoming6months),
      Filter(name: CBPFilterTimeDuration.lastWeek),
      Filter(name: CBPFilterTimeDuration.lastMonth),
      Filter(name: CBPFilterTimeDuration.last3month),
      Filter(name: CBPFilterTimeDuration.last6month),
      Filter(name: CBPFilterTimeDuration.lastYear)
    ]),
    CBPFilterModel(category: CBPFilterCategory.provider, filters: []),
    CBPFilterModel(category: CBPFilterCategory.competencyArea, filters: [])
  ];

  List<CBPFilterModel> get filters => _cbpfilters;

  void toggleFilter(String category, int index) {
    _cbpfilters.forEach((element) {
      if (element.category.toLowerCase() == category.toLowerCase()) {
        element.filters[index].isSelected = !element.filters[index].isSelected;
      }
    });
    notifyListeners();
  }

  void addFilters(List<Map<String, dynamic>> filterList) {
    if (filterList != null && filterList.isNotEmpty) {
      _cbpfilters.forEach((element) {
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

  // Remove filtering category(Eg: Competency area)
  void removeFilter(String category) {
    _cbpfilters.removeWhere(
        (element) => element.category.toLowerCase() == category.toLowerCase());
    notifyListeners();
  }

  // Add filter category(Eg: Competency area)
  void addCategory(category) {
    var data = _cbpfilters.firstWhere(
        (element) =>
            element.category.toLowerCase() == category.toString().toLowerCase(),
        orElse: () => CBPFilterModel(category: '', filters: []));
    if (data.category == "") {
      _cbpfilters.add(CBPFilterModel(category: category, filters: []));
    }
    notifyListeners();
  }

  void searchFilters(List<Map<String, dynamic>> filterList) {
    if (filterList != null && filterList.isNotEmpty) {
      _cbpfilters.forEach((element) {
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
