import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Modelo/ProductoCantidad.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';

class VentasController {
  final String usuarioId;
  final BuildContext context;
  final VoidCallback refresh;

  TextEditingController codigoController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<ProductoConCantidad> productosEscaneados = [];

  VentasController({
    required this.usuarioId,
    required this.context,
    required this.refresh,
  });

  void limpiarVenta() {
    productosEscaneados.clear();
    codigoController.clear();
  }

  double calcularTotal() {
    return productosEscaneados.fold(
      0,
      (total, pc) => total + (pc.producto.precio.toDouble() * pc.cantidad),
    );
  }

  Future<void> guardarVenta() async {
    if (usuarioId.isEmpty) {
      _mostrarMensaje('UsuarioId vacío.');
      return;
    }
    if (productosEscaneados.isEmpty) {
      _mostrarMensaje('No hay productos para registrar la venta.');
      return;
    }

    print('Guardando venta...');
    print('ProductosEscaneados:');
    for (var pc in productosEscaneados) {
      print(
          ' - ${pc.producto.productoname} x${pc.cantidad} a \$${pc.producto.precio}');
    }
    print('Total: ${calcularTotal()}');

    final cajasSnapshot = await FirebaseFirestore.instance
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajasSnapshot.docs.isEmpty) {
      _mostrarMensaje('No hay caja abierta para registrar ventas.');
      return;
    }

    final IDcaja = cajasSnapshot.docs.first.id;

   
    final ventasSnapshot = await FirebaseFirestore.instance
        .collection('cajas')
        .doc(IDcaja)
        .collection('ventas')
        .get();
    final IDventa = ventasSnapshot.docs.length + 1;

    final productosMapeados = productosEscaneados.map((pc) {
      return {
        'id': pc.producto.id,
        'nombre': pc.producto.productoname,
        'precio': pc.producto.precio,
        'cantidad': pc.cantidad,
      };
    }).toList();

    final venta = {
      'usuarioId': usuarioId,
      'ventaId': IDventa,
      'productos': productosMapeados,
      'total': calcularTotal(),
      'fecha': Timestamp.now(),
      'IDventa': IDventa,
      'IDcaja': IDcaja,
    };

    try {
      await FirebaseFirestore.instance
          .collection('cajas')
          .doc(IDcaja)
          .collection('ventas')
          .add(venta);

      final batch = FirebaseFirestore.instance.batch();
      for (var pc in productosEscaneados) {
        final docRef = FirebaseFirestore.instance
            .collection('productos')
            .doc(pc.producto.id);

        final doc = await docRef.get();
        if (doc.exists) {
          final currentStock =
              (doc.data() as Map<String, dynamic>)['existencias'] ?? 0;
          final newStock = currentStock - pc.cantidad;

          if (newStock < 0) {
            _mostrarMensaje(
                'No hay suficientes existencias de ${pc.producto.productoname}');
            continue;
          }

          batch.update(docRef, {'existencias': newStock});
        }
      }

      await batch.commit();

      _mostrarMensaje('Venta registrada con éxito');
      productosEscaneados.clear();
      refresh();
    } catch (e) {
      _mostrarMensaje('Error al registrar la venta: $e');
    }
  }

  Future<void> buscarProducto(String input) async {
    if (input.isEmpty) return;

    final regex = RegExp(r'^(.+?)(\*(\d+))?$');
    final match = regex.firstMatch(input);

    if (match == null) {
      _mostrarMensaje('Formato de código inválido');
      return;
    }

    String codigo = match.group(1)!;
    int cantidad = int.tryParse(match.group(3) ?? '1') ?? 1;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('productos')
        .doc(codigo)
        .get();

    if (doc.exists) {
      Productos producto = Productos.fromFirestore(doc);
      int index =
          productosEscaneados.indexWhere((p) => p.producto.id == producto.id);

      if (index == -1) {
        productosEscaneados
            .add(ProductoConCantidad(producto: producto, cantidad: cantidad));
      } else {
        productosEscaneados[index].cantidad += cantidad;
      }
      refresh();
    } else {
      _mostrarMensaje('Producto no encontrado');
    }

    codigoController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }

  void agregarProductoDesdeCard(String nombre, double precio, int cantidad) {
    int index = productosEscaneados
        .indexWhere((p) => p.producto.productoname == nombre);
    if (index == -1) {
      productosEscaneados.add(
        ProductoConCantidad(
          producto: Productos(
              id: 'id_generado',
              productoname: nombre,
              precio: precio.toInt(),
              existencias: 0),
          cantidad: cantidad,
        ),
      );
    } else {
      productosEscaneados[index].cantidad += cantidad;
    }
    codigoController.clear();
    FocusScope.of(context).requestFocus(focusNode);
    refresh();
  }

  void eliminarProductoDesdeCard(String nombre) {
    int index = productosEscaneados
        .indexWhere((pc) => pc.producto.productoname == nombre);
    if (index != -1) {
      if (productosEscaneados[index].cantidad > 1) {
        productosEscaneados[index].cantidad--;
      } else {
        productosEscaneados.removeAt(index);
      }
    }
    refresh();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
