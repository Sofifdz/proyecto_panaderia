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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[700]
          : Colors.grey[400],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _BusquedaProductoSheet(controller: controller);
      },
    );
  }
}

class _BusquedaProductoSheet extends StatefulWidget {
  final VentasController controller;
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

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: mediaQuery.viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              ComponentInputSearch(
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
              const SizedBox(height: 10),
              Expanded(
                child: resultados.isEmpty
                    ? Center(
                        child: Text("Sin resultados",
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Color.fromARGB(255, 81, 81, 81),
                            )))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: resultados.length,
                        itemBuilder: (context, index) {
                          final producto = resultados[index];
                          return ListTile(
                            title: Text(producto.productoname,
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            subtitle: Text("\$${producto.precio}",
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Color.fromARGB(255, 81, 81, 81),
                                )),
                            onTap: () {
                              Navigator.of(context).pop(producto);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
