import 'package:equatable/equatable.dart';

class OrganisationModel extends Equatable {
  final String id;
  final String name;
  final String orgType;
  final String subOrgType;
  final String subOrgId;
  final String subRootOrgId;
  final String l1MapId;
  final String l1OrgName;
  final String l2MapId;
  final String l2OrgName;
  final String l3MapId;
  final String l3OrgName;
  final String mapId;

  const OrganisationModel(
      {this.id,
      this.name,
      this.orgType,
      this.subOrgType,
      this.subOrgId,
      this.subRootOrgId,
      this.l1MapId,
      this.l1OrgName,
      this.l2MapId,
      this.l2OrgName,
      this.l3MapId,
      this.l3OrgName,
      this.mapId});

  factory OrganisationModel.fromJson(Map<String, dynamic> json) {
    return OrganisationModel(
        id: json['id'] != null ? json['mapId'] : json['mapid'],
        name: json['orgName'],
        orgType: json['sbOrgType'],
        subOrgType: json['sbOrgSubType'],
        subOrgId: json['sbOrgId'] != null ? json['sbOrgId'] : json['sborgid'],
        subRootOrgId: json['sbRootOrgId'],
        l1MapId: json['l1MapId'],
        l1OrgName: json['l1OrgName'],
        l2MapId: json['l2MapId'],
        l2OrgName: json['l2OrgName'],
        l3MapId: json['l3MapId'],
        l3OrgName: json['l3OrgName'],
        mapId: json['mapId']);
  }

  @override
  List<Object> get props => [
        id,
        name,
        subOrgType,
        subOrgId,
        subRootOrgId,
        l1MapId,
        l1OrgName,
        l2MapId,
        l2OrgName,
        l3MapId,
        l3OrgName,
        mapId
      ];
}
