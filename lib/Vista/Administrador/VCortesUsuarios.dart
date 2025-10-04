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
  String? mesSeleccionado;
  List<String> listaMeses = [];

  bool _actualizando = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    mesSeleccionado = DateFormat('MMMM yyyy', 'es_MX').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Cortes de ${widget.nombreUsuario}',
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cajas')
            .where('usuarioId', isEqualTo: widget.userId)
            .orderBy('fechaApertura', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cajas = snapshot.data!.docs;

          if (cajas.isEmpty) {
            return Center(
              child: Text(
                'No hay cajas para este usuario',
                style: GoogleFonts.montserrat(fontSize: 20, color: Colors.red),
              ),
            );
          }

          final Set<String> mesesUnicos = cajas.map((doc) {
            final fecha = (doc['fechaApertura'] as Timestamp).toDate();
            return DateFormat('MMMM yyyy', 'es_MX').format(fecha);
          }).toSet();

          listaMeses = mesesUnicos.toList()..sort((a, b) => b.compareTo(a));
          if (!listaMeses.contains(mesSeleccionado)) {
            mesSeleccionado = null;
          }

          final cajasFiltradas = mesSeleccionado == null
              ? cajas
              : cajas.where((doc) {
                  final fecha = (doc['fechaApertura'] as Timestamp).toDate();
                  final mesActual =
                      DateFormat('MMMM yyyy', 'es_MX').format(fecha);
                  return mesActual == mesSeleccionado;
                }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(160, 133, 203, 144),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 235, 255, 238),
                    iconEnabledColor: Colors.black,
                    value: mesSeleccionado,
                    hint: const Text(
                      "Selecciona un mes",
                      style: TextStyle(color: Colors.black),
                    ),
                    items: listaMeses.map((mes) {
                      return DropdownMenuItem<String>(
                        value: mes,
                        child: Text(
                          mes,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        mesSeleccionado = valor;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cajasFiltradas.length,
                  itemBuilder: (context, index) {
                    final data =
                        cajasFiltradas[index].data() as Map<String, dynamic>;
                    final estado = data['estado'] ?? 'abierta';
                    final format = DateFormat('dd/MM/yyyy hh:mm a');

                    final fechaApertura = data['fechaApertura'] != null
                        ? (data['fechaApertura'] as Timestamp).toDate()
                        : null;

                    final fechaCierre = data['fechaCierre'] != null
                        ? (data['fechaCierre'] as Timestamp).toDate()
                        : null;

                    final esCerrada = estado == 'cerrada';
                    final fechaTexto = esCerrada
                        ? format.format(fechaCierre!)
                        : format.format(fechaApertura!);

                    return Card(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2C2C2E)
                          : const Color.fromARGB(146, 225, 225, 225),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Icon(
                          esCerrada ? Icons.lock : Icons.lock_open,
                          color: esCerrada
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                        title: Text(
                          esCerrada ? "Caja Cerrada" : "Caja Abierta",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          fechaTexto,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VDetallesCortes(cajaId: cajasFiltradas[index].id),
                              ),
                            );
                          },
                        ),
                      ),
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
}
