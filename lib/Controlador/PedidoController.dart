import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';

class PedidoController {

  Future<void> registrarPedido({
    required String cliente,
    required String telefono,
    required String descripcion,
    required double precio,
    required double abono,
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

      bool isLiquidado = abono >= precio;

      transaction.set(pedidoRef, {
        'id': nuevoId.toString(),
        'cliente': cliente,
        'telefono': telefono,
        'descripcion': descripcion,
        'precio': precio,
        'abonos': abono,
        'fecha': BoardDateFormat('dd/MM/yyyy HH:mm').format(fecha),
        'isEntregado': false,
        'isLiquidado': isLiquidado,
      });
    });
  }

  Future<void> guardarPedido({
    required BuildContext context,
    required String cliente,
    required String telefono,
    required String descripcion,
    required String precio,
    required double abono,
    required DateTime fecha,
  }) async {

    try {

      double precioDouble = double.parse(precio);

      await registrarPedido(
        cliente: cliente,
        telefono: telefono,
        descripcion: descripcion,
        precio: precioDouble,
        abono: abono,
        fecha: fecha,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido registrado con éxito')),
      );

      Navigator.pop(context);

    } catch (e) {

      print('Error al registrar pedido: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget estadoPedidoWidget(Pedidos pedido, BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textoColor =
        isDark ? const Color(0xFFB0B0B0) : Colors.grey[800]!;

    String texto = "";

    if ((pedido.abonos < pedido.precio) && !pedido.isEntregado) {
      texto =
          "Pendiente de pago: \$${(pedido.precio - pedido.abonos).toStringAsFixed(2)}";

    } else if ((pedido.abonos >= pedido.precio) && !pedido.isEntregado) {
      texto = "Pagado";

    } else if ((pedido.abonos < pedido.precio) && pedido.isEntregado) {
      texto =
          "Entregado con adeudo:\n\$${(pedido.precio - pedido.abonos).toStringAsFixed(2)}";

    } else if ((pedido.abonos >= pedido.precio) && pedido.isEntregado) {
      texto = "Pedido liquidado \ny entregado";
    }

    return Text(
      texto,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: textoColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}