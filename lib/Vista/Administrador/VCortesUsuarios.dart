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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    mesSeleccionado = DateFormat('MMMM yyyy', 'es_MX').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cortes de ${widget.nombreUsuario}',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
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
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor:
                        isDark ? Colors.grey[850] : Colors.green[50],
                    iconEnabledColor: isDark ? Colors.white : Colors.black87,
                    value: mesSeleccionado,
                    hint: Text(
                      "Selecciona un mes",
                      style: GoogleFonts.montserrat(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    items: listaMeses.map((mes) {
                      return DropdownMenuItem<String>(
                        value: mes,
                        child: Text(
                          mes,
                          style: GoogleFonts.montserrat(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
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

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: esCerrada
                            ? isDark
                                ?  Colors.grey[850]
                                : Colors.green.shade400

                               
                                
                            : isDark
                                ? Colors.orange.shade800
                                : Colors.orange.shade100,
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
                        leading: Icon(
                          esCerrada ? Icons.lock : Icons.lock_open,
                          color: esCerrada
                              ? Colors.green[900]
                              : Colors.orange[900],
                        ),
                        title: Text(
                          esCerrada ? "Caja Cerrada" : "Caja Abierta",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          fechaTexto,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              size: 20,
                              color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VDetallesCortes(
                                    cajaId: cajasFiltradas[index].id),
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
