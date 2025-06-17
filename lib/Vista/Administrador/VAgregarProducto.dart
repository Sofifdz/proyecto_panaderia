import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAlmacen.dart';

class VAgregarProducto extends StatefulWidget {
  const VAgregarProducto({super.key});

  @override
  State<VAgregarProducto> createState() => _VAgregarProductoState();
}

class _VAgregarProductoState extends State<VAgregarProducto> {
  String usuarioId = '';
  String username = '';
  final formKey = GlobalKey<FormState>();

  final idcontroller = TextEditingController();
  final productonameController = TextEditingController();
  final existenciaController = TextEditingController();
  final priceController = TextEditingController();
  void initState() {
    super.initState();
    obtenerUsername();
    obtenerUsuarioId();
  }

  void obtenerUsername() async {
    String nombre = await UsuarioController.obtenerUsername(usuarioId);

    setState(() {
      username = nombre;
    });
  }

  void obtenerUsuarioId() async {
    String id = await UsuarioController.obtenerUsuarioId();
    setState(() {
      usuarioId = id;
    });
  }

  Future<void> registrarProducto() async {
    if (!formKey.currentState!.validate()) return;

    try {
      await AlmacenController.registrarProducto(
        id: idcontroller.text,
        nombre: productonameController.text,
        existencias: int.parse(existenciaController.text),
        precio: int.parse(priceController.text),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error al registrar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(160, 133, 203, 144),
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
          IconButton(
            icon: Icon(
              Icons.save,
              size: 30,
              color: theme.brightness == Brightness.dark
                  ? const Color.fromARGB(150, 37, 255, 44)
                  : Colors.green,
            ),
            onPressed: registrarProducto,
          ),
        ],
      ),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    return Padding(
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
                      controller: priceController,
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
          ),
        ),
      ),
    );
  }
}
