class BlendedProgramEnrollResponseModel {
  Data data;
  String message;
  String status;

  BlendedProgramEnrollResponseModel({this.data, this.message, this.status});

  BlendedProgramEnrollResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Data {
  String wfIds;
  String status;

  Data({this.wfIds, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    wfIds = json['wfIds'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wfIds'] = this.wfIds;
    data['status'] = this.status;
    return data;
  }
}