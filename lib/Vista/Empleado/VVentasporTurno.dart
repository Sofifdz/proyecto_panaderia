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
  @override
  void initState() {
    super.initState();
    print("usuarioId recibido en VistaVentasturno: ${widget.usuarioId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Color.fromARGB(255, 81, 81, 81),
                size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Caja: \$${monto.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 81, 81, 81),
                          ),
                        ),
                      ),
                    );
                  }
                },
              )),
        ],
        title: Center(
          child: Text(
            "Ventas",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context) {
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

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cajas')
              .doc(IDcaja)
              .collection('ventas')
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
                      style:
                          GoogleFonts.roboto(fontSize: 20, color: Colors.red),
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
                    if (pagosSnapshot.connectionState ==
                        ConnectionState.waiting) {
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

                              return Card(
                                margin:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF2C2C2E)
                                    : Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                      child: venta.desdePedido == true
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Pedido ${venta.cliente}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 23,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${venta.total.toStringAsFixed(2)}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 23,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  ff,
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 15,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '#${venta.IDventa.toString()}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 23,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${venta.total.toStringAsFixed(2)}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 23,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  ff,
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 15,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFFB0B0B0)
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFB0B0B0)
                              : Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              _filaResumen('Ventas:', totalVentas, context),
                              _filaResumen('Pagos:', totalPagos, context),
                              Divider(
                                thickness: 1,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFB0B0B0)
                                    : Colors.black,
                              ),
                              _filaResumen('Total:', totalNeto, context,
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
      },
    );
  }


  Widget _filaResumen(String texto, double monto, BuildContext context,
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          Text(
            "\$${monto.toStringAsFixed(2)}",
            style: GoogleFonts.roboto(
              fontSize: esTotal ? 25 : 20,
              fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
