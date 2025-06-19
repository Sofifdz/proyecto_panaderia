import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VDetallesCortes extends StatelessWidget {
  final String cajaId;

  const VDetallesCortes({super.key, required this.cajaId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final format = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        title: Center(
          child: Text(
            'Ventas del corte',
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('cajas').doc(cajaId).get(),
        builder: (context, snapshotCaja) {
          if (snapshotCaja.hasError) {
            return Center(child: Text('Error: ${snapshotCaja.error}'));
          }

          if (!snapshotCaja.hasData || !snapshotCaja.data!.exists) {
            return const Center(child: Text('Cargando...'));
          }

          final dataCaja = snapshotCaja.data!.data() as Map<String, dynamic>;

          final inicio = dataCaja['inicioCaja'] ?? 0;
          final cierre = dataCaja['cierreCaja'] ?? 0;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Caja: \$${inicio}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )),
                    Text("Corte: \$${cierre}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cajas')
                      .doc(cajaId)
                      .collection('ventas')
                      .orderBy('fecha')
                      .snapshots(),
                  builder: (context, snapshotVentas) {
                    if (snapshotVentas.hasError) {
                      return Center(
                          child: Text('Error: ${snapshotVentas.error}'));
                    }

                    if (!snapshotVentas.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ventas = snapshotVentas.data!.docs;
                    double totalVentas = ventas.fold(0.0, (suma, venta) {
                      final data = venta.data() as Map<String, dynamic>;
                      final monto = (data['total'] ?? 0).toDouble();
                      return suma + monto;
                    });

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('cajas')
                          .doc(cajaId)
                          .collection('pagos')
                          .snapshots(),
                      builder: (context, snapshotPagos) {
                        if (snapshotPagos.hasError) {
                          return Center(
                              child: Text('Error: ${snapshotPagos.error}'));
                        }

                        if (!snapshotPagos.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final pagos = snapshotPagos.data!.docs;
                        double totalPagos = pagos.fold(0.0, (suma, pago) {
                          final data = pago.data() as Map<String, dynamic>;
                          final monto = (data['monto'] ?? 0).toDouble();
                          return suma + monto;
                        });

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: ventas.length,
                                itemBuilder: (context, index) {
                                  final venta = ventas[index].data()
                                      as Map<String, dynamic>;
                                  final monto =
                                      (venta['total'] ?? 0).toDouble();
                                  final fecha =
                                      (venta['fecha'] as Timestamp).toDate();

                                  return SizedBox(
                                    height: 100,
                                    child: Card(
                                      color: theme.brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF2C2C2E)
                                          : const Color.fromARGB(
                                              146, 225, 225, 225),
                                      margin: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            venta['desdePedido'] == true &&
                                                    venta['cliente'] != null
                                                ? 'Pedido de ${venta['cliente']}'
                                                : '#${index + 1}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFFB0B0B0)
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            '\$${monto.toStringAsFixed(2)}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 24,
                                              color: theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFFB0B0B0)
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            format.format(fecha),
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Divider(thickness: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pagos',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  Text('\$${totalPagos.toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total ventas',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  Text('\$${totalVentas.toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '\$${(totalPagos - totalVentas).toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
