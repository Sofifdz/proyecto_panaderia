import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Modelo/ProductoCantidad.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';

class VentasController {
  static final VentasController _instance = VentasController._internal();

  factory VentasController({
    required String usuarioId,
    required BuildContext context,
    required VoidCallback refresh,
  }) {
    _instance.usuarioId = usuarioId;
    _instance.context = context;
    _instance.refresh = refresh;
    return _instance;
  }

  VentasController._internal();

  late String usuarioId;
  late BuildContext context;
  late VoidCallback refresh;

  final TextEditingController codigoController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final List<ProductoConCantidad> productosEscaneados = [];

  String tipoVenta = 'almacen';

  bool _ventaConfirmada = false;

  void limpiarVenta() {
    if (!_ventaConfirmada) return;

    productosEscaneados.clear();
    codigoController.clear();
    tipoVenta = 'almacen';
    _ventaConfirmada = false;
  }

  double calcularTotal() {
    return productosEscaneados.fold(
      0,
      (total, pc) => total + (pc.producto.precio.toDouble() * pc.cantidad),
    );
  }

  Future<void> guardarVenta() async {
    if (usuarioId.isEmpty || productosEscaneados.isEmpty) {
      _mostrarMensaje('No hay productos para registrar la venta.');
      return;
    }

    final cajasSnapshot = await FirebaseFirestore.instance
        .collection('cajas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajasSnapshot.docs.isEmpty) {
      _mostrarMensaje('No hay caja abierta.');
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
      'IDcaja': IDcaja,
      'tipoVenta': tipoVenta,
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
        if (!doc.exists) continue;

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

      await batch.commit();

      _mostrarMensaje('Venta registrada con éxito');

      _ventaConfirmada = true; // ✅ solo aquí
      limpiarVenta();
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

    if (!doc.exists) {
      _mostrarMensaje('Producto no encontrado');
      codigoController.clear();
      return;
    }

    Productos producto = Productos.fromFirestore(doc);

    if (producto.existencias <= 0) {
      _mostrarMensaje('No hay existencias de ${producto.productoname}');
      codigoController.clear();
      return;
    }

    int index =
        productosEscaneados.indexWhere((p) => p.producto.id == producto.id);

    if (index == -1) {
      if (cantidad > producto.existencias) {
        _mostrarMensaje(
            'Solo hay ${producto.existencias} de ${producto.productoname}');
        codigoController.clear();
        return;
      }

      productosEscaneados.add(
        ProductoConCantidad(producto: producto, cantidad: cantidad),
      );
    } else {
      int nuevaCantidad = productosEscaneados[index].cantidad + cantidad;

      if (nuevaCantidad > producto.existencias) {
        _mostrarMensaje('Stock insuficiente de ${producto.productoname}');
        codigoController.clear();
        return;
      }

      productosEscaneados[index].cantidad = nuevaCantidad;
    }

    refresh();
    codigoController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }

  void agregarProductoDesdeCard(
      String productoId, double precio, int cantidad) async {
    tipoVenta = 'pan';

    final doc = await FirebaseFirestore.instance
        .collection('productos')
        .doc(productoId)
        .get();

    if (!doc.exists) return;

    final producto = Productos.fromFirestore(doc);

    final index =
        productosEscaneados.indexWhere((p) => p.producto.id == producto.id);

    if (index == -1) {
      productosEscaneados.add(
        ProductoConCantidad(producto: producto, cantidad: cantidad),
      );
    } else {
      productosEscaneados[index].cantidad += cantidad;
    }
    refresh();
  }

  void agregarProductoCompletoDesdeDialogo(Productos producto, int cantidad) {
    tipoVenta = 'almacén';

    if (producto.existencias <= 0) {
      _mostrarMensaje('No hay existencias de ${producto.productoname}');
      return;
    }

    final index =
        productosEscaneados.indexWhere((p) => p.producto.id == producto.id);

    if (index == -1) {
      productosEscaneados.add(
        ProductoConCantidad(producto: producto, cantidad: cantidad),
      );
    } else {
      productosEscaneados[index].cantidad += cantidad;
    }

    refresh();
  }

  void eliminarProductoDesdeCard(String productoId) {
    final index =
        productosEscaneados.indexWhere((pc) => pc.producto.id == productoId);

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

  void sumarUno(String productoId) {
    final index =
        productosEscaneados.indexWhere((p) => p.producto.id == productoId);

    if (index != -1) {
      productosEscaneados[index].cantidad++;
      refresh();
    }
  }

  void restarUno(String productoId) {
    final index =
        productosEscaneados.indexWhere((p) => p.producto.id == productoId);

    if (index != -1) {
      if (productosEscaneados[index].cantidad > 1) {
        productosEscaneados[index].cantidad--;
      } else {
        productosEscaneados.removeAt(index);
      }
      refresh();
    }
  }
}
