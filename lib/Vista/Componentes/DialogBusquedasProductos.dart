import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Componente_busquedas.dart';
import 'package:proyecto_panaderia/Controlador/VentasController.dart';

class DialogBusquedaProducto {
  static Future<Productos?> mostrar({
    required BuildContext context,
    required dynamic controller,
  }) {
    return showModalBottomSheet<Productos>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return _BusquedaProductoSheet(controller: controller);
      },
    );
  }
}

class _BusquedaProductoSheet extends StatefulWidget {
  final dynamic controller;

  const _BusquedaProductoSheet({Key? key, required this.controller})
      : super(key: key);

  @override
  State<_BusquedaProductoSheet> createState() => _BusquedaProductoSheetState();
}

class _BusquedaProductoSheetState extends State<_BusquedaProductoSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Productos> resultados = [];

  Future<void> _buscar(String nombre) async {
    if (nombre.isEmpty) {
      setState(() {
        resultados.clear();
      });
      return;
    }

    final nombreLower = nombre.toLowerCase();
    final consulta =
        await FirebaseFirestore.instance.collection('productos').get();

    final todosProductos =
        consulta.docs.map((doc) => Productos.fromFirestore(doc)).toList();

    setState(() {
      resultados = todosProductos
          .where(
              (prod) => prod.productoname.toLowerCase().contains(nombreLower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.deepPurple.shade800, Colors.deepPurple.shade600]
                  : [Colors.purple.shade100, Colors.purple.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: mediaQuery.viewInsets.bottom + 20,
            ),
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white54 : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Buscar Producto",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ComponentInputSearch(
                    searchController: _searchController,
                    showFilterSheet: () {},
                    onChanged: (value) => _buscar(value),
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        resultados.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: resultados.isEmpty
                        ? Center(
                            child: Text(
                              "Sin resultados",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : const Color.fromARGB(255, 81, 81, 81),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: resultados.length,
                            itemBuilder: (context, index) {
                              final producto = resultados[index];
                              int cantidad = 1;

                              return StatefulBuilder(
                                builder: (context, setStateSB) {
                                  return Card(
                                    color: isDark
                                        ? Colors.deepPurple.shade700
                                        : Colors.white,
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      title: Text(
                                        producto.productoname,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${producto.precio}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                                color: Colors.redAccent,
                                                onPressed: () {
                                                  if (cantidad > 1)
                                                    setStateSB(
                                                        () => cantidad--);
                                                },
                                              ),
                                              Text(
                                                cantidad.toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle_outline),
                                                color: Colors.green,
                                                onPressed: () {
                                                  if (cantidad <
                                                      producto.existencias) {
                                                    setStateSB(
                                                        () => cantidad++);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'No hay más existencias de ${producto.productoname}'),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.add_shopping_cart,
                                          size: 30,
                                          color: isDark
                                              ? Colors.purpleAccent
                                              : Colors.purple.shade400,
                                        ),
                                        onPressed: () {
                                          if (cantidad <=
                                              producto.existencias) {
                                            widget.controller
                                                .agregarProductoCompletoDesdeDialogo(
                                                    producto, cantidad);
                                            Navigator.of(context)
                                                .pop(); 
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Cantidad inválida para ${producto.productoname}'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
