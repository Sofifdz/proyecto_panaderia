import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VCortesUsuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final colorScheme = theme.colorScheme;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(160, 133, 203, 144),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Color.fromARGB(255, 81, 81, 81),
                size: 30,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          title: Center(
            child: Text(
              "Ventas",
              style: GoogleFonts.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Color.fromARGB(255, 81, 81, 81),
              ),
            ),
          ),
         
        ),
        drawer: DrawerConfig.administradorDrawer(
            context, widget.usuarioId, widget.username),
        body: cuerpo(context));
  }



  Widget cuerpo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Empleado')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final empleados = snapshot.data!.docs;

        if (empleados.isEmpty) {
          return Center(
            child: Text(
              'No hay empleados registrados',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                color: colorScheme.error,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
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

                  if (snapshotCorte.hasData &&
                      snapshotCorte.data!.docs.isNotEmpty) {
                    final corte = snapshotCorte.data!.docs.first.data()
                        as Map<String, dynamic>;
                    total = corte['cierreCaja'].toString();
                  } else if (snapshotCorte.connectionState ==
                      ConnectionState.done) {
                    total = "Sin cortes";
                  } else if (snapshotCorte.hasError) {
                    total = "Error";
                  }

                  return Card(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : const Color.fromARGB(146, 225, 225, 225),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VCortesUsuarios(
                              userId: empleado.id,
                              nombreUsuario: empleado['username'],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            height: 130,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ventas de ${empleado['username']}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Total del último corte: $total",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFFB0B0B0)
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
