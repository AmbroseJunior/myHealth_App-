class UserModel {
  final int id;
  final String email;
  final String passwordHash;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as int,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
        createdAt: map['created_at'] as String,
      );
}
