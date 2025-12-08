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
  late TextEditingController idcontroller;
  late TextEditingController productonameController;
  late TextEditingController existenciaController;
  late TextEditingController precioController;
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Producto',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Color(0xFF6A1B9A), Color(0xFF8E24AA)] // Morado oscuro
                  : [Color(0xFFBA68C8), Color(0xFFE1BEE7)], // Morado claro
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
           
                  TextFormField(
                    controller: productonameController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Nombre es requerido" : null,
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
                            labelText: "Código",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.barcode_reader,
                          size: 35,
                          color: isDark ? Colors.white70 : Colors.black87,
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Cantidad",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? "Cantidad es requerida" : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: precioController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Precio",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? "Precio es requerido" : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
