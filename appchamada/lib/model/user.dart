import 'user_type.dart';

class User {
  final int? _id;
  String? name;
  String? username;
  String? password;
  bool? isOnline = false;
  String? email;
  String? token;
  UserType? userType;
  //TODO: UserType userType;

  User({
    required id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.isOnline,
    this.token,
    this.userType,
  }) : _id = id;

  User.idOnly({required id}) : _id = id;

  int? get id => _id;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': name,
      'username': username,
      'password': password,
      'isOnline': isOnline,
      'email': email,
      'token': token,
      'userType': userType?.index,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      isOnline: json['isOnline'] as bool?,
      email: json['email'] as String?,
      token: json['token'] as String?,
      userType: json['userType'] != null
          ? UserType.values[json['userType'] as int]
          : null,
    );
  }
}
