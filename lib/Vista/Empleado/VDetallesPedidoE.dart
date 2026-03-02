import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DetallesPedidoController.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ComponentDialogAbono.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VPedidosE.dart';

class VDetallesPedidoE extends StatefulWidget {
  final String pedidoId;
  final String usuarioId;
  final String username;

  const VDetallesPedidoE({
    super.key,
    required this.pedidoId,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VDetallesPedidoE> createState() => _VDetallesPedidoEState();
}

class _VDetallesPedidoEState extends State<VDetallesPedidoE> {
  @override
  Widget build(BuildContext context) {
    final controlador = DetallesPedidoController();
    const backgroundColor = Color(0xFFF4F6F8);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF1F2933),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detalle de Pedido',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pedidos')
              .doc(widget.pedidoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.data!.exists) {
              return const Center(
                child: Text("Pedido no encontrado",
                    style: TextStyle(fontSize: 18)),
              );
            }

            final pedido = Pedidos.fromFirestore(snapshot.data!);
            final bool estaLiquidado = pedido.abonos >= pedido.precio;

            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pedido.cliente,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: mainText,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Teléfono:",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Colors.grey[600])),
                                    Text(pedido.telefono,
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: mainText)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Fecha de entrega:",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Colors.grey[600])),
                                    Text(pedido.fecha,
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: mainText)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    pedido.descripcion,
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: mainText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                       
                        Column(
                          children: [
                            Divider(color: Colors.grey[300], thickness: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total:",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: mainText)),
                                Text("\$${pedido.precio.toStringAsFixed(2)}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Abonado:",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16, color: Colors.grey[700])),
                                Text("\$${pedido.abonos.toStringAsFixed(2)}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Restante:",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16, color: Colors.grey[700])),
                                Text(
                                    "\$${(pedido.precio - pedido.abonos).clamp(0, double.infinity).toStringAsFixed(2)}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                    
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ComponentDialogAbono(widget.pedidoId, context,
                                  pedido, widget.usuarioId);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: primaryBlue,
                            ),
                            child: Text(
                              pedido.isEntregado
                                  ? 'Abonar'
                                  : estaLiquidado
                                      ? 'Entregar pedido'
                                      : 'Abonar',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
