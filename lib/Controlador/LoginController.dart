import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_panaderia/Vista/VLogin.dart';


class LoginController {
  static Future<Usuarios?> iniciarSesion(String email, String password) async {
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return Usuarios.fromFirestore(doc);
  }

    Future<void> logOut(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

}
