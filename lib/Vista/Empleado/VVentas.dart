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

class _VVentasState extends State<VVentas> with SingleTickerProviderStateMixin {
  final GlobalKey<CardspanState> _cardsPanKey = GlobalKey<CardspanState>();
  late VentasController _controller;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _controller = VentasController(
      usuarioId: widget.usuarioId,
      context: context,
      refresh: () => setState(() {}),
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
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
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            appBar: AppBar(
              toolbarHeight: 90,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.purple.shade900, Colors.purple.shade700]
                        : [Colors.purple.shade200, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text(
                "Nueva Venta",
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: _mostrarDialogoPago,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade300, Colors.purple.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              offset: const Offset(2, 4),
                              blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        "Pagar",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            drawer: DrawerConfig.empleadoDrawer(
              context,
              widget.usuarioId,
              widget.username,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 12),
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
                              fillColor:
                                  isDark ? const Color(0xFF3A3A3C) : Colors.purple.shade50,
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
                          icon: Icon(Icons.search_sharp, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text("Productos",
                        style: GoogleFonts.roboto(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          
                          color:  isDark ?  Colors.white : Colors.black,
                        )),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _controller.productosEscaneados.map((pc) {
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 400),
                              opacity: 1,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [Colors.purple.shade700, Colors.purple.shade600]
                                        : [Colors.purple.shade50, Colors.purple.shade100], 
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.1), 
                                      blurRadius: 6,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(pc.producto.productoname,
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: Colors.black, 
                                        )),
                                    Text("Precio: \$${pc.producto.precio}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: Colors.black,
                                        )),
                                    Text("Cantidad: ${pc.cantidad}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: Colors.black, 
                                        )),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _controller.productosEscaneados.remove(pc);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color:  isDark ?  Colors.white : Colors.black,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total:",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:  isDark ?  Colors.white : Colors.black,
                            )),
                        Text("\$${_controller.calcularTotal().toStringAsFixed(2)}",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ?  Colors.white : Colors.black,
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
    );
  }
}
