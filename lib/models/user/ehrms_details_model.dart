class EhrmsDetails {
  String pkEmployeeId;
  String salutation;
  String employeeCode;
  String designation;
  String empFirstName;
  String empMiddleName;
  String empLastName;
  String empFatherName;
  String empEmail;
  String serviceType;
  String differentlyAbled;
  String category;
  String panNo;
  String empDob;
  String empMobile;
  String subCadreid;
  String maritalStatus;
  String presentAddress1;
  String presentAddress2;
  String presentState;
  String presentCity;
  String presentPincode;
  String prmntAddress1;
  String prmntAddress2;
  String prmntState;
  String prmntCity;
  String prmntPincode;
  String placeOfPosting;
  String mdo;
  String profilePhoto;
  String gender;

  EhrmsDetails({
    this.pkEmployeeId,
    this.salutation,
    this.employeeCode,
    this.designation,
    this.empFirstName,
    this.empMiddleName,
    this.empLastName,
    this.empFatherName,
    this.empEmail,
    this.serviceType,
    this.differentlyAbled,
    this.category,
    this.panNo,
    this.empDob,
    this.empMobile,
    this.subCadreid,
    this.maritalStatus,
    this.presentAddress1,
    this.presentAddress2,
    this.presentState,
    this.presentCity,
    this.presentPincode,
    this.prmntAddress1,
    this.prmntAddress2,
    this.prmntState,
    this.prmntCity,
    this.prmntPincode,
    this.placeOfPosting,
    this.mdo,
    this.profilePhoto,
    this.gender,
  });

  factory EhrmsDetails.fromJson(Map<String, dynamic> json) {
    return EhrmsDetails(
      pkEmployeeId: json['pkEmployeeID'],
      salutation: json['salutation'],
      employeeCode: json['employee_code'],
      designation: json['designation'],
      empFirstName: json['emp_first_name'],
      empMiddleName: json['emp_middle_name'],
      empLastName: json['emp_last_name'],
      empFatherName: json['emp_father_name'],
      empEmail: json['emp_email'],
      serviceType: json['service_type'],
      differentlyAbled: json['differently_abled'],
      category: json['category'],
      panNo: json['pan_no'],
      empDob: json['emp_dob'],
      empMobile: json['emp_mobile'],
      subCadreid: json['sub_cadreid'],
      maritalStatus: json['marital_status'],
      presentAddress1: json['present_address_1'],
      presentAddress2: json['present_address_2'],
      presentState: json['present_state'],
      presentCity: json['present_city'],
      presentPincode: json['present_pincode'],
      prmntAddress1: json['prmnt_address_1'],
      prmntAddress2: json['prmnt_address_2'],
      prmntState: json['prmnt_state'],
      prmntCity: json['prmnt_city'],
      prmntPincode: json['prmnt_pincode'],
      placeOfPosting: json['place_of_posting'],
      mdo: json['mdo'],
      profilePhoto: json['profile_photo'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pkEmployeeID': pkEmployeeId,
        'salutation': salutation,
        'employee_code': employeeCode,
        'designation': designation,
        'emp_first_name': empFirstName,
        'emp_middle_name': empMiddleName,
        'emp_last_name': empLastName,
        'emp_father_name': empFatherName,
        'emp_email': empEmail,
        'service_type': serviceType,
        'differently_abled': differentlyAbled,
        'category': category,
        'pan_no': panNo,
        'emp_dob': empDob,
        'emp_mobile': empMobile,
        'sub_cadreid': subCadreid,
        'marital_status': maritalStatus,
        'present_address_1': presentAddress1,
        'present_address_2': presentAddress2,
        'present_state': presentState,
        'present_city': presentCity,
        'present_pincode': presentPincode,
        'prmnt_address_1': prmntAddress1,
        'prmnt_address_2': prmntAddress2,
        'prmnt_state': prmntState,
        'prmnt_city': prmntCity,
        'prmnt_pincode': prmntPincode,
        'place_of_posting': placeOfPosting,
        'mdo': mdo,
        'profile_photo': profilePhoto,
        'gender': gender,
      };
}
