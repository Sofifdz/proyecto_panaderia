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

  void _actualizar() => setState(() {});

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
              colors: widget.esEmpleado
                  ? (isDark
                      ? [Colors.purple.shade900, Colors.purple.shade700]
                      : [Colors.purple.shade200, Colors.purple.shade100])
                  : (isDark
                      ? [Colors.green.shade900, Colors.green.shade700]
                      : [Colors.green.shade400, Colors.green.shade300]),
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
            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Almacén",
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
                  builder: (context) =>
                      widget.esEmpleado ? VAgregarProductoE() : VAgregarProducto(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: widget.esEmpleado
          ? DrawerConfig.empleadoDrawer(context, widget.usuarioId, widget.username)
          : DrawerConfig.administradorDrawer(context, widget.usuarioId, widget.username),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
      
            Row(
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
                  icon: Icon(Icons.tune, color: isDark ? Colors.white : Colors.black87, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Productos>>(
                stream: _almacenController.obtenerProductosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return Center(
                      child: Text("No hay productos",
                          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.redAccent)),
                    );

                  final productosFiltrados = snapshot.data!
                      .where((p) => p.productoname.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

      
                  if (_currentFilter == 'precio_asc')
                    productosFiltrados.sort((a, b) => a.precio.compareTo(b.precio));
                  if (_currentFilter == 'precio_desc')
                    productosFiltrados.sort((a, b) => b.precio.compareTo(a.precio));
                  if (_currentFilter == 'existencias_asc')
                    productosFiltrados.sort((a, b) => a.existencias.compareTo(b.existencias));
                  if (_currentFilter == 'existencias_desc')
                    productosFiltrados.sort((a, b) => b.existencias.compareTo(a.existencias));
                  if (_currentFilter == 'nombre_asc')
                    productosFiltrados
                        .sort((a, b) => a.productoname.toLowerCase().compareTo(b.productoname.toLowerCase()));

                  return _ComponentListaProductos(
                    productos: productosFiltrados,
                    usuarioId: widget.usuarioId,
                    username: widget.username,
                    onUpdate: _actualizar,
                    esEmpleado: widget.esEmpleado,
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

class _ComponentListaProductos extends StatelessWidget {
  final List<Productos> productos;
  final String usuarioId;
  final String username;
  final VoidCallback onUpdate;
  final bool esEmpleado;

  const _ComponentListaProductos({
    Key? key,
    required this.productos,
    required this.usuarioId,
    required this.username,
    required this.onUpdate,
    required this.esEmpleado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (productos.isEmpty) {
      return Center(
        child: Text("No hay resultados",
            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.red)),
      );
    }

    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Dismissible(
          key: Key(producto.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async => await DeleteDialog.showDeleteDialog(
            context: context,
            item: producto,
            onDelete: onUpdate,
          ),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: producto.existencias < 10
                  ? LinearGradient(colors: [Colors.red.shade300, Colors.red.shade100])
                  : LinearGradient(
                      colors: esEmpleado
                          ? (isDark
                              ? [Colors.purple.shade900, Colors.purple.shade800]
                              : [Colors.purple.shade200, Colors.purple.shade100])
                          : (isDark
                              ? [Color(0xFF2C2C2E), Color(0xFF2C2C2E)]
                              : [Colors.green.shade100, Colors.green.shade50]),
                    ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(2, 4))
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(producto.productoname,
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("Precio: \$${producto.precio} | Existencias: ${producto.existencias}",
                    style: GoogleFonts.montserrat(fontSize: 16, color: isDark ? Colors.white60 : Colors.black54)),
              ),
              trailing: Icon(Icons.edit, color: isDark ? Colors.white54 : Colors.grey[700]),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => esEmpleado
                        ? VEditarProductoE(
                            producto: producto,
                            usuarioId: usuarioId,
                            username: username,
                            updateProduct: (p) async => onUpdate(),
                          )
                        : VEditarProducto(
                            producto: producto,
                            usuarioId: usuarioId,
                            username: username,
                            updateProduct: (p) async => onUpdate(),
                          ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
