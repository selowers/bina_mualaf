class User {
  final String id;
  final String nama;
  final String email;
  final String password;
  final String role; // 'pembimbing' or 'calon_mualaf'

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'email': email,
        'password': password,
        'role': role,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        nama: json['nama'],
        email: json['email'],
        password: json['password'],
        role: json['role'],
      );
}