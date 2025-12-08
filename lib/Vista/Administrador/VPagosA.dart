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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: isDark ? Colors.white : Colors.black87, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Pagos",
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward,
                    color: isDark ? Colors.white : Colors.black87),
                onPressed: () => setState(() => ordenDescendente = true),
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward,
                    color: isDark ? Colors.white : Colors.black87),
                onPressed: () => setState(() => ordenDescendente = false),
              ),
              IconButton(
                  icon: Icon(Icons.calendar_today,
                      color: isDark ? Colors.white : Colors.black87),
                  onPressed: () async {
                    final picked = await Component_date.show(
                        context: context, initialDate: fechaFiltro);
                    if (picked != null) {
                      setState(() {
                        fechaFiltro = picked;
                      });
                    }
                  }),
              if (fechaFiltro != null)
                IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white : Colors.black87),
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
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No se encontraron pagos',
                style: GoogleFonts.montserrat(
                    fontSize: 18, color: Colors.redAccent),
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


          if (fechaFiltro != null) {
            pagos.retainWhere((p) =>
                p['fecha'].year == fechaFiltro!.year &&
                p['fecha'].month == fechaFiltro!.month &&
                p['fecha'].day == fechaFiltro!.day);
          }

        
          pagos.sort((a, b) {
            if (ordenDescendente) {
              return b['fecha'].compareTo(a['fecha']);
            } else {
              return a['fecha'].compareTo(b['fecha']);
            }
          });

          if (pagos.isEmpty) {
            return Center(
              child: Text(
                'No se encontraron pagos',
                style: GoogleFonts.montserrat(
                    fontSize: 18, color: Colors.redAccent),
              ),
            );
          }

     
          double total = pagos.fold(0.0, (sum, p) => sum + p['monto']);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: pagos.length,
                  itemBuilder: (context, index) {
                    final pago = pagos[index];
                    final fechaFormateada =
                        DateFormat('dd/MM/yyyy hh:mm a').format(pago['fecha']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          pago['nombre'],
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "${pago['descripcion']}\nMonto: \$${pago['monto'].toStringAsFixed(2)}\nFecha: $fechaFormateada",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : Colors.black54,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.green.shade900, Colors.green.shade700]
                          : [Colors.green.shade400, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Total pagos: \$${total.toStringAsFixed(2)}",
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
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
