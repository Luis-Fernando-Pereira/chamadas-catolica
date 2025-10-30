// lib/model/user_type.dart

enum UserType {
  STUDENT('Student'),
  PROFESSOR('Professor'),
  ADMIN('Admin');

  const UserType(this.description);

  final String description;
}
