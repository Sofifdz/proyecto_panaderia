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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        title: Center(
          child: Text(
            "Gastos",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu, size: 30, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_outlined,
                color: isDark ? Colors.white : Colors.black87, size: 30),
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
      drawer: DrawerConfig.empleadoDrawer(context, widget.usuarioId, widget.username),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : cajaId == null
              ? Center(
                  child: Text(
                    'No hay caja activa para este usuario',
                    style: GoogleFonts.montserrat(fontSize: 18),
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
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      );
                    }
                    final pagos = snapshot.data ?? [];
                    if (pagos.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay gastos registrados',
                          style: GoogleFonts.montserrat(fontSize: 18),
                        ),
                      );
                    }

                    double totalPagos = pagos.fold(0, (sum, pago) => sum + pago.monto);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: pagos.length,
                            itemBuilder: (context, index) {
                              final pago = pagos[index];
                              final fechaFormateada = DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(pago.fecha));

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pago.nombre,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Descripción',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pago.descripcion.isNotEmpty
                                            ? pago.descripcion
                                            : 'Sin descripción',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Fecha: $fechaFormateada',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '\$${pago.monto.toStringAsFixed(2)}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.greenAccent[200] : Colors.green[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(
                          thickness: 2,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total de pagos:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '\$${totalPagos.toStringAsFixed(2)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
