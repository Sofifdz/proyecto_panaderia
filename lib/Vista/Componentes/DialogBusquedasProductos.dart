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

    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlueBg = Color(0xFFF4F6FA);
    const Color cardWhite = Colors.white;
    const Color mainText = Color(0xFF2C2C2C);
    const Color secondaryText = Color(0xFF6B6B6B);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: lightBlueBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Buscar Producto",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: mainText,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: secondaryText),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

              
                Container(
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ComponentInputSearch(
                    searchController: _searchController,
                    showFilterSheet: () {},
                    onChanged: (value) => _buscar(value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => resultados.clear());
                    },
                  ),
                ),

                const SizedBox(height: 20),

            
                Expanded(
                  child: resultados.isEmpty
                      ? Center(
                          child: Text(
                            "Sin resultados",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: secondaryText,
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
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cardWhite,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto.productoname,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: mainText,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "\$${producto.precio}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                          
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons
                                                      .remove_circle_outline),
                                                  color: primaryBlue,
                                                  onPressed: () {
                                                    if (cantidad > 1) {
                                                      setStateSB(
                                                          () => cantidad--);
                                                    }
                                                  },
                                                ),
                                                Text(
                                                  cantidad.toString(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: mainText,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle_outline),
                                                  color: primaryBlue,
                                                  onPressed: () {
                                                    if (cantidad <
                                                        producto.existencias) {
                                                      setStateSB(
                                                          () => cantidad++);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),

                                            
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryBlue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 10,
                                                ),
                                              ),
                                              onPressed: () {
                                                widget.controller
                                                    .agregarProductoCompletoDesdeDialogo(
                                                        producto, cantidad);
                                              },
                                              icon: const Icon(
                                                  Icons.add_shopping_cart, color: Colors.white,),
                                              label: Text(
                                                "Agregar",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
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
