import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/VentaSegmentedControl.dart';
import 'package:proyecto_panaderia/Modelo/Ventas.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VTicketA.dart';

class VDetallesCortes extends StatefulWidget {
  final String cajaId;

  const VDetallesCortes({super.key, required this.cajaId});

  @override
  State<VDetallesCortes> createState() => _VDetallesCortesState();
}

class _VDetallesCortesState extends State<VDetallesCortes> {
  String tipoVentaFiltro = 'todas';

  String determinarTipoVenta(List<dynamic> productos) {
    bool tienePan = false;
    bool tieneAlmacen = false;

    final productosPan = [
      'Pan 5',
      'Pan 9',
      'Pan 10',
      'Pan pedido',
      'Pan Dulce Mayoreo'
    ];

    for (var prod in productos) {
      if (prod is Map<String, dynamic>) {
        final nombre = (prod['nombre'] ?? '').toString().trim();

        if (productosPan.contains(nombre)) {
          tienePan = true;
        } else {
          tieneAlmacen = true;
        }
      }
    }

    if (tienePan && tieneAlmacen) return 'mixto';
    if (tienePan) return 'pan';
    if (tieneAlmacen) return 'almacen';
    return 'almacen';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final format = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.green.shade900, Colors.green.shade700]
                  : [Colors.green.shade400, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ventas del corte',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('cajas')
            .doc(widget.cajaId)
            .get(),
        builder: (context, snapshotCaja) {
          if (snapshotCaja.hasError) {
            return Center(child: Text('Error: ${snapshotCaja.error}'));
          }

          if (!snapshotCaja.hasData || !snapshotCaja.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final dataCaja = snapshotCaja.data!.data() as Map<String, dynamic>;
          final inicio = dataCaja['inicioCaja'] ?? 0;
          final cierre = dataCaja['cierreCaja'] ?? 0;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Caja: \$${inicio}",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          )),
                      Text("Corte: \$${cierre}",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: VentaSegmentedControl(
                  selectedValue: tipoVentaFiltro,
                  onValueChanged: (value) {
                    setState(() {
                      tipoVentaFiltro = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cajas')
                      .doc(widget.cajaId)
                      .collection('ventas')
                      .snapshots(),
                  builder: (context, snapshotVentas) {
                    if (snapshotVentas.hasError) {
                      return Center(
                          child: Text('Error: ${snapshotVentas.error}'));
                    }

                    if (!snapshotVentas.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todasVentas = snapshotVentas.data!.docs;

                    final ventasFiltradas = todasVentas.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final esPedido = data['desdePedido'] == true;
                      if (esPedido) {
                        return tipoVentaFiltro == 'todas' ||
                            tipoVentaFiltro == 'pan';
                      }

                      final tipo = determinarTipoVenta(data['productos'] ?? []);
                      return tipoVentaFiltro == 'todas' ||
                          tipo == tipoVentaFiltro;
                    }).toList();

                    double totalVentas =
                        ventasFiltradas.fold(0.0, (suma, venta) {
                      final data = venta.data() as Map<String, dynamic>;
                      final monto = (data['total'] ?? 0).toDouble();
                      return suma + monto;
                    });

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('cajas')
                          .doc(widget.cajaId)
                          .collection('pagos')
                          .snapshots(),
                      builder: (context, snapshotPagos) {
                        if (snapshotPagos.hasError) {
                          return Center(
                              child: Text('Error: ${snapshotPagos.error}'));
                        }

                        if (!snapshotPagos.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final pagos = snapshotPagos.data!.docs;
                        double totalPagos = pagos.fold(0.0, (suma, pago) {
                          final data = pago.data() as Map<String, dynamic>;
                          final monto = (data['monto'] ?? 0).toDouble();
                          return suma + monto;
                        });

                        final List<Map<String, dynamic>> items = [
                          if (tipoVentaFiltro == 'todas')
                            ...pagos.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return {
                                'tipo': 'pago',
                                'monto': (data['monto'] ?? 0).toDouble(),
                                'fecha': (data['fecha'] as Timestamp).toDate(),
                                'data': data
                              };
                            }),
                          ...ventasFiltradas.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              'tipo': 'venta',
                              'monto': (data['total'] ?? 0).toDouble(),
                              'fecha': (data['fecha'] as Timestamp).toDate(),
                              'data': data
                            };
                          }),
                        ];

                        items.sort((a, b) => a['fecha'].compareTo(b['fecha']));

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final tipo = item['tipo'];
                                  final monto = item['monto'];
                                  final fecha = item['fecha'];
                                  final data = item['data'];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    child: Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: tipo == 'pago'
                                            ? (isDark
                                                ? Colors.blueGrey.shade800
                                                : Colors.blue.shade50)
                                            : (isDark
                                                ? Colors.grey[850]
                                                : Colors.green.shade50),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              tipo == 'pago'
                                                  ? 'Pago de\n${data['nombre'] ?? '---'}'
                                                  : data['desdePedido'] == true &&
                                                          data['cliente'] != null
                                                      ? '${data['cliente']}'
                                                      : '#${index + 1}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                          Text(
                                            '\$${monto.toStringAsFixed(2)}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyyy hh:mm a')
                                                .format(fecha),
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.black54,
                                            ),
                                          ),
                                          if (tipo == 'venta')
                                            IconButton(
                                              icon: const Icon(Icons.info),
                                              color: Colors.green[800],
                                              onPressed: () {
                                                final ventaObj =
                                                    Ventas.fromFirestoreData(
                                                        data);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VTicketA(
                                                            venta: ventaObj),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(thickness: 1),
                            _resumenCaja("Pagos", totalPagos),
                            _resumenCaja("Total ventas", totalVentas),
                            _resumenCaja("Total", totalVentas - totalPagos,
                                isBold: true),
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

  Widget _resumenCaja(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                fontSize: isBold ? 20 : 18,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              )),
          Text('\$${value.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: isBold ? 20 : 18,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
