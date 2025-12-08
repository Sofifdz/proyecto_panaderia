import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';

class ComponentCardProducto extends StatelessWidget {
  final Productos producto;
  final VoidCallback onTap;
  final Future<bool?> Function() onConfirmDismiss;
  final Color Function(int existencia) obtenerColor;

  const ComponentCardProducto({
    super.key,
    required this.producto,
    required this.onTap,
    required this.onConfirmDismiss,
    required this.obtenerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(producto.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDismiss(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: obtenerColor(producto.existencias ?? 0),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColumn('Producto', producto.productoname),
                _buildColumn('Existencias', producto.existencias.toString()),
                _buildColumn('Precio', '\$${producto.precio}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String title, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 22, color: const Color(0xFF515151))),
          Text(value,
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF515151))),
        ],
      ),
    );
  }
}
