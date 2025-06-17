import 'package:cloud_firestore/cloud_firestore.dart';

class Usuarios {
  String id;
  String email;
  String username;
  String password;
  String role;

  Usuarios({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.role,
  });

  factory Usuarios.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  return Usuarios(
    id: doc.id,
    email: data['email'] ?? '',
    username: data['username'] ?? '',
    password: data['password'] ?? '',
    role: data['role'] ?? 'Empleado',
  );
}


  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}
