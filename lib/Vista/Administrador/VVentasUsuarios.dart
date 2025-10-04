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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
              size: 30,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Center(
          child: Text(
            "Ventas por Usuario",
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ),
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
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
          padding: const EdgeInsets.all(16),
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
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color.fromARGB(146, 225, 225, 225),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    
                    title: Text(
                      "Ventas de $username",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Total del último corte: $total",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFFCCCCCC)
                              : const Color.fromARGB(255, 81, 81, 81),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                      Icons.arrow_forward_ios,
                      color: isDark ? Colors.white54 : Colors.grey[700],),
                      onPressed: (){
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
    );
  }
}
