import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VDetallesCortes.dart';

class VCortesUsuarios extends StatefulWidget {
  final String userId;
  final String nombreUsuario;

  const VCortesUsuarios({
    required this.userId,
    required this.nombreUsuario,
    super.key,
  });

  @override
  State<VCortesUsuarios> createState() => _VCortesUsuariosState();
}

class _VCortesUsuariosState extends State<VCortesUsuarios> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'Cortes de ${widget.nombreUsuario}',
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cajas')
            .where('usuarioId', isEqualTo: widget.userId)
            .where('estado', isEqualTo: 'cerrada')
            .orderBy('fechaCierre', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cajas = snapshot.data!.docs;
          print('Cajas encontradas: ${cajas.length}');

          print('userId: ${widget.userId}');

          if (cajas.isEmpty) {
            return Center(
              child: Text(
                'No hay cajas para este usuario',
                style: GoogleFonts.montserrat(fontSize: 20, color: Colors.red),
              ),
            );
          }

          return ListView.builder(
            itemCount: cajas.length,
            itemBuilder: (context, index) {
              final data = cajas[index].data() as Map<String, dynamic>;

              final fechaApertura = data['fechaApertura'] != null
                  ? (data['fechaApertura'] as Timestamp).toDate()
                  : null;

              final fechaCierre = data['fechaCierre'] != null
                  ? (data['fechaCierre'] as Timestamp).toDate()
                  : null;

              final inicio = data['inicioCaja'] ?? 0;
              final cierre = data['cierreCaja'] ?? 0;

              final format = DateFormat('dd/MM/yyyy hh:mm a');

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VDetallesCortes(cajaId: cajas[index].id),
                    ),
                  );
                },
                child: SizedBox(
                  height: 100,
                  child: Card(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : const Color.fromARGB(146, 225, 225, 225),
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          fechaCierre != null
                              ? "Cierre: ${format.format(fechaCierre)}"
                              : "Sin fecha de cierre",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: theme.brightness == Brightness.dark
                                ? const Color.fromARGB(255, 207, 206, 206)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
