import 'package:proyecto_panaderia/Modelo/Productos.dart';

class ProductoConCantidad {
  final Productos producto;
  int cantidad;

  ProductoConCantidad({required this.producto, this.cantidad = 1});

  Map<String, dynamic> toJson() => {
        'producto': producto.toJson(),
        'cantidad': cantidad,
      };

  factory ProductoConCantidad.fromJson(Map<String, dynamic> json) {
    return ProductoConCantidad(
      producto: Productos.fromJson(json['producto']),
      cantidad: json['cantidad'],
    );
  }
}
