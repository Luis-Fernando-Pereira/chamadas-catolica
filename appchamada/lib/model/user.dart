
class User {
  final int? _id;
  String? name;
  String? username;
  String? password;
  bool? isOnline = false;
  String? email;
  String? _token;
  //TODO: UserType userType; 


  User({
    required id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.isOnline,
    String? token
  }) : _id = id;

  int? get id => _id;
  String? get token => _token;
}