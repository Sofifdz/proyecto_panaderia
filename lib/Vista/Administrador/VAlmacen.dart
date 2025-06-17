import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAgregarProducto.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VEditarProducto.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_Filtre.dart';
import 'package:proyecto_panaderia/Vista/Componentes/DeleteDialog.dart';

class VAlmacen extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VAlmacen({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VAlmacen> createState() => _VAlmacenState();
}

class _VAlmacenState extends State<VAlmacen> {
  TextEditingController _searchController = TextEditingController();
  final AlmacenController _controller = AlmacenController();

  String query = '';
  String _currentFilter = '';

  List<Productos> productosList = [];
  List<Productos> allProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        query = _searchController.text.toLowerCase();
      });
    });
    _cargarProductos();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarProductos() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('productos').get();

    List<Productos> productos =
        querySnapshot.docs.map((doc) => Productos.fromFirestore(doc)).toList();

    setState(() {
      productosList = productos;
      allProducts = productos;
    });
  }

  void productos() {
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VAgregarProducto()));
            },
          )
        ],
        title: Center(
          child: Text(
            "Almacén",
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar producto',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showFilterSheet,
                  icon: Icon(
                    Icons.filter_alt,
                    size: 35,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Color.fromARGB(255, 81, 81, 81),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(child: body(context)),
          ],
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No hay productos registrados",
              style: GoogleFonts.montserrat(fontSize: 20, color: Colors.red),
            ),
          );
        }

        List<Productos> productosList = snapshot.data!.docs
            .map((doc) => Productos.fromFirestore(doc))
            .where((producto) =>
                producto.productoname.toLowerCase().contains(query))
            .toList();
        switch (_currentFilter) {
          case 'precio_asc':
            productosList.sort((a, b) => a.precio.compareTo(b.precio));
            break;
          case 'precio_desc':
            productosList.sort((a, b) => b.precio.compareTo(a.precio));
            break;
          case 'existencias_asc':
            productosList
                .sort((a, b) => a.existencias.compareTo(b.existencias));
            break;
          case 'existencias_desc':
            productosList
                .sort((a, b) => b.existencias.compareTo(a.existencias));
            break;
          case 'nombre_asc':
            productosList
                .sort((a, b) => a.productoname.compareTo(b.productoname));
            break;
        }

        return ListView.builder(
          itemCount: productosList.length,
          itemBuilder: (context, index) {
            final producto = productosList[index];
            return Dismissible(
              key: Key(producto.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await DeleteDialog.showDeleteDialog(
                  context: context,
                  item: producto,
                  onDelete: productos,
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: _obtenerColor(context, producto.existencias),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VEditarProducto(
                          producto: producto,
                          usuarioId: widget.usuarioId,
                          username: widget.username,
                          updateProduct: (Productos updateProduct) async {
                            await FirebaseFirestore.instance
                                .collection('productos')
                                .doc(updateProduct.id)
                                .update(updateProduct.toFirestore());
                          },
                        ),
                      ),
                    ).then((_) => productos());
                  },
                  child: SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Producto',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 22,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Color.fromARGB(255, 81, 81, 81),
                                    )),
                                Text(producto.productoname,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.brightness == Brightness.dark
                                         ? const Color(0xFFB0B0B0)
                                          : Color.fromARGB(255, 81, 81, 81),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Existencias',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFFB0B0B0)
                                        : Color.fromARGB(255, 81, 81, 81),
                                  )),
                              Text(producto.existencias.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.brightness == Brightness.dark
                                       ? Colors.white
                                        : Color.fromARGB(255, 81, 81, 81),
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Precio',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFFB0B0B0)
                                        : Color.fromARGB(255, 81, 81, 81),
                                  )),
                              Text('\$${producto.precio}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFFB0B0B0)
                                        : Color.fromARGB(255, 81, 81, 81),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _obtenerColor(BuildContext context, int existencia) {
    final brightness = Theme.of(context).brightness;

    if (existencia < 20) {
      return brightness == Brightness.dark
          ? const Color.fromARGB(151, 255, 76, 63)
          : const Color.fromARGB(151, 255, 76, 63);//const Color.fromARGB(255, 255, 135, 126);
    }

    return brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color.fromARGB(146, 225, 225, 225);
  }
}
