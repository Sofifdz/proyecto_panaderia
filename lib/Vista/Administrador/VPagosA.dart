import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_date.dart';

class VPagosA extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VPagosA({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VPagosA> createState() => _VPagosAState();
}

class _VPagosAState extends State<VPagosA> {
  bool ordenDescendente = true; 
  DateTime? fechaFiltro;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor,
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
          "Pagos",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () => setState(() => ordenDescendente = true),
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                onPressed: () => setState(() => ordenDescendente = false),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final picked =
                      await Component_date.show(context: context, initialDate: fechaFiltro);
                  if (picked != null) {
                    setState(() {
                      fechaFiltro = picked;
                    });
                  }
                },
              ),
              if (fechaFiltro != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () => setState(() => fechaFiltro = null),
                ),
            ],
          ),
        ],
      ),
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('pagos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No se encontraron pagos',
                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.redAccent),
              ),
            );
          }

          final pagos = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime fechaPago;

            if (data['fecha'] is Timestamp) {
              fechaPago = (data['fecha'] as Timestamp).toDate();
            } else if (data['fecha'] is String) {
              try {
                fechaPago = DateTime.parse(data['fecha']);
              } catch (e) {
                fechaPago = DateTime.now();
              }
            } else {
              fechaPago = DateTime.now();
            }

            return {
              'id': doc.id,
              'nombre': data['nombre'] ?? 'Desconocido',
              'descripcion': data['descripcion'] ?? '',
              'monto': (data['monto'] ?? 0).toDouble(),
              'IDcaja': data['IDcaja'] ?? '',
              'fecha': fechaPago,
            };
          }).toList();

          // Filtrar por fecha
          if (fechaFiltro != null) {
            pagos.retainWhere((p) =>
                p['fecha'].year == fechaFiltro!.year &&
                p['fecha'].month == fechaFiltro!.month &&
                p['fecha'].day == fechaFiltro!.day);
          }

          // Ordenar
          pagos.sort((a, b) => ordenDescendente
              ? b['fecha'].compareTo(a['fecha'])
              : a['fecha'].compareTo(b['fecha']));

          if (pagos.isEmpty) {
            return Center(
              child: Text(
                'No se encontraron pagos',
                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.redAccent),
              ),
            );
          }

          double total = pagos.fold(0.0, (sum, p) => sum + p['monto']);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: pagos.length,
                  itemBuilder: (context, index) {
                    final pago = pagos[index];
                    final fechaFormateada =
                        DateFormat('dd/MM/yyyy hh:mm a').format(pago['fecha']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          pago['nombre'],
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: mainText,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "${pago['descripcion']}\nMonto: \$${pago['monto'].toStringAsFixed(2)}\nFecha: $fechaFormateada",
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Total pagos: \$${total.toStringAsFixed(2)}",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}