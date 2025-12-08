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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90, // más alto que el default
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
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : Colors.black87,
              size: 30,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Ventas por Usuario",
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: empleados.length,
            itemBuilder: (context, index) {
              final empleado = empleados[index];
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
                    total = '\$${(corte['cierreCaja'] ?? 0).toStringAsFixed(2)}';
                  } else if (snapshotCorte.connectionState ==
                      ConnectionState.done) {
                    total = "Sin cortes";
                  }

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
                        "Ventas de $username",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Total del último corte: $total",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: isDark ? Colors.white54 : Colors.grey[700],
                        ),
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
            },
          );
        },
      ),
    );
  }
}
