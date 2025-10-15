import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VTicket.dart';

class VVentasporTurno extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VVentasporTurno({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VVentasporTurno> createState() => _VVentasporTurnoState();
}

class _VVentasporTurnoState extends State<VVentasporTurno> {
  String? _cajaId;

  @override
  void initState() {
    super.initState();
    print("usuarioId recibido en VistaVentasturno: ${widget.usuarioId}");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Ventas",
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: CajaController().obtenerCajaActual(widget.usuarioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2));
                } else {
                  final inicioCaja = snapshot.data?['inicioCaja'];
                  final monto =
                      (inicioCaja is num) ? inicioCaja.toDouble() : 0.0;

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade300, Colors.purple.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          offset: const Offset(2, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Caja: \$${monto.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      body: cuerpo(context, isDark),
    );
  }

  Widget cuerpo(BuildContext context, bool isDark) {
    return FutureBuilder<Map<String, dynamic>>(
      future: CajaController().obtenerCajaActual(widget.usuarioId),
      builder: (context, fechasSnapshot) {
        if (fechasSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!fechasSnapshot.hasData || fechasSnapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No hay caja activa o no se encontraron fechas.",
              style: GoogleFonts.roboto(fontSize: 20, color: Colors.red),
            ),
          );
        }

        final IDcaja = fechasSnapshot.data!['cajaId'];
        _cajaId = IDcaja;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cajas')
              .doc(IDcaja)
              .collection('ventas')
              .orderBy('fecha')
              .snapshots(),
          builder: (context, ventasSnapshot) {
            if (ventasSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!ventasSnapshot.hasData) {
              return Center(
                child: Text(
                  "No hay ventas registradas en este turno.",
                  style: GoogleFonts.roboto(fontSize: 20, color: Colors.red),
                ),
              );
            }

            final ventasList = ventasSnapshot.data!.docs
                .map((doc) => Ventas.fromFirestore(doc))
                .toList();

            double totalVentas = 0;
            for (var venta in ventasList) {
              totalVentas += venta.total;
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cajas')
                  .doc(IDcaja)
                  .collection('pagos')
                  .snapshots(),
              builder: (context, pagosSnapshot) {
                if (pagosSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                double totalPagos = 0;
                if (pagosSnapshot.hasData &&
                    pagosSnapshot.data!.docs.isNotEmpty) {
                  for (var doc in pagosSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final pagoMonto = (data['monto'] ?? 0).toDouble();
                    totalPagos += pagoMonto;
                  }
                }

                double totalNeto = totalVentas - totalPagos;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: ventasList.length,
                        itemBuilder: (context, index) {
                          final venta = ventasList[index];
                          final DateTime fechaParseada =
                              DateTime.parse(venta.fecha);
                          String ff = DateFormat('dd/MM/yyyy\nhh:mm a')
                              .format(fechaParseada);

                  
                          if (venta.desdePedido == true) {
                            return Card(
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              color: isDark
                                  ? const Color(0xFF2C2C2E)
                                  : Colors.purple.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VTicket(venta: venta),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Pedido ${venta.cliente}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 23,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '\$${venta.total.toStringAsFixed(2)}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 23,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          ff,
                                          style: GoogleFonts.roboto(
                                            fontSize: 15,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                       
                          return Card(
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : Colors.purple.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VTicket(venta: venta),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '#${venta.IDventa.toString()}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 23,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '\$${venta.total.toStringAsFixed(2)}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 23,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        ff,
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color: isDark ? Colors.white : Colors.black54,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          _filaResumen('Ventas:', totalVentas, context, isDark),
                          _filaResumen('Pagos:', totalPagos, context, isDark),
                          Divider(
                            thickness: 1,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          _filaResumen('Total:', totalNeto, context, isDark,
                              esTotal: true),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _filaResumen(String texto, double monto, BuildContext context,
      bool isDark,
      {bool esTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto,
            style: GoogleFonts.roboto(
              fontSize: esTotal ? 25 : 20,
              fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            "\$${monto.toStringAsFixed(2)}",
            style: GoogleFonts.roboto(
              fontSize: esTotal ? 25 : 20,
              fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
