import 'package:proyecto_panaderia/Modelo/Productos.dart';

class ProductoConCantidad {
  final Productos producto;
  int cantidad;

  ProductoConCantidad({required this.producto, this.cantidad = 1});
}
