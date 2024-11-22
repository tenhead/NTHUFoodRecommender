class MyUser {
  String id;
  String username;
  String email;
  int? age;
  double? weight;
  double? height;

  MyUser({
    required this.id,
    required this.username,
    required this.email,
    this.age,
    this.weight,
    this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
    );
  }
}