import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Controlador/PedidoController.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_date.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VAgregarPedidoE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VDetallesPedidoE.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';

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
  DateTime? fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Pedidos - ${widget.username}",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
                  builder: (_) => VAgregarPedidoE(
                    usuarioId: widget.usuarioId,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final pedidosList = snapshot.data!.docs
                .map((doc) => Pedidos.fromFirestore(doc))
                .toList();

            bool isFechaOk(Pedidos pedido) {
              if (fechaSeleccionada == null) return true;
              try {
                final formatter = DateFormat('dd/MM/yyyy');
                final pedidoDate = formatter.parse(pedido.fecha.split(' ')[0]);
                return pedidoDate.year == fechaSeleccionada!.year &&
                    pedidoDate.month == fechaSeleccionada!.month &&
                    pedidoDate.day == fechaSeleccionada!.day;
              } catch (_) {
                return false;
              }
            }

            final pedidosFiltrados = pedidosList.where((pedido) {
              if (pedido.isLiquidado && pedido.isEntregado) return false;
              return isFechaOk(pedido);
            }).toList();

            if (pedidosFiltrados.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Pendientes",
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: mainText,
                        ),
                      ),
                      const Spacer(),
                      if (fechaSeleccionada != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(fechaSeleccionada!),
                            style: GoogleFonts.roboto(
                              color: primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                        icon: Icon(Icons.calendar_month, color: primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: pedidosFiltrados.isEmpty
                          ? Center(
                              child: Text(
                                fechaSeleccionada == null
                                    ? "No hay pedidos pendientes"
                                    : "No hay pedidos para esta fecha",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: pedidosFiltrados.length,
                              itemBuilder: (context, index) {
                                final pedido = pedidosFiltrados[index];
                              },
                            ),
                    ),
                  ),
                ],
              );
            }
            PedidoController pedidoController = PedidoController();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Pendientes",
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainText,
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
                      icon: Icon(Icons.calendar_month, color: primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: pedidosFiltrados.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidosFiltrados[index];

                        return Dismissible(
                          key: Key(pedido.NoPedido),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            return await DeleteDialog.showDeleteDialog(
                              item: pedido,
                              context: context,
                              onDelete: () => setState(() {}),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VDetallesPedidoE(
                                    pedidoId: pedido.NoPedido,
                                    username: widget.username,
                                    usuarioId: widget.usuarioId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pedido.cliente,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w600,
                                            color: mainText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        pedidoController.estadoPedidoWidget(
                                            pedido, context),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      pedido.fecha,
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.roboto(
                                        color: mainText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
