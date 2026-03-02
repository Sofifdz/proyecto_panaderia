import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarProducto.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VEditarProducto.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VAgregarProductoE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VEditarProductoE.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_Filtre.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Componente_busquedas.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';

class VAlmacenCopia extends StatefulWidget {
  final String usuarioId;
  final String username;
  final bool esEmpleado;

  const VAlmacenCopia({
    Key? key,
    required this.usuarioId,
    required this.username,
    this.esEmpleado = false,
  }) : super(key: key);

  @override
  State<VAlmacenCopia> createState() => _VAlmacenCopiaState();
}

class _VAlmacenCopiaState extends State<VAlmacenCopia> {
  final AlmacenController _almacenController = AlmacenController();
  TextEditingController _searchController = TextEditingController();
  String _query = "";
  String _currentFilter = '';

  void _onSearchChanged(String value) => setState(() => _query = value);

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  Future<void> _actualizar() async {
    setState(() {});
  }

  void _applyFilter(String? filter) => setState(() => _currentFilter = filter ?? '');

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => Component_Filtre(onFilterChanged: _applyFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const cardColor = Colors.white;
    const mainText = Color(0xFF111827);
    const primaryBlue = Color(0xFF2563EB);

    final isEmpleado = widget.esEmpleado;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: isEmpleado
          ? DrawerConfig.empleadoDrawer(context, widget.usuarioId, widget.username)
          : DrawerConfig.administradorDrawer(context, widget.usuarioId, widget.username),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF1F2933),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Almacén - ${widget.username}",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: primaryBlue, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isEmpleado ? VAgregarProductoE() : VAgregarProducto(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ComponentInputSearch(
                      searchController: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                      showFilterSheet: () {},
                    ),
                  ),
                  IconButton(
                    onPressed: _showFilterSheet,
                    icon: Icon(Icons.tune, color: primaryBlue, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          
            Expanded(
              child: StreamBuilder<List<Productos>>(
                stream: _almacenController.obtenerProductosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay productos",
                        style: GoogleFonts.montserrat(fontSize: 18, color: Colors.redAccent),
                      ),
                    );
                  }

                  var productosFiltrados = snapshot.data!
                      .where((p) => p.productoname.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

              
                  switch (_currentFilter) {
                    case 'precio_asc':
                      productosFiltrados.sort((a, b) => a.precio.compareTo(b.precio));
                      break;
                    case 'precio_desc':
                      productosFiltrados.sort((a, b) => b.precio.compareTo(a.precio));
                      break;
                    case 'existencias_asc':
                      productosFiltrados.sort((a, b) => a.existencias.compareTo(b.existencias));
                      break;
                    case 'existencias_desc':
                      productosFiltrados.sort((a, b) => b.existencias.compareTo(a.existencias));
                      break;
                    case 'nombre_asc':
                      productosFiltrados.sort(
                          (a, b) => a.productoname.toLowerCase().compareTo(b.productoname.toLowerCase()));
                      break;
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return ProductoCard(
                        producto: producto,
                        esEmpleado: isEmpleado,
                        usuarioId: widget.usuarioId,
                        username: widget.username,
                        onUpdate: _actualizar,
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

class ProductoCard extends StatelessWidget {
  final Productos producto;
  final bool esEmpleado;
  final String usuarioId;
  final String username;
  final Future<void> Function() onUpdate;

  const ProductoCard({
    Key? key,
    required this.producto,
    required this.esEmpleado,
    required this.usuarioId,
    required this.username,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cardColor = Colors.white;
    const mainText = Color(0xFF111827);
    const primaryBlue = Color(0xFF2563EB);

    return Dismissible(
      key: Key(producto.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async =>
          await DeleteDialog.showDeleteDialog(context: context, item: producto, onDelete: onUpdate),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(2, 4))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            producto.productoname,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: mainText),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Precio: \$${producto.precio} | Existencias: ${producto.existencias}",
              style: GoogleFonts.roboto(fontSize: 14, color: mainText.withOpacity(0.7)),
            ),
          ),
          trailing: Icon(Icons.edit, color: primaryBlue),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => esEmpleado
                    ? VEditarProductoE(
                        producto: producto,
                        usuarioId: usuarioId,
                        username: username,
                        updateProduct: (_) async => onUpdate(),
                      )
                    : VEditarProducto(
                        producto: producto,
                        usuarioId: usuarioId,
                        username: username,
                        updateProduct: (_) async => onUpdate(),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}