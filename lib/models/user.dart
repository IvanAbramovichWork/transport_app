enum UserType { client, employee }

class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final UserType userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });

  // Конвертация объекта в Map для сохранения в базу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.name, // Сохраняем enum как String
    };
  }

  // Восстановление объекта из Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      userType: UserType.values.firstWhere((e) => e.name == map['userType']), // Конвертируем String в enum
    );
  }
}