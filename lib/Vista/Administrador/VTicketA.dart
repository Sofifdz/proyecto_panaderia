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
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.green.shade900, Colors.green.shade700]
                  : [Colors.green.shade400, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          venta.desdePedido == true
              ? 'Pedido #${venta.pedidoId ?? ''}'
              : 'Venta #${venta.IDventa}',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Fecha: $fechaFormateada',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Cliente y descripción ---
              if (venta.desdePedido == true) ...[
                Text('Cliente: ${venta.cliente ?? '---'}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    )),
                const SizedBox(height: 6),
                Text('Descripción: ${venta.descripcion ?? '---'}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    )),
                const SizedBox(height: 16),
              ],

              Text(
                'Detalles de productos',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

           
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, __) => Divider(
                    color: isDark ? Colors.white24 : Colors.black26,
                    thickness: 1,
                  ),
                  itemCount: venta.productos.length,
                  itemBuilder: (context, index) {
                    final producto =
                        venta.productos[index] as Map<String, dynamic>;
                    final nombre = producto['nombre'] ?? 'Producto';
                    final cantidad = producto['cantidad'] ?? 1;
                    final precio = (producto['precio'] ?? 0).toDouble();
                    final subtotal = cantidad * precio;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
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
                                color:
                                    isDark ? Colors.greenAccent : Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Divider(
                thickness: 1.5,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
              const SizedBox(height: 12),

              // --- Total ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${venta.total.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
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
