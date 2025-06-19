import 'package:cloud_firestore/cloud_firestore.dart';

class Pagos {
  String id;
  String nombre;
  String descripcion;
  double monto;
  final String fecha;
  final String IDcaja;

  Pagos({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.monto,
    required this.IDcaja,
    required this.fecha,
  });

  factory Pagos.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String fechaIso = '';
    final fechaData = data['fecha'];
    if (fechaData is Timestamp) {
      fechaIso = fechaData.toDate().toIso8601String();
    } else if (fechaData is String) {
      fechaIso = fechaData;
    } else {
      fechaIso = DateTime.now().toIso8601String();
    }

    return Pagos(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      monto: (data['monto'] ?? 0).toDouble(),
      IDcaja: data['IDcaja'] ?? '',
      fecha: fechaIso,
    );
  }
}
