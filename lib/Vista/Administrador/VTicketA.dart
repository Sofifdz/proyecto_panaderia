import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';

class VTicketA extends StatelessWidget {
  final Ventas venta;

  const VTicketA({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime fechaDt;
    try {
      fechaDt = DateTime.parse(venta.fecha);
    } catch (_) {
      fechaDt = DateTime.now();
    }
    final fechaFormateada = DateFormat('dd/MM/yyyy hh:mm a').format(fechaDt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : const Color.fromARGB(146, 225, 225, 225),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  venta.desdePedido == true
                      ? 'Pedido #${venta.pedidoId ?? ''}'
                      : 'Venta #${venta.IDventa}',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Fecha: $fechaFormateada',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Detalles',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: venta.productos.length,
                  itemBuilder: (context, index) {
                    final producto = venta.productos[index] as Map<String, dynamic>;
                    final nombre = producto['nombre'] ?? 'Producto';
                    final cantidad = producto['cantidad'] ?? 1;
                    final precio = (producto['precio'] ?? 0).toDouble();
                    final subtotal = cantidad * precio;
                    final descripcion = venta.descripcion ?? '';
                    final cliente = venta.cliente ?? '';

                    if (venta.desdePedido == true && index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliente: $cliente',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              )),
                          const SizedBox(height: 8),
                          Text('Descripción: $descripcion',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              )),
                          const SizedBox(height: 16),
                          Divider(color: isDark ? Colors.white24 : Colors.black26),
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.white10 : Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                nombre,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'x$cantidad',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.greenAccent : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                thickness: 1.5,
                color: isDark ? Colors.white38 : Colors.black,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '\$${venta.total.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
