import 'package:cloud_firestore/cloud_firestore.dart';

class Ventas {
  final int IDventa;
  final List<dynamic> productos;
  final double total;
  final String fecha;
  final String usuarioId;
  final String IDcaja;
  final bool desdePedido;
  final String? pedidoId;
  final String? cliente;
  final String? descripcion;
  final bool eliminada; // <-- Nuevo campo

  Ventas({
    required this.IDventa,
    required this.productos,
    required this.total,
    required this.fecha,
    required this.usuarioId,
    required this.IDcaja,
    this.desdePedido = false,
    this.pedidoId,
    this.cliente,
    this.descripcion,
    this.eliminada = false, // <-- Valor por defecto
  });

  factory Ventas.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ventas.fromFirestoreData(data);
  }

  factory Ventas.fromFirestoreData(Map<String, dynamic> data) {
    String fechaIso = '';
    final fechaData = data['fecha'];

    if (fechaData is Timestamp) {
      fechaIso = fechaData.toDate().toIso8601String();
    } else if (fechaData is String) {
      fechaIso = fechaData;
    } else {
      fechaIso = DateTime.now().toIso8601String();
    }

    return Ventas(
      IDventa: data['ventaId'] ?? 0,
      productos: data['productos'] ?? [],
      total: (data['total'] ?? 0).toDouble(),
      fecha: fechaIso,
      usuarioId: data['usuarioId'] ?? '',
      IDcaja: data['IDcaja'] ?? '',
      desdePedido: data['desdePedido'] ?? false,
      pedidoId: data['pedidoId'],
      cliente: data['cliente'],
      descripcion: data['descripcion'],
      eliminada: data['eliminada'] ?? false, // <-- Leer el campo
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ventaId': IDventa,
      'productos': productos,
      'total': total,
      'fecha': fecha,
      'usuarioId': usuarioId,
      'IDcaja': IDcaja,
      'desdePedido': desdePedido,
      'pedidoId': pedidoId,
      'cliente': cliente,
      'descripcion': descripcion,
      'eliminada': eliminada, // <-- Guardar el campo
    };
  }
}
