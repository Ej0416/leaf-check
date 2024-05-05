class UserModel {
  final String uid;
  final String name;
  final String email;
  // final String country;
  // final String region;
  // final String city;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    // required this.country,
    // required this.region,
    // required this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        name: json['username'],
        email: json['email'],
        // country: json['country'],
        // region: json['region'],
        // city: json['city'],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "email": email,
        // "country": country,
        // "region": region,
        // "city": city,
      };
}
