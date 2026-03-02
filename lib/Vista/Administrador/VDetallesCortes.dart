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

    for (var prod in productos) {
      if (prod is Map<String, dynamic>) {
        final nombre = (prod['nombre'] ?? '').toString().toLowerCase().trim();
        if (nombre.contains('pan')) tienePan = true;
        else tieneAlmacen = true;
      }
    }

    if (tienePan && tieneAlmacen) return 'mixto';
    if (tienePan) return 'pan';
    return 'almacen';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);
    final format = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Ventas del corte',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
                              color: mainText)),
                      Text("Corte: \$${cierre}",
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: mainText)),
                    ],
                  ),
                ),
              ),
             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: VentaSegmentedControl(
                  selectedValue: tipoVentaFiltro,
                  onValueChanged: (value) {
                    setState(() => tipoVentaFiltro = value);
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
                      return Center(child: Text('Error: ${snapshotVentas.error}'));
                    }

                    if (!snapshotVentas.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todasVentas = snapshotVentas.data!.docs;

                    final ventasFiltradas = todasVentas.where((doc) {
                      if (tipoVentaFiltro == 'pagos') return false; 
                      final data = doc.data() as Map<String, dynamic>;
                      final esPedido = data['desdePedido'] == true;
                      if (esPedido) return tipoVentaFiltro == 'todas' || tipoVentaFiltro == 'pan';
                      final tipo = determinarTipoVenta(data['productos'] ?? []);
                      return tipoVentaFiltro == 'todas' || tipo == tipoVentaFiltro;
                    }).toList();

                    double totalVentas = ventasFiltradas.fold(0.0, (suma, venta) {
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
                          return Center(child: Text('Error: ${snapshotPagos.error}'));
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

                      
                        final List<Map<String, dynamic>> items;
                        if (tipoVentaFiltro == 'pagos') {
                          items = pagos.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              'tipo': 'pago',
                              'monto': (data['monto'] ?? 0).toDouble(),
                              'fecha': (data['fecha'] as Timestamp).toDate(),
                              'data': data
                            };
                          }).toList();
                        } else {
                          items = [
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
                        }

                        items.sort((a, b) => a['fecha'].compareTo(b['fecha']));

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: items.length,
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                color: mainText,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '\$${monto.toStringAsFixed(2)}',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: mainText),
                                          ),
                                          Text(
                                            format.format(fecha),
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              color: mainText.withOpacity(0.7),
                                            ),
                                          ),
                                          if (tipo == 'venta')
                                            IconButton(
                                              icon: const Icon(Icons.info),
                                              color: primaryBlue,
                                              onPressed: () {
                                                final ventaObj =
                                                    Ventas.fromFirestoreData(data);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VTicketA(venta: ventaObj),
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
                            if (tipoVentaFiltro != 'pagos')
                              _resumenCaja("Total ventas", totalVentas),
                            _resumenCaja(
                                "Total",
                                tipoVentaFiltro == 'pagos'
                                    ? totalPagos
                                    : totalVentas - totalPagos,
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
    const mainText = Color(0xFF111827);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: isBold ? 20 : 18,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: mainText)),
          Text('\$${value.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                  fontSize: isBold ? 20 : 18,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: mainText)),
        ],
      ),
    );
  }
}