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
      existencias: (data['existencias'] ?? 0).toInt(),
      precio: (data['precio'] ?? 0).toInt(),
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

