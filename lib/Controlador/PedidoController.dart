import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoController {
  Future<void> registrarPedido({
    required String cliente,
    required String descripcion,
    required int precio,
    required DateTime fecha,
  }) async {
    final contadorRef =
        FirebaseFirestore.instance.collection('contadores').doc('pedidos');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(contadorRef);
      int nuevoId = 1;

      if (snapshot.exists) {
        nuevoId = snapshot.get('ultimoId') + 1;
      }

    
      transaction.set(contadorRef, {'ultimoId': nuevoId});


      final pedidoRef = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(nuevoId.toString());

      transaction.set(pedidoRef, {
        'id': nuevoId.toString(),
        'cliente': cliente,
        'descripcion': descripcion,
        'precio': precio,
        'fecha': BoardDateFormat('dd/MM/yyyy HH:mm').format(fecha),
        'isEntregado': false,
      });
    });
  }

  Future<void> guardarPedido({
    required BuildContext context,
    required String cliente,
    required String descripcion,
    required String precio,
    required DateTime fecha,
  }) async {
    try {
      await registrarPedido(
        cliente: cliente,
        descripcion: descripcion,
        precio: int.parse(precio),
        fecha: fecha,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido registrado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al registrar pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
