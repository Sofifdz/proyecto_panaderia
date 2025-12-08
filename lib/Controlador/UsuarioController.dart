import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsuarioController {
  Future<void> eliminarUsuario(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print("Usuario eliminado de Firestore.");
    } catch (e) {
      print("Error al eliminar el usuario: $e");
      throw e;
    }
  }

  static Future<String> obtenerUsuarioId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return user?.uid ?? '';
    } catch (e) {
      print("Error al obtener el usuario ID: $e");
      return '';
    }
  }

  static Future<String> obtenerUsername(String userId) async {
    if (userId.isEmpty) return '';
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['username'] ?? '';
    }
    return '';
  }

  static Future<void> registrarUsuario({
    required BuildContext context,
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El correo ya está registrado')),
        );
        return;
      }

      await firestore.collection('users').add({
        'email': email,
        'username': username,
        'password': password,
        'role': role,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error al registrarse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar')),
      );
    }
  }
}
