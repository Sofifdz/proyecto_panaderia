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

  const backgroundColor = Color(0xFFF4F6F8);
  const appBarColor = Color(0xFF1F2933);
  const primaryBlue = Color(0xFF2563EB);
  const mainText = Color(0xFF111827);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        final double totalPagado = pedido.abonos + cantidadIngresada;
        final bool esLiquidado = pedido.abonos >= pedido.precio;

        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
           
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: appBarColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
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
                    
                      Row(
                        children: [
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
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

               
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Text(
                        "Cliente: ${pedido.cliente}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Total: \$${pedido.precio.toStringAsFixed(2)}\n"
                        "Pagado: \$${pedido.abonos.toStringAsFixed(2)}\n"
                        "Restante: \$${(pedido.precio - pedido.abonos).toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!pedido.isLiquidado)
                        TextField(
                          controller: cantidadController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: mainText,
                          ),
                          decoration: InputDecoration(
                            hintText: "0.00",
                            labelText:
                                modoEntrega ? "Cantidad a pagar" : "Cantidad a abonar",
                            labelStyle: GoogleFonts.roboto(color: Colors.grey),
                            filled: true,
                            fillColor: backgroundColor,
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

                      const SizedBox(height: 25),

                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        
                          onPressed: (modoEntrega && pedido.isEntregado)
                              ? null
                              : (cantidadIngresada > 0 || modoEntrega)
                                  ? () async {
                                      double nuevoAbono = pedido.abonos;

                                      if (modoEntrega) {
                                        nuevoAbono += cantidadIngresada;

                                        final cajaQuery =
                                            await FirebaseFirestore.instance
                                                .collection('cajas')
                                                .where('usuarioId',
                                                    isEqualTo: usuarioId)
                                                .where('estado',
                                                    isEqualTo: 'abierta')
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

                                        await FirebaseFirestore.instance
                                            .collection('pedidos')
                                            .doc(pedido.NoPedido)
                                            .update({
                                          'isEntregado': true,
                                          'abonos': nuevoAbono,
                                          'isLiquidado':
                                              nuevoAbono >= pedido.precio,
                                        });

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Pedido entregado correctamente"),
                                          ),
                                        );
                                      } else {
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

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(nuevoEsLiquidado
                                                ? "Pedido liquidado correctamente"
                                                : "Abono registrado correctamente"),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                          child: Text(
                            modoEntrega
                                ? (pedido.isEntregado ? 'Entregado' : 'Entregar')
                                : 'Abonar',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}