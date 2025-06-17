import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';

class VTicket extends StatelessWidget {
  final Ventas venta;

  const VTicket({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color.fromARGB(255, 81, 81, 81),
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
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2E) 
                : const Color.fromARGB(146, 225, 225, 225),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                    child: venta.desdePedido == true
                        ? Text(
                            'Pedido #${venta.pedidoId}',
                            style: GoogleFonts.roboto(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          )
                        : Text(
                            'Venta #${venta.IDventa}',
                            style: GoogleFonts.roboto(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Fecha: ${venta.fecha}',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Productos',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: venta.productos.length,
                    itemBuilder: (context, index) {
                      final producto = venta.productos[index];
                      final nombre = producto['productoname'] ?? 'Producto';
                      final cantidad = producto['cantidad'] ?? 1;
                      final precio = (producto['precio'] ?? 0).toDouble();
                      final subtotal = cantidad * precio;
                      final descripcion = venta.descripcion.toString();
                      final cliente = venta.cliente.toString();

                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: venta.desdePedido == true
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                        'Descripción del pedido:\n\n$descripcion',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                    const SizedBox(width: 8),
                                    Text('Cliente: \n\n$cliente',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                    const SizedBox(width: 8),
                                    Text('\$${subtotal.toStringAsFixed(2)}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(nombre,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                    Text('Cantidad: $cantidad',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                    const SizedBox(width: 8),
                                    Text('\$${subtotal.toStringAsFixed(2)}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[600],
                                        )),
                                  ],
                                ));
                    },
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB0B0B0)
                      : Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Text(
                      '\$${venta.total.toStringAsFixed(2)}',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
