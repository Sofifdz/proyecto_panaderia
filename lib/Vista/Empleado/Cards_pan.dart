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
    double cardWidth = screenWidth * 0.3;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : color,
          //border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.black,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pan.nombre,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    pan.cantidad.toString(),
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFB0B0B0)
                          : Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (pan.cantidad > 0) {
                            setState(() {
                              pan.cantidad--;
                            });
                            widget.onEliminar(pan.nombre);
                          }
                        },
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.green, size: 35),
                        onPressed: () {
                          int cantidad = obtenerCantidadDesdeCodigo();

                          setState(() {
                            pan.cantidad += cantidad;
                          });

                          widget.onAgregar(pan.nombre, pan.precio, cantidad);

                          widget.codigoController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
