import 'package:cloud_firestore/cloud_firestore.dart';

class Pedidos {
  String NoPedido; 
  String cliente;
  String descripcion;
  int precio;
  String fecha;
  bool isEntregado;

  Pedidos({
    required this.NoPedido,
    required this.cliente,
    required this.descripcion,
    required this.precio,
    required this.fecha,
    this.isEntregado = false, 
  });

  factory Pedidos.fromFirestore(DocumentSnapshot doc)
  {
    Map<String, dynamic> data = doc.data() as Map<String,dynamic>;
    return Pedidos(
      NoPedido: doc.id,
      cliente: data['cliente'] ?? '', 
      descripcion: data['descripcion'] ?? '',
      precio:(data['precio'] ?? 0).toInt(),
      fecha: data['fecha'] ?? '',
      isEntregado: data['isEntregado'] ?? false,
    );
  }

  Map <String, dynamic> toFirestore()
  {
    return{
      'cliente':cliente,
      'descripcion': descripcion,
      'precio':precio,
      'fecha': fecha,
      'isEntregado': isEntregado,
    };
  }
}