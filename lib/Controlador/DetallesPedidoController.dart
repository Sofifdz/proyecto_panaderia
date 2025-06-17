import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetallesPedidoController {
  Future<void> entregarPedido({
    required BuildContext context,
    required String pedidoId,
  }) async {
    final pedidoDoc = await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(pedidoId)
        .get();

    final pedidoData = pedidoDoc.data() as Map<String, dynamic>;

    final cajaAbierta = await FirebaseFirestore.instance
        .collection('cajas')
        .where('estado', isEqualTo: 'abierta')
        .limit(1)
        .get();

    if (cajaAbierta.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay una caja abierta")),
      );
      return;
    }

    final cajaData = cajaAbierta.docs.first.data();
    final usuarioId = cajaData['usuarioId'];
    final IDcaja = cajaAbierta.docs.first.id;

    final productos = [
      {
        'nombre': pedidoData['descripcion'],
        'cantidad': 1,
        'precio': pedidoData['precio'],
      }
    ];

    await FirebaseFirestore.instance.collection('ventas').add({
      'usuarioId': usuarioId,
      'ventaId': DateTime.now().millisecondsSinceEpoch,
      'productos': productos,
      'total': pedidoData['precio'],
      'fecha': Timestamp.now(),
      'IDcaja': IDcaja,
      'desdePedido': true,
      'pedidoId': pedidoId,
      'cliente': pedidoData['cliente'],
      'descripcion': pedidoData['descripcion'],
    });

    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(pedidoId)
        .update({'isEntregado': true});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pedido entregado y venta registrada")),
    );

    Navigator.pop(context);
  }
}
