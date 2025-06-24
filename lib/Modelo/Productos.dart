import 'package:cloud_firestore/cloud_firestore.dart';

class Productos {
  String id;
  String productoname;
  int existencias;
  int precio;

  Productos({
    required this.id,
    required this.productoname,
    required this.existencias,
    required this.precio,
  });

  factory Productos.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Productos(
      id: doc.id,
      productoname: data['productoname'] ?? '',
      existencias: data['existencias'] is int
          ? data['existencias']
          : int.tryParse(data['existencias'].toString()) ?? 0,
      precio: data['precio'] is int
          ? data['precio']
          : int.tryParse(data['precio'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productoname': productoname,
      'existencias': existencias,
      'precio': precio,
    };
  }
}
