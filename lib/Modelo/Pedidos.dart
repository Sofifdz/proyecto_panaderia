import 'package:cloud_firestore/cloud_firestore.dart';

class Pedidos {
  String NoPedido;
  String cliente;
  String descripcion;
  int precio;
  String fecha;
  bool isEntregado;
  bool isLiquidado; 
  double abonos;

  Pedidos({
    required this.NoPedido,
    required this.cliente,
    required this.descripcion,
    required this.precio,
    required this.fecha,
    this.abonos = 0,
    this.isEntregado = false,
    this.isLiquidado = false, 
  });

  factory Pedidos.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pedidos(
      NoPedido: doc.id,
      cliente: data['cliente'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toInt(),
      fecha: data['fecha'] ?? '',
      isEntregado: data['isEntregado'] ?? false,
      isLiquidado: data['isLiquidado'] ?? false,
      abonos: (data['abonos'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cliente': cliente,
      'descripcion': descripcion,
      'precio': precio,
      'fecha': fecha,
      'isEntregado': isEntregado,
      'isLiquidado': isLiquidado,
      'abonos': abonos,
    };
  }
}
