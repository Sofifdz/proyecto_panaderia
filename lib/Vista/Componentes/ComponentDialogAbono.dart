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

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 12,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.purple.shade900, Colors.purple.shade700]
                            : [Colors.purple.shade300, Colors.purple.shade200],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          modoEntrega ? 'Entregar pedido' : 'Registrar abono',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                          activeColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Text(
                              "\$${pedido.precio.toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pagado",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Text(
                              "\$${pedido.abonos.toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Restante",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: isDark ? Colors.orange[200] : Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${(pedido.precio - pedido.abonos).toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.orange[200] : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (!pedido.isLiquidado &&
                            (!modoEntrega || (modoEntrega && !pedido.isLiquidado)))
                          TextField(
                            controller: cantidadController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: modoEntrega
                                  ? 'Cantidad a pagar'
                                  : 'Cantidad a abonar',
                              labelStyle: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54),
                              filled: true,
                              fillColor:
                                  isDark ? const Color(0xFF3A3A3C) : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(height: 20),
                 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [Colors.purple.shade900, Colors.purple.shade700]
                                    : [Colors.purple.shade300, Colors.purple.shade200],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: modoEntrega
                                  ? (pedido.isEntregado
                                      ? null
                                      : () async {
                                     
                                          double nuevoAbono = pedido.abonos;

                                          if (cantidadIngresada > 0) {
                                            nuevoAbono += cantidadIngresada;

                                            final cajaQuery = await FirebaseFirestore
                                                .instance
                                                .collection('cajas')
                                                .where('usuarioId', isEqualTo: usuarioId)
                                                .where('estado', isEqualTo: 'abierta')
                                                .limit(1)
                                                .get();

                                            if (cajaQuery.docs.isNotEmpty) {
                                              final cajaId = cajaQuery.docs.first.id;

                                              final ventaData = {
                                                'cliente': pedido.cliente,
                                                'total': cantidadIngresada,
                                                'fecha': Timestamp.now(),
                                                'usuarioId': usuarioId,
                                                'pedidoId': pedido.NoPedido,
                                                'desdePedido': true,
                                                'descripcion': pedido.descripcion,
                                                'productos': productos,
                                              };

                                              await FirebaseFirestore.instance
                                                  .collection('ventas')
                                                  .add(ventaData);

                                              await FirebaseFirestore.instance
                                                  .collection('cajas')
                                                  .doc(cajaId)
                                                  .collection('ventas')
                                                  .add(ventaData);
                                            }
                                          }

                                          await FirebaseFirestore.instance
                                              .collection('pedidos')
                                              .doc(pedido.NoPedido)
                                              .update({
                                            'isEntregado': true,
                                            'abonos': nuevoAbono,
                                            'isLiquidado': nuevoAbono >= pedido.precio,
                                          });

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text("Pedido entregado correctamente"),
                                            ),
                                          );
                                        })
                                  : (cantidadIngresada > 0 && !esLiquidado
                                      ? () async {
                                       
                                          final nuevoAbono =
                                              pedido.abonos + cantidadIngresada;
                                          final nuevoEsLiquidado =
                                              nuevoAbono >= pedido.precio;

                                          await FirebaseFirestore.instance
                                              .collection('pedidos')
                                              .doc(pedido.NoPedido)
                                              .update({
                                            'abonos': nuevoAbono,
                                            'isLiquidado': nuevoEsLiquidado,
                                          });

                                          final cajaQuery = await FirebaseFirestore.instance
                                              .collection('cajas')
                                              .where('usuarioId', isEqualTo: usuarioId)
                                              .where('estado', isEqualTo: 'abierta')
                                              .limit(1)
                                              .get();

                                          if (cajaQuery.docs.isNotEmpty) {
                                            final cajaId = cajaQuery.docs.first.id;

                                            final ventaData = {
                                              'cliente': pedido.cliente,
                                              'total': cantidadIngresada,
                                              'fecha': Timestamp.now(),
                                              'usuarioId': usuarioId,
                                              'pedidoId': pedido.NoPedido,
                                              'desdePedido': true,
                                              'descripcion': pedido.descripcion,
                                              'productos': productos,
                                            };

                                            await FirebaseFirestore.instance
                                                .collection('ventas')
                                                .add(ventaData);

                                            await FirebaseFirestore.instance
                                                .collection('cajas')
                                                .doc(cajaId)
                                                .collection('ventas')
                                                .add(ventaData);
                                          }

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(nuevoEsLiquidado
                                                  ? "Pedido liquidado correctamente"
                                                  : "Abono registrado correctamente"),
                                            ),
                                          );
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
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
