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
}
