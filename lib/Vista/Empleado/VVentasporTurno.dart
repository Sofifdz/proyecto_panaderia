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
  Map<String, dynamic>? _cajaData;
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarCajaActual();
  }

  Future<void> _cargarCajaActual() async {
    try {
      final data =
          await CajaController().obtenerCajaActual(widget.usuarioId);

      if (!mounted) return;

      if (data.isEmpty) {
        setState(() {
          _cajaData = null;
          _cajaId = null;
          _cargando = false;
        });
        return;
      }

      setState(() {
        _cajaData = data;
        _cajaId = data['cajaId'] as String?;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cajaData = null;
        _cajaId = null;
        _cargando = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    if (_cargando) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _appBar(appBarColor),
        drawer: DrawerConfig.empleadoDrawer(
          context,
          widget.usuarioId,
          widget.username,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cajaId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _appBar(appBarColor),
        drawer: DrawerConfig.empleadoDrawer(
          context,
          widget.usuarioId,
          widget.username,
        ),
        body: Center(
          child: Text(
            _error
                ? "Ocurrió un error al cargar la caja."
                : "No hay caja activa.",
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      appBar: _appBar(appBarColor),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildContenido(
          primaryBlue,
          mainText,
          backgroundColor,
        ),
      ),
    );
  }

  AppBar _appBar(Color appBarColor) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: appBarColor,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      title: Text(
        "Ventas - ${widget.username}",
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Caja: \$${(_cajaData?['inicioCaja'] ?? 0).toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildContenido(
      Color primaryBlue, Color mainText, Color backgroundColor) {
    final IDcaja = _cajaId!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cajas')
          .doc(IDcaja)
          .collection('ventas')
          .orderBy('fecha')
          .snapshots(),
      builder: (context, ventasSnapshot) {
        if (!ventasSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
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
            double totalPagos = 0;

            if (pagosSnapshot.hasData) {
              for (var doc in pagosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final monto = data['monto'] ?? 0;

                if (monto is int) {
                  totalPagos += monto.toDouble();
                } else if (monto is double) {
                  totalPagos += monto;
                } else {
                  totalPagos += double.tryParse(monto.toString()) ?? 0;
                }
              }
            }

            double totalNeto = totalVentas - totalPagos;

            return Column(
              children: [
                
                Expanded(
                  child: Container(
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
                    child: ListView.builder(
                      itemCount: ventasList.length,
                      itemBuilder: (context, index) {
                        final venta = ventasList[index];

                        DateTime fecha;
                        try {
                          fecha = DateTime.parse(venta.fecha);
                        } catch (_) {
                          fecha = DateTime.now();
                        }

                        String fechaFormateada =
                            DateFormat('dd/MM/yyyy  hh:mm a')
                                .format(fecha);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VTicket(venta: venta),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    venta.desdePedido == true
                                        ? "Pedido ${venta.cliente}"
                                        : "#${venta.IDventa}",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: mainText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "\$${venta.total.toStringAsFixed(2)}",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    fechaFormateada,
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.roboto(
                                      color: mainText,
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
                ),

                const SizedBox(height: 20),

              
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
                    children: [
                      _filaResumen("Ventas:", totalVentas, mainText),
                      const SizedBox(height: 6),
                      _filaResumen("Gastos:", totalPagos, Colors.red),
                      const Divider(),
                      _filaResumen("Total Neto:", totalNeto,
                          primaryBlue,
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
  }

  Widget _filaResumen(String texto, double monto, Color color,
      {bool esTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          texto,
          style: GoogleFonts.montserrat(
            fontSize: esTotal ? 20 : 16,
            fontWeight:
                esTotal ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          "\$${monto.toStringAsFixed(2)}",
          style: GoogleFonts.montserrat(
            fontSize: esTotal ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}