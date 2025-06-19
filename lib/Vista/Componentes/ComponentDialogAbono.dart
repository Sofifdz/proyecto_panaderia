import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';

Future<void> ComponentDialogAbono(
  String pedidoId,
  BuildContext context,
  Pedidos pedido,
  String usuarioId,
) async {
  final TextEditingController cantidadController = TextEditingController();
  double cantidadIngresada = 0;
  bool modoEntrega = true;

  final pedidoDoc = await FirebaseFirestore.instance
      .collection('pedidos')
      .doc(pedidoId)
      .get();

  final pedidoData = pedidoDoc.data() as Map<String, dynamic>;

  final productos = [
    {
      'nombre': pedidoData['descripcion'],
      'cantidad': 1,
      'precio': pedidoData['precio'],
    }
  ];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final double totalPagado = pedido.abonos + cantidadIngresada;
          final bool esLiquidado = pedido.abonos >= pedido.precio;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor:
                isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F4F8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modoEntrega ? 'Entregar pedido' : 'Registrar abono',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Switch(
                  value: modoEntrega,
                  onChanged: esLiquidado
                      ? null
                      : (val) {
                          setState(() {
                            modoEntrega = val;
                            cantidadController.clear();
                            cantidadIngresada = 0;
                          });
                        },
                  activeColor: Colors.green,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total: \$${pedido.precio.toStringAsFixed(2)}",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "Pagado: \$${pedido.abonos.toStringAsFixed(2)}",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "Restante: \$${(pedido.precio - pedido.abonos).toStringAsFixed(2)}",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.orange[200] : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 12),
                if (!pedido.isLiquidado &&
                    (!modoEntrega || (modoEntrega && !pedido.isLiquidado)))
                  TextField(
                    controller: cantidadController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: modoEntrega
                          ? 'Cantigar a pagar'
                          : 'Cantidad a abonar',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF3A3A3C) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        cantidadIngresada = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: modoEntrega
                      ? (pedido.isEntregado
                          ? Colors.grey
                          : const Color.fromARGB(255, 116, 181, 119))
                      : (cantidadIngresada > 0
                          ? const Color.fromARGB(255, 116, 181, 119)
                          : Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: modoEntrega
                    ? (pedido.isEntregado
                        ? null
                        : () async {
                            double nuevoAbono = pedido.abonos;

                            if (cantidadIngresada > 0) {
                              nuevoAbono += cantidadIngresada;

                              await FirebaseFirestore.instance
                                  .collection('ventas')
                                  .add({
                                'cliente': pedido.cliente,
                                'total': cantidadIngresada,
                                'fecha': Timestamp.now(),
                                'usuarioId': usuarioId,
                                'pedidoId': pedido.NoPedido,
                                'desdePedido': true,
                                'descripcion': pedidoData['descripcion'],
                                'productos': productos,
                              });
                            }

                            bool nuevoEsLiquidado = nuevoAbono >= pedido.precio;

                            await FirebaseFirestore.instance
                                .collection('pedidos')
                                .doc(pedido.NoPedido)
                                .update({
                              'isEntregado': true,
                              'abonos': nuevoAbono,
                              'isLiquidado': nuevoEsLiquidado,
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(nuevoEsLiquidado
                                    ? "Pedido entregado y liquidado"
                                    : "Pedido entregado correctamente"),
                              ),
                            );
                          })
                    : (cantidadIngresada > 0 && !esLiquidado
                        ? () async {
                            final nuevoAbono =
                                pedido.abonos + cantidadIngresada;
                            final bool nuevoEsLiquidado =
                                nuevoAbono >= pedido.precio;

                            await FirebaseFirestore.instance
                                .collection('pedidos')
                                .doc(pedido.NoPedido)
                                .update({
                              'abonos': nuevoAbono,
                              'isLiquidado': nuevoEsLiquidado,
                            });

                            await FirebaseFirestore.instance
                                .collection('ventas')
                                .add({
                              'cliente': pedido.cliente,
                              'total': cantidadIngresada,
                              'fecha': Timestamp.now(),
                              'usuarioId': usuarioId,
                              'pedidoId': pedido.NoPedido,
                              'desdePedido': true,
                              'descripcion': pedidoData['descripcion'],
                              'productos': productos,
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(nuevoEsLiquidado
                                  ? "Pedido liquidado correctamente"
                                  : "Abono registrado correctamente"),
                            ));
                          }
                        : null),
                child: Text(
                  modoEntrega
                      ? (pedido.isEntregado ? 'Entregado' : 'Entregar')
                      : 'Abonar',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
