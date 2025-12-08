import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaPan {
  String id; // ✅ ID real del producto (028, 027, etc.)
=======

class CategoriaPan {
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
  String nombre;
  double precio;
  int cantidad;
  Color color;

  CategoriaPan({
<<<<<<< HEAD
    required this.id,
=======
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
    required this.color,
    required this.nombre,
    required this.precio,
    this.cantidad = 0,
  });
}

class CardsPan extends StatefulWidget {
<<<<<<< HEAD
  final Function(String id, double precio, int cantidad) onAgregar;
  final Function(String id) onEliminar;
=======
  final Function(String nombre, double precio, int cantidad) onAgregar;
  final Function(String nombre) onEliminar;
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
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
<<<<<<< HEAD
  List<CategoriaPan> categoriasPan = [];

  @override
  void initState() {
    super.initState();
    cargarPanes();
  }

  Future<void> cargarPanes() async {
    final query =
        await FirebaseFirestore.instance.collection('productos').get();

    const nombresPermitidos = [
      'Pan Francés',
      'Pan 10',
      'Pan 11',
    ];

    setState(() {
      categoriasPan = query.docs
          .where((doc) => nombresPermitidos.contains(doc['productoname']))
          .map((doc) {
            final precio = (doc['precio'] as num).toDouble();

            return CategoriaPan(
              id: doc['id'], // ✅ ID REAL
              nombre: doc['productoname'],
              precio: precio,
              color: _colorPorPrecio(precio),
            );
          })
          .toList();
    });
  }

  Color _colorPorPrecio(double precio) {
    if (precio == 10) {
      return const Color.fromARGB(255, 173, 219, 175);
    } else if (precio == 9) {
      return const Color.fromARGB(255, 173, 199, 221);
    } else {
      return const Color.fromARGB(255, 173, 128, 128);
    }
  }

=======
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
  void resetearCantidades() {
    setState(() {
      for (var pan in categoriasPan) {
        pan.cantidad = 0;
      }
    });
  }

<<<<<<< HEAD
=======
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
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f

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
<<<<<<< HEAD
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
=======
        color: isDark ? Color(0xFF2C2C2C) : Colors.white,
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
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
<<<<<<< HEAD
=======
   
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
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
<<<<<<< HEAD
=======

  
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
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
<<<<<<< HEAD
=======

      
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if (pan.cantidad > 0) {
                      setState(() {
                        pan.cantidad--;
                      });
<<<<<<< HEAD
                      widget.onEliminar(pan.id);
=======
                      widget.onEliminar(pan.nombre);
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[100],
                    ),
<<<<<<< HEAD
                    child: const Icon(Icons.remove,
                        color: Colors.red, size: 28),
=======
                    child:
                        const Icon(Icons.remove, color: Colors.red, size: 28),
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    int cantidad = obtenerCantidadDesdeCodigo();
                    setState(() {
                      pan.cantidad += cantidad;
                    });
<<<<<<< HEAD
                    widget.onAgregar(pan.id, pan.precio, cantidad);
=======
                    widget.onAgregar(pan.nombre, pan.precio, cantidad);
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
                    widget.codigoController.clear();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[100],
                    ),
<<<<<<< HEAD
                    child: const Icon(Icons.add,
                        color: Colors.green, size: 28),
=======
                    child: const Icon(Icons.add, color: Colors.green, size: 28),
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
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
<<<<<<< HEAD
            .map(
              (entry) =>
                  buildCardPan(entry.key, entry.value, entry.value.color),
            )
=======
            .map((entry) =>
                buildCardPan(entry.key, entry.value, entry.value.color))
>>>>>>> f59880e641c4aaf8b5f916dccaea8cf9c73acd3f
            .toList(),
      ),
    );
  }
}
