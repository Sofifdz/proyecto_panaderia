import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';

class VTicket extends StatelessWidget {
  final Ventas venta;

  const VTicket({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color primaryColor =
        isDark ? Colors.purple.shade700 : Colors.purple.shade200;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
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
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          venta.desdePedido == true
              ? 'Pedido #${venta.pedidoId}'
              : 'Venta #${venta.IDventa}',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cliente y descripción si es pedido
              if (venta.desdePedido) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Fecha: ${venta.fecha}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: primaryColor.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  shadowColor: primaryColor.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: primaryColor, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Cliente: ${venta.cliente}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.note_alt, color: primaryColor, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Descripción: ${venta.descripcion}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 20),
              Text(
                'Productos',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

             
              Expanded(
                child: ListView.builder(
                  itemCount: venta.productos.length,
                  itemBuilder: (context, index) {
                    final producto = venta.productos[index];
                    final nombre = producto['nombre'] ?? 'Producto';
                    final cantidad = producto['cantidad'] ?? 1;
                    final precio = (producto['precio'] ?? 0).toDouble();
                    final subtotal = cantidad * precio;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: primaryColor.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  nombre,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.black87,
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
                                    color: Colors.grey[700],
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
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

              // Total
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.7), primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '\$${venta.total.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Etiqueta ABONO si es pedido
              if (venta.desdePedido)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ABONO',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
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
    );
  }
}
