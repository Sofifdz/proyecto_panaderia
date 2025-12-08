import 'package:cloud_firestore/cloud_firestore.dart';

class Caja {
  
  String usuarioId; 
  String fechaApertura;
  String fechaCierre;
  String estado;
  int inicioCaja;
  int cierreCaja;

  Caja({
    required this.usuarioId,
    required this.fechaApertura,
    required this.fechaCierre,
    required this.inicioCaja,
    required this.estado,
    required this.cierreCaja,
  });
  factory Caja.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Caja(
      usuarioId: data['usuarioId'] ?? '',
      fechaApertura: (data['fechaApertura']).toDate(),
      fechaCierre:  (data['fechaCierre']).toDate(),
      inicioCaja:(data['inicioCaja'] ?? 0).toInt(),
      cierreCaja:(data['cierreCaja'] ?? 0).toInt(),
      estado: data['estado'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'fechaApertura': fechaApertura,
      'fechaCierre':fechaCierre,
      'inicioCaja': inicioCaja,
      'cierreCaja': cierreCaja,
      'estado':estado,
    };
  }
}
