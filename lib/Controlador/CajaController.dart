import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ShowDialogCaja.dart';
import 'package:proyecto_panaderia/Vista/VLogin.dart';

class CajaController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool> abrirCaja(String usuarioId, double monto) async {
    final cajasAbiertas = await db
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajasAbiertas.docs.isEmpty) {
      await db.collection('cajas').add({
        'usuarioId': usuarioId,
        'fechaApertura': FieldValue.serverTimestamp(),
        'inicioCaja': monto,
        'cierreCaja': null,
        'fechaCierre': null,
        'estado': 'abierta',
      });
      return true;
    } else {
      print("Ya hay una caja abierta.");
      return false;
    }
  }

  Future<bool> cerrarCaja(String usuarioId, double monto) async {
    final cajasAbiertas = await db
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajasAbiertas.docs.isNotEmpty) {
      final cajaId = cajasAbiertas.docs.first.id;

      await db.collection('cajas').doc(cajaId).update({
        'cierreCaja': monto,
        'fechaCierre': FieldValue.serverTimestamp(),
        'estado': 'cerrada',
      });
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> obtenerCajaActual(String usuarioId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .orderBy('fechaApertura', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final apertura = data['fechaApertura'] as Timestamp;
      final cierre = data['fechaCierre'] as Timestamp?;
      final cajaId = snapshot.docs.first.id;

      return {
        'fechaApertura': apertura,
        if (cierre != null) 'fechaCierre': cierre,
        'cajaId': cajaId,
        'inicioCaja': data['inicioCaja'] ?? 0,
      };
    }

    return {};
  }

  static Future<void> corteDeCaja(
      BuildContext context, String usuarioId, String username) async {
    final cajaController = CajaController();

    await ShowDialogCaja.show(
      context: context,
      usuarioId: usuarioId,
      username: username,
      abroOcierro: 'Cierro con',
      txtBoton: 'Cerrar',
      tipoOperacion: "cerrar",
      controller: cajaController,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
}
