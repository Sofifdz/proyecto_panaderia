import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_panaderia/Modelo/Pagos.dart';

class PagoController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> guardarPago({
    required String usuarioId,
    required String nombre,
    required String descripcion,
    required double monto,
    required DateTime fecha,
  }) async {
    if (usuarioId.isEmpty) {
      throw Exception('UsuarioId vacío.');
    }
    if (monto <= 0) {
      throw Exception('Monto inválido.');
    }

    final cajasSnapshot = await FirebaseFirestore.instance
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajasSnapshot.docs.isEmpty) {
      throw Exception('No hay caja abierta para registrar pagos.');
    }

    final cajaId = cajasSnapshot.docs.first.id;

    final pago = {
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
    };

    await FirebaseFirestore.instance
        .collection('cajas')
        .doc(cajaId)
        .collection('pagos')
        .add(pago);
  }

  Stream<List<Pagos>> obtenerPagos(String cajaId) {
    return firestore
        .collection('cajas')
        .doc(cajaId)
        .collection('pagos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => Pagos.fromFirestore(doc)).toList());
  }
}
