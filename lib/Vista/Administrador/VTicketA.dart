import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';

class VTicketA extends StatelessWidget {
  final Ventas venta;

  const VTicketA({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
   
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const mainText = Color(0xFF111827);
    const subtleText = Color(0xFF6B7280);
    const accentGreen = Color(0xFF16A34A);

   
    DateTime fecha;
    try {
      fecha = DateTime.parse(venta.fecha);
    } catch (_) {
      fecha = DateTime.now();
    }
    final fechaFormateada = DateFormat('dd/MM/yyyy hh:mm a').format(fecha);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
         toolbarHeight: 80,
        elevation: 0,
        centerTitle: true,
        title: Text(
          venta.desdePedido == true
              ? 'Pedido #${venta.pedidoId ?? ''}'
              : 'Venta #${venta.IDventa}',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "PANADERÍA",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fechaFormateada,
                    style: GoogleFonts.roboto(
                      color: subtleText,
                    ),
                  ),
                  if (venta.desdePedido) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Cliente: ${venta.cliente ?? '---'}",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Descripción: ${venta.descripcion ?? '---'}",
                      style: GoogleFonts.roboto(
                        color: subtleText,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

          
            Row(
              children: List.generate(
                40,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index.isEven ? Colors.grey.shade300 : Colors.transparent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

           
            Expanded(
              child: ListView.builder(
                itemCount: venta.productos.length,
                itemBuilder: (context, index) {
                  final producto = venta.productos[index] as Map<String, dynamic>;
                  final nombre = producto['nombre'] ?? 'Producto';
                  final cantidad = producto['cantidad'] ?? 1;
                  final precio = (producto['precio'] ?? 0).toDouble();
                  final subtotal = cantidad * precio;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                nombre,
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "x$cantidad",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  color: subtleText,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "\$${subtotal.toStringAsFixed(2)}",
                                textAlign: TextAlign.end,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  color: accentGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Divider(
                          thickness: 0.5,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

           
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Column(
                children: [
                  _resumenRow("Subtotal", "\$${venta.total.toStringAsFixed(2)}"),
                  const SizedBox(height: 10),
                  Divider(),
                  const SizedBox(height: 10),
                  _resumenRow("TOTAL", "\$${venta.total.toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumenRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}