import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VCortesUsuarios.dart';

class VVentasUsuarios extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VVentasUsuarios({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VVentasUsuarios> createState() => _VVentasUsuariosState();
}

class _VVentasUsuariosState extends State<VVentasUsuarios> {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
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
          "Ventas por Usuario",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Empleado')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay empleados registrados',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
            );
          }

          final empleados = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: empleados.map((empleado) {
                final empleadoId = empleado.id;
                final username = empleado['username'];

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('cajas')
                      .where('usuarioId', isEqualTo: empleadoId)
                      .orderBy('fechaApertura', descending: true)
                      .limit(1)
                      .get(),
                  builder: (context, snapshotCorte) {
                    String total = "Cargando...";

                    if (snapshotCorte.connectionState == ConnectionState.done &&
                        snapshotCorte.hasData &&
                        snapshotCorte.data!.docs.isNotEmpty) {
                      final corte = snapshotCorte.data!.docs.first.data()
                          as Map<String, dynamic>;
                      total =
                          '\$${(corte['cierreCaja'] ?? 0).toStringAsFixed(2)}';
                    } else if (snapshotCorte.connectionState ==
                        ConnectionState.done) {
                      total = "Sin cortes";
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Ventas de $username",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: mainText,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Total del último corte: $total",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: mainText.withOpacity(0.7),
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: primaryBlue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VCortesUsuarios(
                                  userId: empleadoId,
                                  nombreUsuario: username,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}