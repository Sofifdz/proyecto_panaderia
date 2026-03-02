import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/PagoController.dart';
import 'package:proyecto_panaderia/Modelo/Pagos.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VagregarPago.dart';

class Vpagos extends StatefulWidget {
  final String usuarioId;
  final String username;

  const Vpagos({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<Vpagos> createState() => _VpagosState();
}

class _VpagosState extends State<Vpagos> {
  final CajaController _cajaController = CajaController();
  final PagoController _pagosController = PagoController();

  String? cajaId;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerCaja();
  }

  Future<void> _obtenerCaja() async {
    final datosCaja = await _cajaController.obtenerCajaActual(widget.usuarioId);
    setState(() {
      cajaId = datosCaja['cajaId'];
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.empleadoDrawer(context, widget.usuarioId, widget.username),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        title: Text(
          "Gastos - ${widget.username}",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
           icon: Icon(Icons.add_circle, color: primaryBlue, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Vagregarpago(
                    usuarioId: widget.usuarioId,
                    username: widget.username,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: cargando
    ? const Center(child: CircularProgressIndicator())
    : cajaId == null
        ? Center(
            child: Text(
              'No hay caja activa para este usuario',
              style: GoogleFonts.montserrat(fontSize: 18, color: mainText),
            ),
          )
        : StreamBuilder<List<Pagos>>(
            stream: _pagosController.obtenerPagos(cajaId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar pagos: ${snapshot.error}',
                    style: GoogleFonts.montserrat(fontSize: 16, color: mainText),
                  ),
                );
              }
              final pagos = snapshot.data ?? [];
              double totalPagos = pagos.fold(0, (sum, pago) => sum + pago.monto);

              if (pagos.isEmpty) {
                return Center(
                  child: Text(
                    'No hay gastos registrados',
                    style: GoogleFonts.montserrat(fontSize: 18, color: mainText),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pagos.length,
                        itemBuilder: (context, index) {
                          final pago = pagos[index];
                          final fechaFormateada = DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(pago.fecha));
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        pago.nombre,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: mainText,
                                        ),
                                      ),
                                      Text(
                                        fechaFormateada,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pago.descripcion.isNotEmpty
                                        ? pago.descripcion
                                        : 'Sin descripción',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      
                                      Text(
                                        '\$${pago.monto.toStringAsFixed(2)}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total de pagos:',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainText,
                            ),
                          ),
                          Text(
                            '\$${totalPagos.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}