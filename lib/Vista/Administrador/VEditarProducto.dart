import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/EditarProductoController.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';

class VEditarProducto extends StatefulWidget {
  final Productos producto;
  final Future<void> Function(Productos) updateProduct;
  final String usuarioId;
  final String username;

  const VEditarProducto({
    super.key,
    required this.producto,
    required this.updateProduct,
    required this.usuarioId,
    required this.username,
   
  });

  @override
  State<VEditarProducto> createState() => _VEditarProductoState();
}

class _VEditarProductoState extends State<VEditarProducto> {
  late TextEditingController idcontroller;
  late TextEditingController productonameController;
  late TextEditingController existenciaController;
  late TextEditingController precioController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    idcontroller = TextEditingController(text: widget.producto.id.toString());
    productonameController = TextEditingController(text: widget.producto.productoname);
    existenciaController = TextEditingController(text: widget.producto.existencias.toString());
    precioController = TextEditingController(text: widget.producto.precio.toString());
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const cardColor = Colors.white;
    const mainText = Color(0xFF111827);
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF1F2933),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            
              Navigator.pop(context); 
          },
        ),
        title: Text(
          'Editar Producto',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(2, 4))],
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
                      labelStyle: GoogleFonts.roboto(
                        color: mainText.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.roboto(color: mainText),
                    validator: (value) => (value == null || value.isEmpty) ? "Nombre es requerido" : null,
                  ),
                  const SizedBox(height: 20),

                 
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          enabled: false,
                          controller: idcontroller,
                          decoration: InputDecoration(
                            labelText: "Código",
                            labelStyle: GoogleFonts.roboto(
                              color: mainText.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.roboto(color: mainText),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.qr_code_scanner, size: 32, color: primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: existenciaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Cantidad",
                            labelStyle: GoogleFonts.roboto(
                              color: mainText.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.roboto(color: mainText),
                          validator: (value) => (value == null || value.isEmpty) ? "Cantidad es requerida" : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: precioController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Precio",
                            labelStyle: GoogleFonts.roboto(
                              color: mainText.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.roboto(color: mainText),
                          validator: (value) => (value == null || value.isEmpty) ? "Precio es requerido" : null,
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