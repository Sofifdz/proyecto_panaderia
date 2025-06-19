import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarProducto.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VEditarProducto.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_Filtre.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Componente_busquedas.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VAgregarProductoE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VEditarProductoE.dart';

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

  @override
  void initState() {
    super.initState();
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

  void _applyFilter(String? filter) {
    setState(() {
      _currentFilter = filter ?? '';
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Component_Filtre(
        onFilterChanged: (String filter) {
          _applyFilter(filter);
        },
      ),
    );
  }

  void productos() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Color.fromARGB(255, 81, 81, 81),
                size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Color.fromARGB(255, 81, 81, 81),
                size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.esEmpleado
                      ? VAgregarProductoE()
                      : VAgregarProducto(),
                ),
              );
            },
          )
        ],
        title: Center(
          child: Text(
            'Almacén',
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
        backgroundColor: widget.esEmpleado
            ? (theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : const Color.fromARGB(255, 209, 219, 250))
            : const Color.fromARGB(160, 133, 203, 144),
      ),
      drawer: widget.esEmpleado
          ? DrawerConfig.empleadoDrawer(
              context, widget.usuarioId, widget.username)
          : DrawerConfig.administradorDrawer(
              context, widget.usuarioId, widget.username),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                  icon: Icon(
                    Icons.tune,
                    size: 30,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Color.fromARGB(255, 81, 81, 81),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final productosFiltrados = snapshot.data!
                      .where((producto) => producto.productoname
                          .toLowerCase()
                          .contains(_query.toLowerCase()))
                      .toList();

                  if (_currentFilter == 'precio_asc') {
                    productosFiltrados
                        .sort((a, b) => a.precio.compareTo(b.precio));
                  } else if (_currentFilter == 'precio_desc') {
                    productosFiltrados
                        .sort((a, b) => b.precio.compareTo(a.precio));
                  } else if (_currentFilter == 'existencias_asc') {
                    productosFiltrados
                        .sort((a, b) => a.existencias.compareTo(b.existencias));
                  } else if (_currentFilter == 'existencias_desc') {
                    productosFiltrados
                        .sort((a, b) => b.existencias.compareTo(a.existencias));
                  } else if (_currentFilter == 'nombre_asc') {
                    productosFiltrados.sort((a, b) => a.productoname
                        .toLowerCase()
                        .compareTo(b.productoname.toLowerCase()));
                  }

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
    final theme = Theme.of(context);

    if (productos.isEmpty) {
      return Center(
        child: Text(
          "No hay resultados",
          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];

        return Dismissible(
          key: Key(producto.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await DeleteDialog.showDeleteDialog(
              context: context,
              item: producto,
              onDelete: onUpdate,
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            color: _obtenerColor(context, producto.existencias),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 90,
              child: ListTile(
                title: Text(
                  producto.productoname,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      "Precio: \$${producto.precio}",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFFB0B0B0)
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "|",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Existencias: ${producto.existencias}",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFFB0B0B0)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.edit),
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
          ),
        );
      },
    );
  }

  Color _obtenerColor(BuildContext context, int existencia) {
    final brightness = Theme.of(context).brightness;

    if (existencia < 10) {
      return brightness == Brightness.dark
          ? const Color.fromARGB(151, 255, 76, 63)
          : const Color.fromARGB(
              151, 255, 76, 63); //const Color.fromARGB(255, 255, 135, 126);
    }

    return brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color.fromARGB(146, 225, 225, 225);
  }
}
