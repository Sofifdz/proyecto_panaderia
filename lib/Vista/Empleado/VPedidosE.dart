import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VAgregarPedidoE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VDetallesPedidoE.dart';

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
  List<Pedidos> pedidosList = [];
  bool isLoading = true;

  void pedidos() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color.fromARGB(255, 81, 81, 81),
                size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VAgregarPedidoE(
                            usuarioId: widget.usuarioId,
                            username: widget.username,
                          )));
            },
          )
        ],
        title: Center(
          child: Text(
            "Pedidos",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No hay pedidos registrados",
                style: GoogleFonts.roboto(fontSize: 20, color: Colors.red),
              ),
            );
          }
          final pedidosList = snapshot.data!.docs
              .map((doc) => Pedidos.fromFirestore(doc))
              .where((pedido) => !pedido.isEntregado)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pendientes",
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFB0B0B0)
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                    child: ListView.builder(
                        itemCount: pedidosList.length,
                        itemBuilder: (context, index) {
                          if (index >= pedidosList.length) return SizedBox();

                          final pedido = pedidosList[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VDetallesPedidoE(
                                            pedidoId: pedido.NoPedido,
                                            usuarioId: widget.usuarioId,
                                            username: widget.username,
                                          )));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: _obtenerColor(pedido.isEntregado),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        pedido.cliente,
                                        style: GoogleFonts.roboto(
                                            fontSize: 25,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFFB0B0B0)
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Fecha de entrega:",
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFFB0B0B0)
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            pedido.fecha,
                                            style: GoogleFonts.roboto(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFFB0B0B0)
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        })),
              ],
            ),
          );
        });
  }

  Color _obtenerColor(bool isEntregado) {
    if (!isEntregado) {
      return Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color.fromARGB(255, 217, 217, 218);
    }
    return Color.fromARGB(146, 148, 184, 152);
  }
}
