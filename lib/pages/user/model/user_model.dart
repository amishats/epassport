import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  const UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.phoneNumber,
    required this.passportPhoto,
    required this.signPhoto,
  });

  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String phoneNumber;
  final String passportPhoto;
  final String signPhoto;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        firstName: json["firstName"].toString(),
        lastName: json["lastName"].toString(),
        email: json["email"].toString(),
        age: int.tryParse(json["age"].toString()) ?? 0,
        phoneNumber: json["phoneNumber"].toString(),
        passportPhoto: json["passportPhoto"].toString(),
        signPhoto: json["signPhoto"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "age": age,
        "phoneNumber": phoneNumber,
        "passportPhoto": passportPhoto,
        "signPhoto": signPhoto,
      };
}
