class RegistrationGroup {
  String name;

  RegistrationGroup({
    this.name,
  });

  factory RegistrationGroup.fromJson(Map<String, dynamic> json) {
    return RegistrationGroup(
      name: json['name'],
    );
  }

  List<Object> get props => [name];
}
