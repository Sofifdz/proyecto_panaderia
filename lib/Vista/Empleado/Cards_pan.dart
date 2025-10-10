import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriaPan {
  String nombre;
  double precio;
  int cantidad;
  Color color;

  CategoriaPan({
    required this.color,
    required this.nombre,
    required this.precio,
    this.cantidad = 0,
  });
}

class CardsPan extends StatefulWidget {
  final Function(String nombre, double precio, int cantidad) onAgregar;
  final Function(String nombre) onEliminar;
  final TextEditingController codigoController;

  const CardsPan({
    super.key,
    required this.onAgregar,
    required this.onEliminar,
    required this.codigoController,
  });

  @override
  State<CardsPan> createState() => CardspanState();
}

class CardspanState extends State<CardsPan> {
  void resetearCantidades() {
    setState(() {
      for (var pan in categoriasPan) {
        pan.cantidad = 0;
      }
    });
  }

  List<CategoriaPan> categoriasPan = [
    CategoriaPan(
        nombre: "Pan 10",
        precio: 10,
        color: Color.fromARGB(255, 173, 219, 175)),
    CategoriaPan(
        nombre: "Pan 9", precio: 9, color: Color.fromARGB(255, 173, 199, 221)),
    CategoriaPan(
        nombre: "Pan 5", precio: 5, color: Color.fromARGB(255, 173, 128, 128)),
  ];

  int obtenerCantidadDesdeCodigo() {
    final texto = widget.codigoController.text.trim();
    final match = RegExp(r'^\*(\d+)$').firstMatch(texto);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }

  Widget buildCardPan(int index, CategoriaPan pan, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.34;
    if (cardWidth < 120) cardWidth = 120;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
   
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  pan.nombre,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${pan.precio.toStringAsFixed(2)}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),

  
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pan.cantidad.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if (pan.cantidad > 0) {
                      setState(() {
                        pan.cantidad--;
                      });
                      widget.onEliminar(pan.nombre);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[100],
                    ),
                    child:
                        const Icon(Icons.remove, color: Colors.red, size: 28),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    int cantidad = obtenerCantidadDesdeCodigo();
                    setState(() {
                      pan.cantidad += cantidad;
                    });
                    widget.onAgregar(pan.nombre, pan.precio, cantidad);
                    widget.codigoController.clear();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[100],
                    ),
                    child: const Icon(Icons.add, color: Colors.green, size: 28),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoriasPan
            .asMap()
            .entries
            .map((entry) =>
                buildCardPan(entry.key, entry.value, entry.value.color))
            .toList(),
      ),
    );
  }
}
