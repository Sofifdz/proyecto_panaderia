import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarPersonal.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VEditarPersonal.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Componente_busquedas.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';

class VPersonal extends StatefulWidget {
  final String usuarioId;
  final String username;
  const VPersonal({
    Key? key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VPersonal> createState() => _VPersonalState();
}

class _VPersonalState extends State<VPersonal> {
  TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
  }

  void actualizarEmpleados() {
    setState(() {});
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _actualizar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1_rounded,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VAgregarPersonal(
                            usuarioId: widget.usuarioId,
                            username: widget.username,
                          )));
            },
          )
        ],
        title: Center(
          child: Text(
            "Personal",
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
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No hay empleados registrados",
              style: GoogleFonts.montserrat(fontSize: 20, color: Colors.red),
            ),
          );
        }

        final empleadosList = snapshot.data!.docs
            .map((doc) => Usuarios.fromFirestore(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ComponentInputSearch(
                searchController: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
                showFilterSheet: () {}, 
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final filteredList = empleadosList
                        .where((e) => e.username
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          "No hay resultados",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final usuario = filteredList[index];

                        return Dismissible(
                          key: Key(usuario.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await DeleteDialog.showDeleteDialog(
                              context: context,
                              item: usuario,
                              onDelete: actualizarEmpleados,
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
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
                                    builder: (context) => VEditarPersonal(
                                      usuarioId: widget.usuarioId,
                                      username: widget.username,
                                      user: usuario,
                                      updateUser: (Usuarios updatedUser) async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(updatedUser.id)
                                            .update(updatedUser.toFirestore());
                                      },
                                    ),
                                  ),
                                ).then((_) => actualizarEmpleados());
                              },
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFFB0B0B0)
                                          : Colors.black,
                                    ),
                                    title: Text(
                                      "Nombre",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        color:
                                            theme.brightness == Brightness.dark
                                                ? const Color(0xFFB0B0B0)
                                                : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      usuario.username,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        color:
                                            theme.brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
