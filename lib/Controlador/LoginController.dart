import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:proyecto_panaderia/Vista/VLogin.dart';
import 'package:proyecto_panaderia/Controlador/SessionManager.dart'; 

class LoginController {
 
  static Future<Usuarios?> iniciarSesion(String email, String password) async {
    final firestore = FirebaseFirestore.instance;
    print('Buscando usuario con email: $email y password: $password');

    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    print('Documentos encontrados: ${querySnapshot.docs.length}');

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final usuario = Usuarios.fromFirestore(doc);

  
    await SessionManager.guardarSesion(
      userId: usuario.id,
      username: usuario.username,
      role: usuario.role,
    );

    return usuario;
  }


  Future<void> logOut(BuildContext context) async {
    try {
      await SessionManager.cerrarSesion(); 

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Login()),
        (route) => false,
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
