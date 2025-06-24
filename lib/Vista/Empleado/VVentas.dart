import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/VentasController.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DialogBusquedasProductos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ShowDialogVenta.dart';
import 'package:proyecto_panaderia/Vista/Empleado/Cards_pan.dart';

class VVentas extends StatefulWidget {
  final String usuarioId;
  final String username;
  const VVentas({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VVentas> createState() => _VVentasState();
}

class _VVentasState extends State<VVentas> {
  final GlobalKey<CardspanState> _cardsPanKey = GlobalKey<CardspanState>();

  late VentasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VentasController(
      usuarioId: widget.usuarioId,
      context: context,
      refresh: () => setState(() {}),
    );
  }

  void _mostrarDialogoPago() {
    DialogPago.mostrar(
      context: context,
      total: _controller.calcularTotal(),
      onVentaConfirmada: () async {
        await _controller.guardarVenta();
        _controller.limpiarVenta();
        _cardsPanKey.currentState?.resetearCantidades();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f9): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) => _mostrarDialogoPago(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF121212)
                : Colors.white,
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color.fromARGB(255, 209, 219, 250),
              leading: Builder(builder: (context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(255, 81, 81, 81),
                    size: 30,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }),
              actions: [
                ElevatedButton(
                  onPressed: _mostrarDialogoPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF4CAF50)
                            : const Color.fromARGB(255, 168, 209, 172),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Pagar",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color.fromARGB(255, 81, 81, 81),
                    ),
                  ),
                ),
              ],
              title: Text(
                "Nueva Venta",
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color.fromARGB(255, 81, 81, 81),
                ),
              ),
              centerTitle: true,
            ),
            drawer: DrawerConfig.empleadoDrawer(
              context,
              widget.usuarioId,
              widget.username,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            CardsPan(
                              key: _cardsPanKey,
                              codigoController: _controller.codigoController,
                              onAgregar: _controller.agregarProductoDesdeCard,
                              onEliminar: _controller.eliminarProductoDesdeCard,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller.codigoController,
                              focusNode: _controller.focusNode,
                              onSubmitted: _controller.buscarProducto,
                              decoration: InputDecoration(
                                hintText: "Escanear código de barras",
                                prefixIcon: const Icon(Icons.qr_code_scanner),
                                filled: true,
                                fillColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A3C)
                                    : Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              DialogBusquedaProducto.mostrar(
                                context: context,
                                controller: _controller,
                              ).then((productoSeleccionado) {
                                if (productoSeleccionado != null) {
                                  _controller.agregarProductoDesdeCard(
                                    productoSeleccionado.productoname,
                                    productoSeleccionado.precio.toDouble(),
                                    1,
                                  );
                                  setState(() {});
                                }
                              });
                            },
                            icon: Icon(Icons.search_sharp,size: 30,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("Productos",
                          style: GoogleFonts.roboto(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _controller.productosEscaneados.map((pc) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(pc.producto.productoname,
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  Text(
                                    "Precio: \$${pc.producto.precio}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text("Cantidad: ${pc.cantidad}",
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _controller.productosEscaneados
                                            .remove(pc);
                                      });
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
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
                          Text("Total:",
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              )),
                          Text(
                              "\$${_controller.calcularTotal().toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
