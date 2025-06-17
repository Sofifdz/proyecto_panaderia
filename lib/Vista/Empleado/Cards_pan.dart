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
  State<CardsPan> createState() => _CardspanState();
}

class _CardspanState extends State<CardsPan> {
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

  void editarCardPan(int index) {
    final pan = categoriasPan[index];
    TextEditingController nombreController =
        TextEditingController(text: pan.nombre);
    TextEditingController precioController =
        TextEditingController(text: pan.precio.toString());

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Editar categoría",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: GoogleFonts.roboto(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.blue[200]! : Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Precio",
                  labelStyle: GoogleFonts.roboto(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.blue[200]! : Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancelar",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color.fromARGB(255, 209, 219, 250)
                    : const Color.fromARGB(255, 209, 219, 250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  pan.nombre = nombreController.text;
                  pan.precio =
                      double.tryParse(precioController.text) ?? pan.precio;
                });
                Navigator.pop(context);
              },
              child: Text(
                "Guardar",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isDark ? Colors.black : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCardPan(int index, CategoriaPan pan, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.3;

    return GestureDetector(
      onTap: () => editarCardPan(index),
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
