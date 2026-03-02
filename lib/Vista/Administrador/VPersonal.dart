import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarPersonal.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VEditarPersonal.dart';
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

  void actualizarEmpleados() => setState(() {});
  void _onSearchChanged(String value) => setState(() => _query = value);
  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Personal",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VAgregarPersonal(
                    usuarioId: widget.usuarioId,
                    username: widget.username,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.roboto(color: mainText),
                      decoration: const InputDecoration(
                        hintText: 'Buscar empleado',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(Icons.close, color: primaryBlue),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(
                      child: Text(
                        "No hay empleados registrados",
                        style: GoogleFonts.montserrat(
                            fontSize: 18, color: Colors.redAccent),
                      ),
                    );

                  final empleadosList = snapshot.data!.docs
                      .map((doc) => Usuarios.fromFirestore(
                          doc as QueryDocumentSnapshot<Map<String, dynamic>>))
                      .toList();

                  final filteredList = empleadosList
                      .where((e) => e.username.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

                  if (filteredList.isEmpty)
                    return Center(
                      child: Text(
                        "No hay resultados",
                        style: GoogleFonts.montserrat(
                            fontSize: 18, color: Colors.redAccent),
                      ),
                    );

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
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: Icon(Icons.person, size: 40, color: primaryBlue),
                            title: Text(
                              usuario.username,
                              style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: mainText),
                            ),
                            subtitle: Text(
                              "Rol: ${usuario.role}",
                              style: GoogleFonts.roboto(color: mainText),
                            ),
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
      ),
    );
  }
}