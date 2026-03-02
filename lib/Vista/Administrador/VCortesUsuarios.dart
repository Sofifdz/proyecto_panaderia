import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VDetallesCortes.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_date.dart';

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
  DateTime? fechaFiltro;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    mesSeleccionado = DateFormat('MMMM yyyy', 'es_MX').format(now);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cortes de ${widget.nombreUsuario}',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final picked = await Component_date.show(
                  context: context, initialDate: fechaFiltro);
              if (picked != null) {
                setState(() {
                  fechaFiltro = picked;
                  mesSeleccionado =
                      DateFormat('MMMM yyyy', 'es_MX').format(picked);
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
                style: GoogleFonts.montserrat(
                    fontSize: 20, color: Colors.redAccent),
              ),
            );
          }

          final Set<String> mesesUnicos = cajas.map((doc) {
            final fecha = (doc['fechaApertura'] as Timestamp).toDate();
            return DateFormat('MMMM yyyy', 'es_MX').format(fecha);
          }).toSet();

          listaMeses = mesesUnicos.toList()..sort((a, b) => b.compareTo(a));
          if (!listaMeses.contains(mesSeleccionado)) mesSeleccionado = null;

     
          final cajasFiltradas = cajas.where((doc) {
            final fecha = (doc['fechaApertura'] as Timestamp).toDate();
            if (fechaFiltro != null) {
              return fecha.year == fechaFiltro!.year &&
                  fecha.month == fechaFiltro!.month &&
                  fecha.day == fechaFiltro!.day;
            }
            if (mesSeleccionado != null) {
              final mesActual =
                  DateFormat('MMMM yyyy', 'es_MX').format(fecha);
              return mesActual == mesSeleccionado;
            }
            return true;
          }).toList();

          return Column(
            children: [
          
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    iconEnabledColor: primaryBlue,
                    value: mesSeleccionado,
                    hint: Text(
                      "Selecciona un mes",
                      style: GoogleFonts.montserrat(
                          color: mainText, fontWeight: FontWeight.w600),
                    ),
                    items: listaMeses.map((mes) {
                      return DropdownMenuItem(
                        value: mes,
                        child: Text(
                          mes,
                          style: GoogleFonts.montserrat(
                              color: mainText, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        mesSeleccionado = valor;
                        fechaFiltro = null;
                      });
                    },
                  ),
                ),
              ),
            
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                        border: Border.all(
                            color: esCerrada ? primaryBlue : Colors.orange, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(
                          esCerrada ? Icons.lock : Icons.lock_open,
                          color: esCerrada ? primaryBlue : Colors.orange,
                        ),
                        title: Text(
                          esCerrada ? "Caja Cerrada" : "Caja Abierta",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: mainText),
                        ),
                        subtitle: Text(
                          fechaTexto,
                          style: GoogleFonts.roboto(
                              fontSize: 14, color: mainText.withOpacity(0.7)),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              size: 20, color: primaryBlue),
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