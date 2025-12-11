class UserModel {
  final int id;
  final String name;
  final String email;
  final String? city;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      city: json['city'],
    );
  }
}
