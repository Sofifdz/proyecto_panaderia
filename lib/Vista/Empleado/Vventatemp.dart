import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/VentaTempController.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DialogBusquedasProductos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ShowDialogVenta.dart';
import 'package:proyecto_panaderia/Vista/Empleado/Cards_pan.dart';

class Vventatemp extends StatefulWidget {
  final String usuarioId;
  final String username;
  const Vventatemp({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<Vventatemp> createState() => _VventatempState();
}

class _VventatempState extends State<Vventatemp> {
  final GlobalKey<CardspanState> _cardsPanKey = GlobalKey<CardspanState>();
  late VentaTempController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VentaTempController(
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
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Caja - ${widget.username}",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller.codigoController,
                      focusNode: _controller.focusNode,
                      onSubmitted: _controller.buscarProducto,
                      style: GoogleFonts.roboto(color: mainText),
                      decoration: InputDecoration(
                        hintText: "Escanear o escribir código",
                        prefixIcon:
                            Icon(Icons.qr_code_scanner, color: primaryBlue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      DialogBusquedaProducto.mostrar(
                        context: context,
                        controller: _controller,
                      );
                    },
                    icon: Icon(Icons.search, color: primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: CardsPan(
                key: _cardsPanKey,
                codigoController: _controller.codigoController,
                onAgregar: _controller.agregarProductoDesdeCard,
                onEliminar: _controller.eliminarProductoDesdeCard,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: mainText,
                        ),
                      ),
                      Text(
                        "\$${_controller.calcularTotal().toStringAsFixed(2)}",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.productosEscaneados.length,
                    itemBuilder: (context, index) {
                      final pc = _controller.productosEscaneados[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                pc.producto.productoname,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  color: mainText,
                                ),
                              ),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: primaryBlue),
                              onPressed: () {
                                _controller.restarUno(pc.producto.id);
                                _cardsPanKey.currentState
                                    ?.restarUnoPorId(pc.producto.id);
                                setState(() {});
                              },
                            ),
                            Text(
                              pc.cantidad.toString(),
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: mainText,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: primaryBlue),
                              onPressed: () {
                                _controller.sumarUno(pc.producto.id);
                                _cardsPanKey.currentState
                                    ?.sumarUnoPorId(pc.producto.id);
                                setState(() {});
                              },
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "\$${(pc.producto.precio * pc.cantidad).toStringAsFixed(2)}",
                                textAlign: TextAlign.end,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: mainText,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _controller.productosEscaneados.remove(pc);
                                });
                                _cardsPanKey.currentState
                                    ?.resetearCantidadPorId(pc.producto.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            onPressed: _controller.productosEscaneados.isEmpty
                ? null
                : _mostrarDialogoPago,
            child: Text(
              "COBRAR",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
