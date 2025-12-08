import 'dart:convert';

import 'package:proyecto_panaderia/Modelo/ProductoCantidad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static Future<void> guardarSesion({
    required String userId,
    required String username,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('role', role);
  }


  static Future<String?> obtenerUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

 
  static Future<String?> obtenerUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }


  static Future<String?> obtenerRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }


  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

    static Future<void> guardarProductosEscaneados(List<ProductoConCantidad> productos) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> productosJson = productos.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('productosEscaneados', productosJson);
  }

  static Future<List<ProductoConCantidad>> obtenerProductosEscaneados() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? productosJson = prefs.getStringList('productosEscaneados');

    if (productosJson == null) return [];

    return productosJson
        .map((jsonStr) => ProductoConCantidad.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  static Future<void> limpiarProductosEscaneados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('productosEscaneados');
  }
}
