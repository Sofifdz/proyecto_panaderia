import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';


class AlmacenController {
  Future<List<Productos>> cargarProductos() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('productos').get();
    return querySnapshot.docs.map((doc) => Productos.fromFirestore(doc)).toList();
  }

  Stream<List<Productos>> obtenerProductosStream() {
    return FirebaseFirestore.instance.collection('productos').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Productos.fromFirestore(doc)).toList());
  }

  Future<void> actualizarProducto(Productos producto) async {
    await FirebaseFirestore.instance
        .collection('productos')
        .doc(producto.id)
        .update(producto.toFirestore());
  }

  Future<void> eliminarProducto(String id) async {
    await FirebaseFirestore.instance.collection('productos').doc(id).delete();
  }

  static Future<void> registrarProducto({
    required String id,
    required String nombre,
    required int existencias,
    required int precio,
  }) async {
    await FirebaseFirestore.instance.collection('productos').doc(id).set({
      'id': id,
      'productoname': nombre,
      'existencias': existencias,
      'precio': precio,
    });
  }
}
