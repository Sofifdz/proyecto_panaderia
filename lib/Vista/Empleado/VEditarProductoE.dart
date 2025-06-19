import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Controlador/EditarProductoController.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';


class VEditarProductoE extends StatefulWidget {
  final Productos producto;
  final Future<void> Function(Productos) updateProduct;
  final String usuarioId;
  final String username;

  const VEditarProductoE({
    super.key,
    required this.producto,
    required this.updateProduct,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VEditarProductoE> createState() => _VEditarProductoEState();
}

class _VEditarProductoEState extends State<VEditarProductoE> {
  var idcontroller;
  var productonameController;
  var existenciaController;
  var precioController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    idcontroller = TextEditingController(text: widget.producto.id.toString());
    productonameController =
        TextEditingController(text: widget.producto.productoname);
    existenciaController =
        TextEditingController(text: widget.producto.existencias.toString());
    precioController =
        TextEditingController(text: widget.producto.precio.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            EditarProductoController.editar(
              context: context,
              formKey: formKey,
              widget: widget,
              productonameController: productonameController,
              precioController: precioController,
              existenciaController: existenciaController,
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 50.0),
            child: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: productonameController,
                        decoration: InputDecoration(
                          labelText: "Nombre",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nombre es requerido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              enabled: false,
                              controller: idcontroller,
                              decoration: InputDecoration(
                                labelText: "Codigo",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Codigo es requerido";
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                              child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.barcode_reader,
                                    size: 35,
                                    color:
                                        const Color.fromARGB(255, 81, 81, 81),
                                  )))
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: existenciaController,
                              decoration: InputDecoration(
                                labelText: "Cantidad",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Cantidad es requerida";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: TextFormField(
                              controller: precioController,
                              decoration: InputDecoration(
                                labelText: "Precio",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Precio es requerido";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            )));
  }
}
