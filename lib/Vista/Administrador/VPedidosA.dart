import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/PedidoController.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarPedidoA.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VDeatallesPedidoA.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_date.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';

class VPedidosA extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VPedidosA({super.key, required this.usuarioId, required this.username});

  @override
  State<VPedidosA> createState() => _VPedidosAState();
}

class _VPedidosAState extends State<VPedidosA> {
  String usuarioId = '';
  String username = 'Cargando...';
  bool entregados = false;
  DateTime? fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    usuarioId = widget.usuarioId;
    username = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Pedidos",
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: primaryBlue, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VAgregarPedidoA(
                    username: username,
                    usuarioId: usuarioId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DrawerConfig.administradorDrawer(context, usuarioId, username),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No hay pedidos registrados",
                style: GoogleFonts.montserrat(fontSize: 20, color: Colors.red),
              ),
            );
          }

          final pedidosList = snapshot.data!.docs
              .map((doc) => Pedidos.fromFirestore(doc))
              .toList();

          bool isFechaOk(Pedidos pedido) {
            if (fechaSeleccionada == null) return true;
            try {
              final fechaStr = pedido.fecha.split(' ')[0];
              final partes = fechaStr.split('/');
              final day = int.parse(partes[0]);
              final month = int.parse(partes[1]);
              final year = int.parse(partes[2]);
              final pedidoDate = DateTime(year, month, day);
              return pedidoDate.year == fechaSeleccionada!.year &&
                  pedidoDate.month == fechaSeleccionada!.month &&
                  pedidoDate.day == fechaSeleccionada!.day;
            } catch (e) {
              print("Error al parsear fecha: ${pedido.fecha}, $e");
              return false;
            }
          }

          final pedidosFiltrados = pedidosList.where((pedido) {
            if (entregados) {
              return !pedido.isLiquidado && isFechaOk(pedido);
            } else {
              return isFechaOk(pedido);
            }
          }).toList();

          pedidosFiltrados.sort((a, b) {
            try {
              final formatter = DateFormat('dd/MM/yyyy');
              final aDate = formatter.parse(a.fecha.split(' ')[0]);
              final bDate = formatter.parse(b.fecha.split(' ')[0]);
              int cmp = bDate.compareTo(aDate);
              if (cmp != 0) return cmp;
              if (!a.isLiquidado && b.isLiquidado) return -1;
              if (a.isLiquidado && !b.isLiquidado) return 1;
              return 0;
            } catch (e) {
              return 0;
            }
          });

          PedidoController pedidoController = PedidoController();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      entregados ? "No Liquidado" : "Todos",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      activeColor: Colors.blue,
                      value: entregados,
                      onChanged: (bool value) {
                        setState(() {
                          entregados = value;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 28),
                      onPressed: () async {
                        final picked = await Component_date.show(
                          context: context,
                          initialDate: fechaSeleccionada,
                        );
                        if (picked != null) {
                          setState(() {
                            fechaSeleccionada = picked;
                          });
                        }
                      },
                    ),
                    if (fechaSeleccionada != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => fechaSeleccionada = null),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: pedidosFiltrados.length,
                    itemBuilder: (context, index) {
                      final pedido = pedidosFiltrados[index];
                      return Dismissible(
                        key: Key(pedido.NoPedido),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await DeleteDialog.showDeleteDialog(
                            item: pedido,
                            context: context,
                            onDelete: () => setState(() {}),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VDetallesPedidoA(
                                  pedidoId: pedido.NoPedido,
                                  username: username,
                                  usuarioId: usuarioId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pedido.cliente,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    pedidoController.estadoPedidoWidget(pedido, context),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Fecha de entrega:",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      pedido.fecha,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}