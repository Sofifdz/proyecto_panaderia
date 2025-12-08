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

  void actualizarEmpleados() => setState(() {});
  void _onSearchChanged(String value) => setState(() => _query = value);
  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                size: 30, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Personal",
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded,
                color: isDark ? Colors.white : Colors.black87, size: 30),
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
      drawer: DrawerConfig.administradorDrawer(
          context, widget.usuarioId, widget.username),
      body: StreamBuilder<QuerySnapshot>(
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
              .where((e) =>
                  e.username.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color.fromARGB(146, 225, 225, 225),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: isDark ? Colors.white70 : Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Buscar empleado',
                            hintStyle: TextStyle(
                                color:
                                    isDark ? Colors.white54 : Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Icon(Icons.close,
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            "No hay resultados",
                            style: GoogleFonts.montserrat(
                                fontSize: 18, color: Colors.redAccent),
                          ),
                        )
                      : ListView.builder(
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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[100],
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: Icon(Icons.person,
                                      size: 40,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                  title: Text(
                                    usuario.username,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Rol: ${usuario.role}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VEditarPersonal(
                                          usuarioId: widget.usuarioId,
                                          username: widget.username,
                                          user: usuario,
                                          updateUser:
                                              (Usuarios updatedUser) async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(updatedUser.id)
                                                .update(
                                                    updatedUser.toFirestore());
                                          },
                                        ),
                                      ),
                                    ).then((_) => actualizarEmpleados());
                                  },
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
