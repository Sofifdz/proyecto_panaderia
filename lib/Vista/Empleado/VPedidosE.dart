import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/PedidoController.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_date.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VAgregarPedidoE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VDetallesPedidoE.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';
import 'package:intl/intl.dart';

class VPedidosE extends StatefulWidget {
  final String usuarioId;
  final String username;
  const VPedidosE({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VPedidosE> createState() => _VPedidosEState();
}

class _VPedidosEState extends State<VPedidosE> {
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
                  ? [Colors.purple.shade900, Colors.purple.shade700]
                  : [Colors.purple.shade200, Colors.purple.shade100],
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
          "Pedidos",
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_outlined,
                color: isDark ? Colors.white : Colors.black87, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VAgregarPedidoE(
                    usuarioId: widget.usuarioId,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DrawerConfig.empleadoDrawer(
        context,
        usuarioId,
        username,
      ),
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
            if (pedido.isLiquidado && pedido.isEntregado) return false;

            return isFechaOk(pedido);
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Pendientes",
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final picked = await Component_date.show(
                          context: context,
                          initialDate: fechaSeleccionada,
                        );
                        setState(() {
                          fechaSeleccionada = picked;
                        });
                      },
                      icon: const Icon(Icons.calendar_month, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VDetallesPedidoE(
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
                              borderRadius: BorderRadius.circular(15),
                              gradient: pedido.isLiquidado
                                  ? (pedido.isEntregado
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade300,
                                            Colors.green.shade100
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: isDark
                                              ? [
                                                  Color(0xFF3A3A3C),
                                                  Color(0xFF2C2C2E)
                                                ]
                                              : [
                                                  Colors.grey.shade200,
                                                  Colors.grey.shade100
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ))
                                  : LinearGradient(
                                      colors: [
                                        Colors.red.shade300,
                                        Colors.red.shade100
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    pedidoController.estadoPedidoWidget(
                                        pedido, context),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Fecha de entrega:",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      pedido.fecha,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
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
